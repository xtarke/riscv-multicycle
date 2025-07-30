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

    component pll
        PORT(
            inclk0 : IN  STD_LOGIC := '0';
            c0     : OUT STD_LOGIC
        );

    end component;
	 
	 -- Sinais 
    signal clk_pll    : std_logic;
	 signal clk_10Hz   : std_logic;
	 signal clk_A   : std_logic;


begin
		  
-- Bloco PLL: Clock de 10MHz para 1MHz
	 u1 : component pll
        port map(
            inclk0 => ADC_CLK_10,
            c0  => clk_pll          
			);
	
	 
-- instância do divisor de clock de 1MHz para 10Hz		
	  divisor_clock_inst : entity work.divisor_clock
	  generic map(
                max => 50000
            )
        port map(
            clk    => clk_pll,
            output => clk_10Hz
        );
		  
		  
 -- Gerar A: 1MHz para 1kHz para validação do código
	  Clock_A : entity work.divisor_clock
	  generic map(
                max => 500
            )
        port map(
            clk    => clk_pll,
            output => clk_A
        );

		  
-- instância do enconder
	     encoder_inst : entity work.encoder
        port map(
            clk    => clk_10Hz,
            aclr_n => sw(9),
            A      => ARDUINO_IO(0), --clk_A,
            B      => ARDUINO_IO(1),
            segs_a => HEX0,
            segs_b => HEX1,
            segs_c => HEX2,
				segs_d => HEX3,
            segs_e => HEX4
        );
	  	  
	  HEX5 <= (others => '1'); -- Apagar Display não utilizado

end;

