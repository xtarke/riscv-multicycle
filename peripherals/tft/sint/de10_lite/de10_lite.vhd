-------------------------------------------------------------------
-- Name        : de0_lite.vhd
-- Author      : 
-- Version     : 0.1
-- Copyright   : Departamento de Eletrônica, Florianópolis, IFSC
-- Description : Projeto base DE10-Lite
-------------------------------------------------------------------
LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

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
		ARDUINO_RESET_N: inout std_logic;
		
		GPIO: inout std_logic_vector(35 downto 0)
	);
	
	signal clock_100KHz : std_logic;
	
	signal output 	: unsigned(7 downto 0);
	signal cs     	: std_logic;
	signal rs     	: std_logic;
	signal wr     	: std_logic;
	
end entity;


architecture rtl of de10_lite is
begin

 tft_controller_inst : entity work.tft_controller
 	port map(
 		clk    => clock_100KHz,
 		reset  => SW(0),
 		cs     => cs,
 		rs     => rs,
 		wr     => wr,
 		output => output
 	);
 
 PLL_100KHz_inst : entity work.PLL_100KHz
 	port map(
 		inclk0 => ADC_CLK_10,
 		c0     => clock_100KHz
 	);
 
	ARDUINO_IO(8)  <= std_logic(output(7));
	ARDUINO_IO(9)  <= std_logic(output(6));
	ARDUINO_IO(10) <= std_logic(output(5));
	ARDUINO_IO(11) <= std_logic(output(4));
	ARDUINO_IO(12) <= std_logic(output(3));
	ARDUINO_IO(13) <= std_logic(output(2));
	ARDUINO_IO(6)  <= std_logic(output(1));
	ARDUINO_IO(7)  <= std_logic(output(0));
	
	GPIO(35) <= cs;
	GPIO(34) <= rs;
	GPIO(33) <= wr;
	
	LEDR(0) <= clock_100KHz;
end;

