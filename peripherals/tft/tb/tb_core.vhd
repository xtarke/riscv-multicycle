--No código de inicialização do display há delays de inicialização em milisegundos, 
--para conseguir aferir o funcionamento na simulação, é recomendado que altere o
--valor da constante ADJ presente no arquivo "writer.vhd" para o valor 1.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.decoder_types.all;

entity coretestbench is
	generic(
		--! Num of 32-bits memory words 
		IMEMORY_WORDS : integer := 1024;	--!= 4K (1024 * 4) bytes
		DMEMORY_WORDS : integer := 1024;  	--!= 2k (512 * 2) bytes
		constant SIZE : integer := 8		-- 8 bytes UART package
	);
	port(
		----------- SEG7 ------------
		HEX0 : out std_logic_vector(7 downto 0);
		HEX1 : out std_logic_vector(7 downto 0);
		HEX2 : out std_logic_vector(7 downto 0);
		HEX3 : out std_logic_vector(7 downto 0);
		HEX4 : out std_logic_vector(7 downto 0);
		HEX5 : out std_logic_vector(7 downto 0);
		----------- SW ------------

		SW: in std_logic_vector(9 downto 0);		
		LEDR: out std_logic_vector(9 downto 0);
		
		---------- ARDUINO IO -----
		ARDUINO_IO: inout std_logic_vector(15 downto 0)
	);
end entity coretestbench;

architecture RTL of coretestbench is
	signal clk       : std_logic;
	signal clk_sdram : std_logic;
	signal clk_vga   : std_logic;
	signal rst       : std_logic;
	signal rst_n     : std_logic;

	signal idata : std_logic_vector(31 downto 0);

	signal daddress : natural;
	signal ddata_r  : std_logic_vector(31 downto 0);
	signal ddata_w  : std_logic_vector(31 downto 0);
	signal dmask    : std_logic_vector(3 downto 0);
	signal dcsel    : std_logic_vector(1 downto 0);
	signal d_we     : std_logic := '0';
	signal iaddress : integer range 0 to IMEMORY_WORDS - 1 := 0;
	signal address  : std_logic_vector(31 downto 0);

	signal ddata_r_mem : std_logic_vector(31 downto 0);
	signal d_rd : std_logic;
	signal input_in	: std_logic_vector(31 downto 0);
	signal cpu_state    : cpu_state_t;
	signal debugString  : string(1 to 40) := (others => '0');
	
	-- UART Signals
	signal clk_baud : std_logic;
	signal data_in : std_logic_vector(7 downto 0);
	signal tx : std_logic;
	signal start : std_logic;
	signal tx_cmp : std_logic;
	signal data_out : std_logic_vector(SIZE-1 downto 0);
	signal rx : std_logic;
	signal rx_cmp : std_logic;
	
	signal csel_uart : std_logic;
	signal dmemory_address : natural;
	signal d_sig : std_logic;

	-- 1. TFT Read Signal
	signal ddata_r_tft : std_logic_vector(31 downto 0);
	
	-- Display tft physical signals
	signal pin_output : unsigned(7 downto 0);
	signal pin_cs     : std_logic := '0';
	signal pin_rs     : std_logic := '0';
	signal pin_wr     : std_logic := '0';
	signal pin_rst    : std_logic := '0';
	signal ret    	  : unsigned(31 downto 0);
	
