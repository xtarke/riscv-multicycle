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

entity de0_lite is 
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


	

	

	component i2c_master
		port(
			sda     : inout std_logic;
			scl     : inout   std_logic;
			clk     : in    std_logic;
			clk_scl : in    std_logic;
			rst     : in    std_logic;
			ena     : in    std_logic;
			rw      : in    std_logic;
			addr    : in    std_logic_vector(6 downto 0);
			data_w  : in    std_logic_vector(7 downto 0);
			ack_err : out   std_logic
		);
	end component i2c_master;

 
	SIGNAL clk 	 	: std_logic;
	SIGNAL clk_scl 	 	: std_logic;
	
	
begin

	pll_inst : entity work.pll
	 PORT MAP (
		inclk0	 => MAX10_CLK1_50,
		c0	 => clk,
		c1	 => clk_scl
	);
	
	dut : i2c_master
	
	
		port map(
			
			sda		=> ARDUINO_IO(5),
			scl 		=> ARDUINO_IO(1),
			clk      => clk,
			clk_scl	=> clk_scl,
			
			rst     => SW(0),
			ena     => SW(1),
			rw      => SW(2),
			addr    =>  "0100111",
			data_w	=> x"FF",
			ack_err  =>  ARDUINO_IO(7)
									
		);

		ARDUINO_IO(15) <= clk;
		
		
end;

