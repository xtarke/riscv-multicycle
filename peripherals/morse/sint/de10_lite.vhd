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

entity de10_lite_Morse is 
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


architecture rtl of de10_lite_Morse is
    
    signal clk : std_logic;
    signal rst : std_logic;
    signal entrada : integer;
    signal buzzer : std_logic;
    signal chaves: unsigned(4 downto 0); 
    
begin
	final:entity work.MorseCodeBuzzer
	    port map(
	        clk     => clk,
	        rst     => rst,
	        entrada => entrada,
			  ledt=>LEDR(2), -- led do tempo T
			  ledf=>LEDR(8), -- led de fim do número
			  led3t=>LEDR(4),-- led do tempo 3T
	        buzzer  => ARDUINO_IO(1)-- pino do meio do modulo do buzzer
	    );

	 entrada<=to_integer(chaves);-- converte as chaves para inteiro, para ir para a entrada 
	rst<=SW(9);-- reset
	chaves(0)<=SW(0);-- chaves de entrada dos números
	chaves(1)<=SW(1);
	chaves(2)<=SW(2);
	chaves(3)<=SW(3);
	chaves(4)<=SW(4);
	
	PLL_inst : entity work.PLL_Morse --clock de 10M e dividido por 4000 (2.5khz)
        port map(
            inclk0 => ADC_CLK_10,
            c0     => clk
        );
end;

