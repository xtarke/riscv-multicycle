-------------------------------------------------------------------
-- Name        : de0_lite.vhd
-- Author      : 
-- Version     : 0.1
-- Copyright   : Departamento de Eletrônica, Florianópolis, IFSC
-- Description : Projeto base DE10-Lite
-------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity de10_lite is
	port(
		---------- CLOCK ----------
		ADC_CLK_10      : in    std_logic;
		MAX10_CLK1_50   : in    std_logic;
		MAX10_CLK2_50   : in    std_logic;
		----------- SDRAM ------------
		DRAM_ADDR       : out   std_logic_vector(12 downto 0);
		DRAM_BA         : out   std_logic_vector(1 downto 0);
		DRAM_CAS_N      : out   std_logic;
		DRAM_CKE        : out   std_logic;
		DRAM_CLK        : out   std_logic;
		DRAM_CS_N       : out   std_logic;
		DRAM_DQ         : inout std_logic_vector(15 downto 0);
		DRAM_LDQM       : out   std_logic;
		DRAM_RAS_N      : out   std_logic;
		DRAM_UDQM       : out   std_logic;
		DRAM_WE_N       : out   std_logic;
		----------- SEG7 ------------
		HEX0            : out   std_logic_vector(7 downto 0);
		HEX1            : out   std_logic_vector(7 downto 0);
		HEX2            : out   std_logic_vector(7 downto 0);
		HEX3            : out   std_logic_vector(7 downto 0);
		HEX4            : out   std_logic_vector(7 downto 0);
		HEX5            : out   std_logic_vector(7 downto 0);
		----------- KEY ------------
		KEY             : in    std_logic_vector(1 downto 0);
		----------- LED ------------
		LEDR            : out   std_logic_vector(9 downto 0);
		----------- SW ------------
		SW              : in    std_logic_vector(9 downto 0);
		----------- VGA ------------
		VGA_B           : out   std_logic_vector(3 downto 0);
		VGA_G           : out   std_logic_vector(3 downto 0);
		VGA_HS          : out   std_logic;
		VGA_R           : out   std_logic_vector(3 downto 0);
		VGA_VS          : out   std_logic;
		----------- Accelerometer ------------
		GSENSOR_CS_N    : out   std_logic;
		GSENSOR_INT     : in    std_logic_vector(2 downto 1);
		GSENSOR_SCLK    : out   std_logic;
		GSENSOR_SDI     : inout std_logic;
		GSENSOR_SDO     : inout std_logic;
		----------- Arduino ------------
		ARDUINO_IO      : inout std_logic_vector(15 downto 0);
		ARDUINO_RESET_N : inout std_logic
	);
end entity;

architecture rtl of de10_lite is

component clk is
	PORT
	(
		inclk0		: IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC 
	);
END component clk;


    signal clk_1   : std_logic;
    signal rst   : std_logic;
    signal sec   : std_logic_vector(7 downto 0);
    signal min   : std_logic_vector(7 downto 0);
    signal hour  : std_logic_vector(7 downto 0);
    signal seg0, seg1, seg2, seg3, seg4, seg5 : std_logic_vector(7 downto 0);

begin

    clk_inst : entity work.clk
	port map (
		inclk0	 => ADC_CLK_10,
		c0	 => clk_1
	);
	
	-- Clock e reset controlados por switches
    --clk_1 <= sw(1);
    rst <= sw(0);

    -- LEDs de debug
    --ledr(1) <= clk_1;
    ledr(0) <= rst;
    ledr(9 downto 2) <= (others => '0');

    -- Instancia o RTC
    rtc_inst : entity work.rtc
        port map (
            clk   => clk_1,
            rst   => rst,
            sec   => sec,
            min   => min,
            hour  => hour,
            day   => open,
            month => open,
            year  => open,
            seg0  => seg0,
            seg1  => seg1,
            seg2  => seg2,
            seg3  => seg3,
            seg4  => seg4,
            seg5  => seg5
        );

    -- Atribuição dos segmentos aos displays HEX
    HEX0 <= seg0;  -- unidade dos segundos
    HEX1 <= seg1;  -- dezena dos segundos
    HEX2 <= seg2;  -- unidade dos minutos
    HEX3 <= seg3;  -- dezena dos minutos
    HEX4 <= seg4;  -- unidade das horas
    HEX5 <= seg5;  -- dezena das horas

end architecture;