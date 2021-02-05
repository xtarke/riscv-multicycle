-------------------------------------------------------------------
-- Name        : de0_lite.vhd
-- Author      : 
-- Version     : 0.1
-- Copyright   : Departamento de Eletrônica, Florianópolis, IFSC
-- Description : Projeto base DE10-Lite
-------------------------------------------------------------------
LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.decoder_types.all;

entity de0_lite is 
	generic (
		--! Num of 32-bits memory words 
		IMEMORY_WORDS : integer := 1024;	--!= 4K (1024 * 4) bytes
		DMEMORY_WORDS : integer := 1024  	--!= 2k (512 * 2) bytes
	);
	port (
		---------- CLOCK ----------
		ADC_CLK_10:	in std_logic;
		MAX10_CLK1_50: in std_logic;
		MAX10_CLK2_50: in std_logic;
		
		----------- SDRAM ------------
		DRAM_ADDR: out std_logic_vector (12 downto 0);
		DRAM_BA: out std_logic_vector (1 downto 0);
		DRAM_CAS_N: out std_logic;
		DRAM_CKE: out std_logic;
		DRAM_CLK: out std_logic;
		DRAM_CS_N: out std_logic;		
		DRAM_DQ: inout std_logic_vector(15 downto 0);
		DRAM_LDQM: out std_logic;
		DRAM_RAS_N: out std_logic;
		DRAM_UDQM: out std_logic;
		DRAM_WE_N: out std_logic;
		
		----------- SEG7 ------------
		HEX0: out std_logic_vector(7 downto 0);
		HEX1: out std_logic_vector(7 downto 0);
		HEX2: out std_logic_vector(7 downto 0);
		HEX3: out std_logic_vector(7 downto 0);
		HEX4: out std_logic_vector(7 downto 0);
		HEX5: out std_logic_vector(7 downto 0);

		----------- KEY ------------
		KEY: in std_logic_vector(1 downto 0);

		----------- LED ------------
		LEDR: out std_logic_vector(9 downto 0);

		----------- SW ------------
		SW: in std_logic_vector(9 downto 0);

		----------- VGA ------------
		VGA_B: out std_logic_vector(3 downto 0);
		VGA_G: out std_logic_vector(3 downto 0);
		VGA_HS: out std_logic;
		VGA_R: out std_logic_vector(3 downto 0);
		VGA_VS: out std_logic;
	
		----------- Accelerometer ------------
		GSENSOR_CS_N: out std_logic;
		GSENSOR_INT: in std_logic_vector(2 downto 1);
		GSENSOR_SCLK: out std_logic;
		GSENSOR_SDI: inout std_logic;
		GSENSOR_SDO: inout std_logic;
	
		----------- Arduino ------------
		ARDUINO_IO: inout std_logic_vector(15 downto 0);
		ARDUINO_RESET_N: inout std_logic
	);
end entity;



architecture rtl of de0_lite is
		
	signal clk_pll : std_logic;
	signal clk : std_logic;
	signal rst : std_logic;
	
	-- Instruction bus signals
	signal idata     : std_logic_vector(31 downto 0);
	signal iaddress  : integer range 0 to IMEMORY_WORDS-1 := 0;
	signal address   : std_logic_vector (9 downto 0);
	
	-- Data bus signals
	signal daddress :  integer range 0 to DMEMORY_WORDS-1;
	signal ddata_r	:  	std_logic_vector(31 downto 0);
	signal ddata_w  :	std_logic_vector(31 downto 0);
	signal dmask    : std_logic_vector(3 downto 0);
	signal dcsel    : std_logic_vector(1 downto 0);
	signal d_we     : std_logic := '0';
	
	signal ddata_r_mem : std_logic_vector(31 downto 0);
	signal d_rd : std_logic;			
	
	-- I/O signals
	signal ddata_r_gpio : std_logic_vector(31 downto 0);
	
	-- PLL signals
	signal locked_sig : std_logic;
	
	-- CPU state signals
	signal state : cpu_state_t;
	signal d_sig : std_logic;

	-- Things I'm gonna use
	
	signal debug_leds	  : 	std_logic_vector(7 downto 0);
	signal debug_hex0	  : 	std_logic_vector(3 downto 0);
	signal debug_hex1	  : 	std_logic_vector(3 downto 0);
	signal debug_hex2	  : 	std_logic_vector(3 downto 0);
	signal debug_hex3	  : 	std_logic_vector(3 downto 0);
	signal debug_hex4	  : 	std_logic_vector(3 downto 0);
	signal debug_hex5	  : 	std_logic_vector(3 downto 0);
	
	signal clk_count : std_logic;
	
	-- 7 segments display
	type displays_type is array (0 to 5) of std_logic_vector(3 downto 0);
	type displays_out_type is array (0 to 5) of std_logic_vector(7 downto 0);

	signal displays     : displays_type;
	signal displays_out : displays_out_type;	

