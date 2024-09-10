-------------------------------------------------------------------
-- Name        : de0_lite.vhd
-- Author      : 
-- Version     : 0.1
-- Copyright   : Departamento de EletrÃ´nica, FlorianÃ³polis, IFSC
-- Description : Projeto base DE10-Lite
-------------------------------------------------------------------
LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;

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

   component probe is
		port (
			source : out std_logic_vector(23 downto 0);                    -- source
         	probe  : in  std_logic_vector(23 downto 0) := (others => 'X')  -- probe
      	);
   end component probe;
	
	component pll
        port (
            inclk0   : in  std_logic;
            c0       : out std_logic;
            locked   : out std_logic
        );
    end component;
	 
	signal source_signial : std_logic_vector(23 downto 0);
	signal probe_signal : std_logic_vector(23 downto 0);
    signal pll_clk   : std_logic;
    signal pll_locked: std_logic;
	 
begin
	
	u0 : component probe
		port map(
         	source => source_signial,
			probe  => probe_signal
      	);

    pll_instance : pll
        port map (
            inclk0  => MAX10_CLK1_50,  -- Clock de entrada (ajuste conforme necessário)
            c0      => pll_clk,        -- Clock de saída do PLL
            locked  => pll_locked      -- Sinal de travamento do PLL
        );
	
	controlador_RGB: entity work.controlador
		port map(
			clk   => pll_clk,
			reset => SW(5),
			start => SW(6),
			restart => SW(7),
			din   => source_signial(23 downto 0),
			dout  => ARDUINO_IO(8)
		);
		
		HEX0 <= (others => '1');
		HEX1 <= (others => '1');
		HEX2 <= (others => '1');
		HEX3 <= (others => '1');
		HEX4 <= (others => '1');
		HEX5 <= (others => '1');
	
end;

