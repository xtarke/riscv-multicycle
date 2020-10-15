---------------------------------------------------------------------
-- Name        : testbench.vhd
-- Author      : Suzi Yousif
-- Description : A complete testbench for Ultrassonic Sensor HC-SR04.
--				 To simulate, use testbench.do file.
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.decoder_types.all;

entity coretestbench is
	generic(
		--! Num of 32-bits memory words 
		IMEMORY_WORDS : integer := 1024;	--!= 4K (1024 * 4) bytes
		DMEMORY_WORDS : integer := 1024  	--!= 2k (512 * 2) bytes
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
		
		---------- ARDUINO IO -----
		ARDUINO_IO: inout std_logic_vector(15 downto 0)
	);	
	
	
end entity coretestbench;

architecture RTL of coretestbench is
	signal clk       : std_logic;
	signal rst       : std_logic;
	signal idata : std_logic_vector(31 downto 0);

	signal daddress : natural;
	signal ddata_r  : std_logic_vector(31 downto 0);
	signal ddata_w  : std_logic_vector(31 downto 0);
	signal dmask    : std_logic_vector(3 downto 0);
	signal dcsel    : std_logic_vector(1 downto 0);
	signal d_we     : std_logic := '0';

	signal iaddress : integer range 0 to IMEMORY_WORDS - 1 := 0;

	signal address     : std_logic_vector(9 downto 0);

	signal ddata_r_mem : std_logic_vector(31 downto 0);
	signal d_rd : std_logic;
			
	signal cpu_state    : cpu_state_t;	
	signal debugString  : string(1 to 40) := (others => '0');
	
	signal dmemory_address : natural;
	signal d_sig : std_logic;
	
	-- I/O signals
	signal ddata_r_gpio : std_logic_vector(31 downto 0);
	signal gpio_input : std_logic;
	signal gpio_output : std_logic;
	
	type displays_type is array (0 to 5) of std_logic_vector(3 downto 0);
	type displays_out_type is array (0 to 5) of std_logic_vector(7 downto 0);

	signal displays     : displays_type;
	signal displays_out : displays_out_type;

begin

	clock_driver : process
		constant period : time := 10000 ns;
	begin
		clk <= '0';
		wait for period / 2;
		clk <= '1';
		wait for period / 2;
	end process clock_driver;

	reset : process is
	begin
		rst <= '1';
		wait for 10000 ns;
		rst <= '0';
		wait;
	end process reset;

	-- IMem shoud be read from instruction and data buses
	-- Not enough RAM ports for instruction bus, data bus and in-circuit programming
	-- with dcsel select 
	-- address <= std_logic_vector(to_unsigned(daddress,10)) when "01",
	--			   std_logic_vector(to_unsigned(iaddress,10)) when others;				   
	process(d_rd, dcsel, daddress, iaddress)
	begin
		if (d_rd = '1') and (dcsel = "00") then
			address <= std_logic_vector(to_unsigned(daddress, 10));
		else
			address <= std_logic_vector(to_unsigned(iaddress, 10));
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
			rst 	=> rst,
			clk 	=> clk,
			data 	=> ddata_w,
			address => dmemory_address,
			we 		=> d_we,
			csel 	=> dcsel(0),
			dmask 	=> dmask,
			signal_ext => d_sig,
			q 		=> ddata_r_mem
		);

	-- Adress space mux ((check sections.ld) -> Data chip select:
	-- 0x00000    ->    Instruction memory
	-- 0x20000    ->    Data memory
	-- 0x40000    ->    Input/Output generic address space
	-- ( ... )    ->    ( ... )
	datamux: entity work.databusmux
		port map(
			dcsel        => dcsel,
			idata        => idata,
			ddata_r_mem  => ddata_r_mem,
			ddata_r_gpio => ddata_r_gpio,
			ddata_r      => ddata_r
		);

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

	HCSR04_inst: entity work.HCSR04
		generic map(
			MY_CHIPSELECT   => "10",
			MY_WORD_ADDRESS => x"10"
		)
		port map(
			clk      => clk,
			rst      => rst,
			daddress => daddress,
			ddata_w  => ddata_w,
			ddata_r  => ddata_r_gpio,
			d_we     => d_we,
			d_rd     => d_rd,
			dcsel    => dcsel,
			dmask    => dmask,
			echo     => gpio_input,
			Trig     => gpio_output
		);
	
	-- Connect gpio data to output hardware
	ARDUINO_IO(1) <= gpio_output;
	
	-- Connect input hardware to gpio data
	gpio_input <= '0', '1' after 800000 ns, '0' after 850000 ns;

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
		
	-- Display		
	hex_gen : for i in 0 to 5 generate
	hex_dec : entity work.display_dec
		port map(
			data_in => displays(i),
			disp    => displays_out(i)
		);
	end generate;
	
	HEX0 <= displays_out(0);
	HEX1 <= displays_out(1);
	HEX2 <= displays_out(2);
	HEX3 <= displays_out(3);
	HEX4 <= displays_out(4);
	HEX5 <= displays_out(5);
	
	display : process (clk, rst) is
	begin
		if rst = '1' then
			for i in 0 to 5 loop
				displays(i) <= (others => '0');
			end loop;	
		elsif rising_edge(clk) then
			if (d_we = '1') and (dcsel = "10")then					
				if to_unsigned(daddress, 32)(8 downto 0) = x"02" then --OUT_SEGS
				 	displays(0) <= ddata_w(3 downto 0);
					displays(1) <= ddata_w(7 downto 4);
					displays(2) <= ddata_w(11 downto 8);
					displays(3) <= ddata_w(15 downto 12);
					displays(4) <= ddata_w(19 downto 16);
					displays(5) <= ddata_w(23 downto 20);
				end if;
			end if;
		end if;
	end process display;
	
end architecture RTL;