begin
	
	pll_inst: entity work.pll
		port map(
			areset => '0',
			inclk0 => ADC_CLK_10,
			c0     => clk_pll,
			locked => locked_sig
		);

	--clk <= clk_count;
	clk <= clk_pll;

	slow_clock_to_debug: process (clk_pll) is
			variable counter : integer := 0;
			variable um_segundo : integer := 10000;
			variable meio_segundo : integer := 5000;
		begin
			if rst = '1' then
				counter := 0;
				clk_count <= '0';
			elsif rising_edge(clk_pll) then
				counter := counter + 1;
				if counter = meio_segundo then
					clk_count <= '1';
				elsif (counter = um_segundo) then
					clk_count <='0';
					counter := 0;
				end if;
			end if;
		end process slow_clock_to_debug;
	
	-- Dummy out signals	
	rst <= SW(9);	
	LEDR(9) <= SW(9);	
	LEDR(8) <= clk;	
	
	-- IMem shoud be read from instruction and data buses
	-- Not enough RAM ports for instruction bus, data bus and in-circuit programming
	instr_mux: entity work.instructionbusmux
		generic map(
			IMEMORY_WORDS => IMEMORY_WORDS,			
			DMEMORY_WORDS => DMEMORY_WORDS
		)
		port map(
			d_rd     => d_rd,
			dcsel    => dcsel,
			daddress => daddress,
			iaddress => iaddress,
			address  => address
		);
	
	-- 32-bits x 1024 words quartus RAM (dual port: portA -> riscV, portB -> In-System Mem Editor
	iram_quartus_inst: entity work.iram_quartus
		port map(
			address => address,
			byteena => "1111",
			clock   => clk,
			data    => (others => '0'),
			wren    => '0',
			q       => idata
		);
	
	-- Data Memory RAM
	dmem: entity work.dmemory
		generic map(
			MEMORY_WORDS => DMEMORY_WORDS
		)
		port map(
			rst => rst,
			clk => clk,
			data => ddata_w,
			address => daddress,
			we => d_we,
			csel => dcsel(0),
			dmask => dmask,
			signal_ext => d_sig,
			q => ddata_r_mem
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
	myRisc: entity work.core
		generic map(
			IMEMORY_WORDS => IMEMORY_WORDS,
			DMEMORY_WORDS => DMEMORY_WORDS
		)
		port map(			
			clk 		=> clk,
			rst 		=> rst,
			iaddress 	=> iaddress,
			idata 		=> idata,
			daddress 	=> daddress,
			ddata_r 	=> ddata_r,
			ddata_w 	=> ddata_w,
			d_we  => d_we,
			d_rd  => d_rd,
			d_sig => d_sig,
			dcsel => dcsel,
			dmask => dmask,
			state => state
		);
		
	-- dig_filt instance
	dig_filt: entity work.dig_filt
		generic map(
			MY_CHIPSELECT => "10"
		)
		port map(			
			clk 		=> clk,
			rst 		=> rst,

			-- databus interface
			daddress 	=> daddress,
			ddata_r 	=> ddata_r_gpio,
			ddata_w 	=> ddata_w,
			d_we  => d_we,
			d_rd  => d_rd,
			dcsel => dcsel,
			dmask => dmask,

			-- Debug signals
			debug_leds => debug_leds,
			debug_hex0 => debug_hex0,
			debug_hex1 => debug_hex1,
			debug_hex2 => debug_hex2,
			debug_hex3 => debug_hex3,
			debug_hex4 => debug_hex4,
			debug_hex5 => debug_hex5
		);
	
	
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
	

	-- Debug process, to watch ddata_w when core access the peripheral
	display : process (clk, rst) is
	begin
		if rst = '1' then
			for i in 0 to 5 loop
				displays(i) <= (others => '0');
			end loop;	
		elsif rising_edge(clk) then
			if ((d_rd = '1') or (d_we = '1')) and (dcsel = "10") then
				displays(0) <= debug_hex0;
				displays(1) <= debug_hex1;
				displays(2) <= debug_hex2;
				displays(3) <= debug_hex3;
				displays(4) <= debug_hex4;
				if to_unsigned(daddress, 32)(7 downto 0) = x"01" then
					displays(5) <= ddata_w(3 downto 0); -- reading DIG_FILT_OUT from OUTBUS
				end if;
				LEDR(7 downto 0) <= debug_leds;
			end if;

		end if;
	end process display;
	
	
 	
end;

