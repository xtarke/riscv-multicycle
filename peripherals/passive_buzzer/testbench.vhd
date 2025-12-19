--------------------------------------------------------------------------------
-- Arquivo: testbench.vhd
-- Author: Sarah Bararua
-- Descrição: Gerador de música com seletor (Imperial March & Jingle Bells)
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity buzzer_tb is
end entity buzzer_tb;

architecture sim of buzzer_tb is
    signal clk_tb         : std_logic := '0';
    signal sw_imperial_tb : std_logic := '0';
    signal sw_jingle_tb   : std_logic := '0';
    signal wave_out_tb    : std_logic;
    constant CLK_PERIOD : time := 20 ns; -- 50MHz
begin

    -- Instancia o buzzer
    dut : entity work.buzzer
        generic map ( CLK_FREQ => 50_000_000 )
        port map (
            clk         => clk_tb,
            sw_imperial => sw_imperial_tb,
            sw_jingle   => sw_jingle_tb,
            wave_out    => wave_out_tb
        );

    -- Clock
    process begin
        while true loop
            clk_tb <= '0'; wait for CLK_PERIOD / 2;
            clk_tb <= '1'; wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Teste
    process begin
        -- 1. Início
        sw_imperial_tb <= '0';
        sw_jingle_tb   <= '0';
        wait for 100 us;

        -- 2. Tocar Imperial 
        sw_imperial_tb <= '1';
        wait for 40 ms; 
        
        sw_imperial_tb <= '0';
        wait for 1 ms;

        -- 3. Tocar Jingle Bells
        sw_jingle_tb <= '1';
        wait for 35 ms;

        sw_jingle_tb <= '0';
        wait;
    end process;
end architecture sim;