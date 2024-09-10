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
	signal clk : std_logic;
	signal ws_signal : std_logic;
	signal sd_signal : std_logic;
	signal sck_signal: std_logic;
	signal data : std_logic_vector(95 downto 0);

	
	component pll
		PORT
		(
			inclk0	: IN STD_LOGIC  := '0';
			c0		: OUT STD_LOGIC 
		);
	end component;

	component probe is
		port (
			probe : in std_logic_vector(95 downto 0) := (others => 'X')  -- probe
		);
	end component probe;
	
begin
	
	pll_inst : component pll
		port map(
			inclk0 => MAX10_CLK1_50,
			c0     => clk
		);

	u0 : component probe
			port map (
				probe => data  -- probes.probe
		);	

	I2S_inst : entity work.I2S
		port map(
			clk           => clk,
			sck           => sck_signal,
			rst           => SW(0),
			ws            => ws_signal,
			sd            => sd_signal,
			enable        => SW(1),
			left_channel  => data(31 downto 0),
			right_channel => data(63 downto 32)
		);

	men_cycle_inst : entity work.men_cycle
		port map(
			clk  => clk,
			rst  => SW(0),
			data => data(63 downto 32), -- Grava o sinal do mic direito
			wren => ws_signal,
			q    => data(95 downto 64)
		);
	
		-- Os sinais foram duplicados para a depuração
		ARDUINO_IO(0) <= sck_signal;
		ARDUINO_IO(1) <= sck_signal;
		ARDUINO_IO(2) <= ws_signal;
		ARDUINO_IO(3) <= ws_signal;
		sd_signal <= ARDUINO_IO(4);
		ARDUINO_IO(5) <= sd_signal;
			
end;

