-------------------------------------------------------------------
-- Name        : de0_lite.vhd
-- Author      : 
-- Version     : 0.1
-- Copyright   : Departamento de Eletrônica, Florianópolis, IFSC
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

signal clk_pll				: std_logic;

signal sources				: std_logic_vector(17 downto 0);
signal source_clk 		: std_logic;
signal source_rst			: std_logic;
signal source_data		: std_logic_vector(7 downto 0);
signal source_modo		: std_logic_vector(7 downto 0);

signal probesa				: std_logic_vector(2 downto 0);
signal probe_din			: std_logic;
signal probe_clk_out		: std_logic;
signal probe_cs			: std_logic;

signal program				: std_logic;

	component probes is
		port (
			source : out std_logic_vector(17 downto 0);                    -- source
			probe  : in  std_logic_vector(2 downto 0)  := (others => 'X')  -- probe
		);
	end component probes;

begin
	
		pll_u0: ENTITY work.pll
	PORT map
	(
		inclk0		=> ADC_CLK_10,
		c0				=> clk_pll
	);
	
	
	source_clk 		<= clk_pll;--SW(0);--sources(0);  --
	source_rst 		<= sources(1);
	source_data 	<= sources(9 downto 2);
	source_modo		<= sources(17 downto 10);
	
	probesa(0) 		<= probe_din;
	probesa(1)		<= probe_clk_out;
	probesa(2)		<= probe_cs;
	
	
	u0 : component probes
		port map (
			source => sources, -- sources.source
			probe  => probesa   --  probes.probe
		);

	
	max : entity work.max7219cn
		port map(
			clk     => source_clk,
			rst     => source_rst,
			data    => source_data,
			modo    => source_modo,
			program => program,
			din     => probe_din,
			clk_out => probe_clk_out,
			cs      => probe_cs
		);
		
	ARDUINO_IO(1) <= probe_cs;
	ARDUINO_IO(4) <= probe_clk_out;
	ARDUINO_IO(8) <= probe_din;
	
	program <= SW(0);
	
	

end;

