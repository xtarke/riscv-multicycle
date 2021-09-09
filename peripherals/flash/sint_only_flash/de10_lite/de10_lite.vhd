-------------------------------------------------------------------
-- Name        : de10_lite.vhd
-- Author      : Rafael G. Nagel
-- Version     : 
-- Copyright   : 
-- Description : Projeto base DE10-Lite
-------------------------------------------------------------------
LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
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

	component source_and_probe is
		port (
			source : out std_logic_vector(255 downto 0);  
			probe  : in  std_logic_vector(255 downto 0)
		);
	end component source_and_probe;

	signal source : std_logic_vector(255 downto 0);
	signal probe : std_logic_vector(255 downto 0);

	signal clk   : std_logic;
	signal rst   : std_logic;

    -- core data bus signals
    signal daddress  : unsigned(31 downto 0) := (others => '0');
    signal ddata_w   : std_logic_vector(31 downto 0) := (others => '0');
    signal ddata_r	 : std_logic_vector(31 downto 0) := (others => '0');
    signal d_we      : std_logic := '0';
    signal d_rd	     : std_logic := '0';
    signal dcsel	 : std_logic_vector(1 downto 0) := (others => '0');
    signal dmask     : std_logic_vector(3 downto 0) := (others => '0');	

begin

	u0 : component source_and_probe
		port map (
			source => source,
			probe  => probe
		);

	rst_deb: entity work.debouncer
	generic map (
		SYS_FREQ => 10,
		COUNT => 1000000
	)
	port map (
		clk => ADC_CLK_10,
		rst => '0',
		input => SW(9),
		output => rst
	);

	clk_deb: entity work.debouncer
	generic map (
		SYS_FREQ => 10,
		COUNT => 1000000
	)
	port map (
		clk => ADC_CLK_10,
		rst => '0',
		input => SW(0),
		output => clk
	);

	d_we_deb: entity work.debouncer
	generic map (
		SYS_FREQ => 10,
		COUNT => 1000000
	)
	port map (
		clk => ADC_CLK_10,
		rst => '0',
		input => SW(1),
		output => d_we
	);

	d_rd_deb: entity work.debouncer
	generic map (
		SYS_FREQ => 10,
		COUNT => 1000000
	)
	port map (
		clk => ADC_CLK_10,
		rst => '0',
		input => SW(2),
		output => d_rd
	);

	flash_bus: entity work.flash_bus
		generic map (
			-- chip select
			MY_CHIPSELECT => "00",
			DADDRESS_BUS_SIZE => 32,
			-- if 'daddress' is a shared bus, we may need to setup a daddress offset
			DADDRESS_OFFSET => 0
		)
		port map (
			clk      => clk,
			rst      => rst,

			daddress => daddress,
			ddata_w  => ddata_w,
			ddata_r	 => ddata_r,
			
			d_we     => d_we,
			d_rd	 => d_rd,
			
			dcsel	 => dcsel,
			dmask    => dmask
		);

	daddress <= unsigned(source(31 downto 0));
	ddata_w <= source(63 downto 32);
	probe(31 downto 0) <= ddata_r;
end;

 