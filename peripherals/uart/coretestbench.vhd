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

	signal address     : std_logic_vector(31 downto 0);

	signal ddata_r_mem : std_logic_vector(31 downto 0);
	signal d_rd : std_logic;
		
	signal input_in	: std_logic_vector(31 downto 0);
	signal cpu_state    : cpu_state_t;
	
	signal debugString  : string(1 to 40) := (others => '0');
	
	signal d_sig : std_logic;

	-- UART Signals
	signal clk_baud : std_logic;
	signal data_in : std_logic_vector(7 downto 0);
	signal tx : std_logic;
	signal start : std_logic;
	signal tx_cmp : std_logic;
	signal data_out : std_logic_vector(SIZE-1 downto 0);
	signal rx : std_logic;
	signal rx_cmp : std_logic;
	signal config_all : std_logic_vector (31 downto 0);
	
	signal csel_uart : std_logic;

	signal dmemory_address : natural;
	
	signal interrupts_combo : std_logic_vector(31 downto 0);


begin

	clock_driver : process
		constant period : time := 1000 ns;
	begin
		clk <= '0';
		--wait for period / 2;
		wait for 1 ns;
		clk <= '1';
		wait for 1 ns;
		--wait for period / 2;
	end process clock_driver;

	reset : process is
	begin
		rst <= '1';
		wait for 5 ns;
		rst <= '0';
		wait;
	end process reset;
	
	clock_baud : process
		constant period : time := 26041 ns;
	begin
		clk_baud <= '0';
		wait for 2 ns;
		--wait for period / 2;
		clk_baud <= '1';
		wait for 2 ns;
		--wait for period / 2;
	end process clock_baud;

	rst_n <= not rst;

	--	imem: component imemory
	--		generic map(
	--			MEMORY_WORDS => IMEMORY_WORDS
	--		)
	--		port map(
	--			clk           => clk,
	--			data          => idata,
	--			write_address => 0,
	--			read_address  => iaddress,
	--			we            => '0',
	--			q             => idata 
	--	);

	-- IMem shoud be read from instruction and data buses
	-- Not enough RAM ports for instruction bus, data bus and in-circuit programming
	-- with dcsel select 
	-- address <= std_logic_vector(to_unsigned(daddress,10)) when "01",
	--			   std_logic_vector(to_unsigned(iaddress,10)) when others;				   
	process(d_rd, dcsel, daddress, iaddress)
	begin
		if (d_rd = '1') and (dcsel = "00") then
			address <= std_logic_vector(to_unsigned(daddress, 32));
		else
			address <= std_logic_vector(to_unsigned(iaddress, 32));
		end if;
	end process;

	-- 32-bits x 1024 words quartus RAM (dual port: portA -> riscV, portB -> In-System Mem Editor
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
			csel    => dcsel(0),
			signal_ext => d_sig,
			dmask   => dmask,
			q       => ddata_r_mem
		);

	-- Adress space mux ((check sections.ld) -> Data chip select:
	-- 0x00000    ->    Instruction memory
	-- 0x20000    ->    Data memory
	-- 0x40000    ->    Input/Output generic address space
	-- 0x60000    ->    SDRAM address space	
	with dcsel select ddata_r <=
		idata when "00",
		ddata_r_mem when "01",
		input_in when "10",
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
		dcsel    => dcsel,
		dmask    => dmask,
		interrupts=>interrupts_combo,
		state    => cpu_state
	);
	
	-- FileOutput DEBUG	
	debug : entity work.trace_debug
	generic map(
		MEMORY_WORDS => 1024
	)
	port map(
		pc   => iaddress,
		data => idata,
		inst => debugString
	);

	

	uart_plus : entity work.uart
	port map(
		clk_in_1M  => clk,
		clk_baud   => clk_baud,
		csel       => csel_uart,
		data_in    => ddata_w(7 downto 0),
		tx         => tx,
		tx_cmp     => tx_cmp,
		data_out   => data_out,
		rx         => rx,
		rx_cmp     => rx_cmp,
		config_all => config_all
	);
	
	-- ToDo: Colocar dentro do módulo. 
	-- ToDo: Uart deve estar em formato do barramento (ver barramento base em gpio.h)
	uart_dcsel: process(dcsel, daddress)
	begin
		csel_uart <= '0';
		if dcsel = "10" then			
			if (to_unsigned(daddress, 32)(15 downto 0) = x"0020") then  -- 0x0020 = (PERIPH_BASE + 2*16*4)) / 4 = 2*16 = 32 = 0x0020
				csel_uart <= '1';
			end if;			
		end if;	
	end process;
	
	
	config_all <= (others => '0');
		
	receive: process
	begin
		data_in <= x"61";
		rx <= '1';
		wait for 50 ns;
		rx <= '0'; -- Start bit
		wait for 50 ns;
		rx <= '1'; -- Start bit
		wait for 50 ns;
		rx <= '0'; -- Start bit
		--wait;
	end process;
	
	

end architecture RTL;