begin

	clock_driver : process
		constant period : time := 1000 ns;
	begin
		clk <= '0';
		wait for period / 2;
		clk <= '1';
		wait for period / 2;
	end process clock_driver;

	reset : process is
	begin
		rst <= '1';
		wait for 5 ns;
		rst <= '0';
		wait;
	end process reset;

	rst_n <= not rst;

	process(d_rd, dcsel, daddress, iaddress)
	begin
		if (d_rd = '1') and (dcsel = "00") then
			address <= std_logic_vector(to_unsigned(daddress, 32));
		else
			address <= std_logic_vector(to_unsigned(iaddress, 32));
		end if;
	end process;

	-- 32-bits x 1024 words quartus RAM (dual port: portA -> riscV, portB -> In-System Mem Editor)
	iram_quartus_inst : entity work.iram_quartus
		port map(
			address => address(9 downto 0),
			byteena => "1111",
			clock   => clk,
			data    => (others => '0'),
			wren    => '0',
			q       => idata
		);

	dmemory_address <= to_integer(to_unsigned(daddress, 10));
	
	-- Data Memory RAM
	dmem : entity work.dmemory
		generic map(
			MEMORY_WORDS => DMEMORY_WORDS
		)
		port map(
			rst     => rst,
			clk     => clk,
			data    => ddata_w,
			address => dmemory_address,
			we      => d_we,
			signal_ext => d_sig,
			csel    => dcsel(0),
			dmask   => dmask,
			q       => ddata_r_mem
		);

	-- OR input_in with ddata_r_tft allows both the original IO logic and the 
	-- TFT display to share the dcsel="10" space simultaneously.
	with dcsel select ddata_r <=
		idata when "00",
		ddata_r_mem when "01",
		input_in or ddata_r_tft when "10",
		(others => '0') when others;

	-- Softcore instatiation
	myRiscv : entity work.core
		generic map(
			IMEMORY_WORDS => IMEMORY_WORDS,
			DMEMORY_WORDS => DMEMORY_WORDS
		)
		port map(
			clk      => clk,
			rst      => rst,
			iaddress => iaddress,
			idata    => idata,
			daddress => daddress,
			ddata_r  => ddata_r,
			ddata_w  => ddata_w,
			d_we     => d_we,
			d_rd     => d_rd,
			d_sig	 => d_sig,
			dcsel    => dcsel,
			dmask    => dmask,
			state    => cpu_state
		);

	-- 3instantiated the TFT Component
	tft_inst : entity work.tft
		generic map(
			MY_CHIPSELECT     => "10",
			MY_WORD_ADDRESS   => x"0008",
			DADDRESS_BUS_SIZE => 32
		)
		port map(
			clk        => clk,
			daddress   => to_unsigned(daddress, 32),
			ddata_w    => ddata_w,
			ddata_r    => ddata_r_tft,
			d_we       => d_we,
			d_rd       => d_rd,
			dcsel      => dcsel,
			
			ret        => ret,
			pin_output => pin_output,
			pin_cs     => pin_cs,
			pin_rs     => pin_rs,
			pin_wr     => pin_wr,
			pin_rst    => pin_rst
		);

	-- Output register (Dummy LED blinky)
	process(clk, rst)
	begin
		if rst = '1' then
			LEDR(7 downto 0) <= (others => '0');
			HEX0 <= (others => '1');
			HEX1 <= (others => '1');
			HEX2 <= (others => '1');
			HEX3 <= (others => '1');
			HEX4 <= (others => '1');
			HEX5 <= (others => '1');
		else
			if rising_edge(clk) then
				if (d_we = '1') and (dcsel = "10") then
					if to_unsigned(daddress, 32)(8 downto 0) = x"01" then										
						LEDR(7 downto 0) <= ddata_w(7 downto 0);
					elsif to_unsigned(daddress, 32)(8 downto 0) = x"02" then
						HEX0 <= ddata_w(7 downto 0);
						HEX1 <= ddata_w(15 downto 8);
						HEX2 <= ddata_w(23 downto 16);
						HEX3 <= ddata_w(31 downto 24);
					end if;
				end if;
			end if;
		end if;
	end process;

	-- Input register
	process(clk, rst)
	begin
		if rst = '1' then
			input_in <= (others => '0');
		else
			if rising_edge(clk) then		
				if (d_rd = '1') and (dcsel = "10") then
					if to_unsigned(daddress, 32)(8 downto 0) = x"00" then		
						input_in(4 downto 0) <= SW(4 downto 0);
					elsif to_unsigned(daddress, 32)(8 downto 0) = x"04" then								
						input_in(7 downto 0) <= data_out;						
					else
						-- Ensures unused addresses evaluate to zero so the OR mux works
						input_in <= (others => '0');
					end if;
				else
					input_in <= (others => '0');
				end if;
			end if;
		end if;
	end process;

	-- FileOutput DEBUG	
	debug : entity work.trace_debug
		generic map(
			MEMORY_WORDS => IMEMORY_WORDS
		)
		port map(
			pc   => iaddress,
			data => idata,
			inst => debugString
		);

end architecture RTL;