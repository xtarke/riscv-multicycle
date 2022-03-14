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
    component probes is
        port (
            source : out std_logic_vector(31 downto 0);                    -- source
            probe  : in  std_logic_vector(31 downto 0) := (others => 'X')  -- probe
    );
    end component probes;

    signal data_in : Unsigned(23 downto 0);
    signal data_out: std_logic;
	 signal clk20M  : std_logic;
    signal clk800K0 : std_logic;
    signal clk800K1 : std_logic;
    signal source : std_logic_vector(31 downto 0);
    signal probe :  std_logic_vector(31 downto 0);
    signal color : unsigned(23 downto 0);
    signal toggle : unsigned(6 downto 0) := "0000000";
    signal s_rst : std_logic;

begin
    	
        
        u0 : component probes
        port map (
            source => source, -- sources.source
            probe  => probe   --  probes.probe
        );
    	
    	pll_inst: entity work.pll
    	    port map(
    	        inclk0 => MAX10_CLK1_50,
    	        c0 => clk20M,
    	        c1 => clk800K0,
				c2 => clk800K1
    	    );
	   
	   -- Instancia de driver_WS2812 com nome dut
	   dut: entity work.driver_WS2812pll
	       generic map(
	       MY_CHIPSELECT   => "10",
           MY_WORD_ADDRESS => x"10"
	       )
	       port map(
			   clk  => clk20M,
	           clk0 => clk800K0,
	           clk1 => clk800K1,
	           rst => s_rst,
	           data_in => data_in,
	           data_out => data_out
	       );
        
	      -- data_in <= x"0000FF";
	      data_in <= unsigned(source(23 downto 0));
		  s_rst <= (source(24));
		  probe(0) <= data_out;
		  ARDUINO_IO(3) <= data_out;
			
		  
end;

