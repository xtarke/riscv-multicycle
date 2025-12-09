-------------------------------------------------------------------
-- Name        : rng_tb.vhd
-- Author      : Elisa Anes Romero
-- Version     : 0.2
-- Description : Testbench do módulo RNG somente leitura (LFSR)
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end entity;

architecture stimulus of testbench is

    -------------------------------------------------------------------
    -- Constantes
    -------------------------------------------------------------------
    constant CLK_PERIOD : time := 10 ns;
    constant RUN_TIME   : time := 500 ns;
    constant N_CYCLES   : integer := RUN_TIME / CLK_PERIOD;

    -------------------------------------------------------------------
    -- Sinais do testbench
    -------------------------------------------------------------------
    signal clk_tb         : std_logic := '0';
    signal rst_tb         : std_logic := '0';
    signal chip_select_tb : std_logic := '0';
    signal addr_tb        : std_logic_vector(1 downto 0) := "00";
    signal read_data_tb   : std_logic_vector(31 downto 0);

begin

    -------------------------------------------------------------------
    -- Instância do DUT
    -------------------------------------------------------------------
    dut_rng : entity work.rng
        port map(
            clk         => clk_tb,
            rst         => rst_tb,
            chip_select => chip_select_tb,
            addr        => addr_tb,
            read_data   => read_data_tb
        );

    -------------------------------------------------------------------
    -- Geração do clock
    -------------------------------------------------------------------
    clk_process : process
    begin
        for i in 0 to N_CYCLES loop
            clk_tb <= '0';
            wait for CLK_PERIOD/2;
            clk_tb <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;


    -------------------------------------------------------------------
    -- Estímulos principais
    -------------------------------------------------------------------
    stim_proc : process
    begin
        ----------------------------------------------------------------
        -- RESET
        ----------------------------------------------------------------
        rst_tb <= '1';
        chip_select_tb <= '0';
        wait for 30 ns;

        rst_tb <= '0';
        chip_select_tb <= '1';
        wait for 20 ns;

        ----------------------------------------------------------------
        -- Ler vários valores do RNG (LFSR rodando)
        ----------------------------------------------------------------
        addr_tb <= "00";  -- sempre lendo RNG_VALUE

        for i in 0 to 10 loop
            wait for 20 ns;
        end loop;

        ----------------------------------------------------------------
        -- Finaliza simulação
        ----------------------------------------------------------------
        chip_select_tb <= '0';
        wait;
    end process;

end architecture stimulus;
