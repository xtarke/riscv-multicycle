-------------------------------------------------------------------
-- Name        : de10_lite.vhd
-- Author      : Joana Wasserberg
-- Version     : 0.1
-- Copyright   : Departamento de Eletrônica, Florianópolis, IFSC
-- Description : Projeto top-level 
-------------------------------------------------------------------
LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity de10_lite is 
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




architecture rtl of de10_lite is

	component clk is
		PORT (
			inclk0	: IN STD_LOGIC_VECTOR (1 DOWNTO 0); --inclk
			c0	    : OUT STD_LOGIC --clk
		);
	END COMPONENT clk;

	signal rst        : std_logic;
	signal direction  : std_logic;
	signal clk_pll    : std_logic; 
	signal segs       : std_logic_vector(7 downto 0);
	signal speed_sel  : std_logic_vector(1 downto 0);
	signal sw_val 		: std_logic_vector(1 downto 0);
	

begin

	 

	pll_inst : entity work.clk
		port map (
			inclk0 => ADC_CLK_10,
			c0     => clk_pll    
		);

	speed_sel <= SW(1 downto 0);
	
	animation_segs_inst : entity work.animation_segs
		port map (
			clk        => clk_pll,  
			rst        => SW(7),
			direction  => SW(6),
			speed		  => speed_sel,
			segs       => segs
			
		);
		
	LEDR(1 downto 0) <= SW(1 downto 0);
	LEDR(7) <= SW(7);
	LEDR(6) <= SW(6);
		
	HEX0 <= segs;
	HEX1 <= segs;
	HEX2 <= segs;
	HEX3 <= segs;
	HEX4 <= segs;
	HEX5 <= segs;

end architecture;