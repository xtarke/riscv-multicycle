-------------------------------------------------------------------
-- name        : testbench.vhd
-- author      : Luciano Caminha Junior
-- version     : 0.1
-- copyright   : Instituto Federal de Santa Catarina
-- description : Testbench para WS2812pll
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity testbenchpll is

end entity testbenchpll;

architecture RTL of testbenchpll is
    component driver_WS2812pll
        port(
            clk      : in  std_logic;
            clk0     : in  std_logic;
            clk1     : in  std_logic;
            rst      : in  std_logic;
            data_in  : in  unsigned(23 downto 0);
            data_out : out std_logic
        );
    end component driver_WS2812pll;

    -- declaracao de sinais
        signal clk: std_logic;
        signal clk0: std_logic;
        signal clk1: std_logic;
        signal rst: std_logic;
        signal data_in: unsigned(23 downto 0);
        signal data_out: std_logic;

begin
    -- Instancia de driver_WS2812 com nome dut
    dut: driver_WS2812pll port map (
            clk  => clk,
            clk0 => clk0,
            clk1 => clk1,
            rst => rst,
            data_in => data_in,
            data_out => data_out
        );

    -- Clock master em 20MHz
    clk_process: process
    begin
        clk <= '1';
        wait for 25 ns;
        clk <= '0';
        wait for 25 ns;
    end process;
    
    -- Clock para o bit 0 em 800KHz
    clk0_process: process
    begin
        clk0 <= '1';
        wait for 400 ns;
        clk0 <= '0';
        wait for 850 ns;
    end process;
    
    -- Clock para o bit 1 em 800KHz
    clk1_process: process
    begin
        clk1 <= '1';
        wait for 850 ns;
        clk1 <= '0';
        wait for 400 ns;
    end process;
    
    process
    begin
        rst <= '1';
        data_in <= "000000001111111101010101";
        wait for 50 ns;
        rst <= '0';
        wait for 500 us;
        data_in <= "000000000000000000000000";
        wait for 500 us; 
    end process; 

end architecture RTL;