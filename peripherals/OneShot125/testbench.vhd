-- ============================================================================
-- ARQUIVO: testbench.vhd
-- DESCRIÇÃO: Testbench para verificação funcional do módulo OneShot125.
--            O código gera os sinais de clock e reset, aplica diferentes
--            valores de comando e permite observar o comportamento do
--            PWM gerado e a conversão do comando para exibição em
--            displays de sete segmentos.
-- ============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_oneshot125 is
end tb_oneshot125;

architecture behavior of tb_oneshot125 is
    signal clk_tb           : std_logic := '0';
    signal rst_tb           : std_logic := '0';
    signal comando_tb       : unsigned(19 downto 0);
    signal pwm_saida_tb     : std_logic;
    signal valor_display_tb : unsigned(11 downto 0);
    -- Sinais para conectar nos displays
    signal hex0_tb, hex1_tb, hex2_tb, hex3_tb : std_logic_vector(6 downto 0);

begin
    -- Conecta ao design principal
    dut : entity work.oneshot125
        port map (
            clk           => clk_tb,
            rst           => rst_tb,
            comando       => comando_tb,
            pwm_saida     => pwm_saida_tb,
            valor_display => valor_display_tb,
            HEX0 => hex0_tb, HEX1 => hex1_tb, HEX2 => hex2_tb, HEX3 => hex3_tb
        );

    -- Clock 50 MHz
    clk_process : process
    begin
        while true loop
            clk_tb <= '0'; wait for 10 ns;
            clk_tb <= '1'; wait for 10 ns;
        end loop;
    end process;

    -- Teste
    stim_process : process
    begin
        comando_tb <= to_unsigned(1000, 20);
        wait for 2 ms;
        comando_tb <= to_unsigned(1500, 20);
        wait for 2 ms;
        comando_tb <= to_unsigned(2000, 20);
        wait;
    end process;
end architecture;
