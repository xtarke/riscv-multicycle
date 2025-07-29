-------------------------------------------------------------------
-- name        : testbench.vhd
-- author      : Greicili dos Santos Ferreira
-- description : Testbench do bloco encoder
-- date        : 24/07/2025
-------------------------------------------------------------------

-- bibliotecas e clásulas
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-------------------------------------
entity testbench is
end entity testbench;
------------------------------

architecture stimulus of testbench is
    signal clk_1MHz : std_logic;       -- Clock de 10kHz gerado no Quartus com o PLL
    signal clk_tb    : std_logic;
    signal aclr_n_tb : std_logic;
    signal A_tb      : std_logic;
    signal B_tb      : std_logic;
    signal segs_a_tb : std_logic_vector(7 downto 0);
    signal segs_b_tb : std_logic_vector(7 downto 0);
    signal segs_c_tb : std_logic_vector(7 downto 0);
    signal segs_d_tb : std_logic_vector(7 downto 0);
    signal segs_e_tb : std_logic_vector(7 downto 0);

begin

    -- instância do encoder incremental
    encoder_inst : entity work.encoder
        port map(
            clk    => clk_tb,
            aclr_n => aclr_n_tb,
            A      => A_tb,
            B      => B_tb,
            segs_a => segs_a_tb,
            segs_b => segs_b_tb,
            segs_c => segs_c_tb,
            segs_d => segs_d_tb,
            segs_e => segs_e_tb
        );

    -- Instância para dividir o clock de 1MHz para 10Hz (fornece o período de 100ms para a contagem dos pulsos)
    divisor_clock_inst : entity work.divisor_clock
        generic map(
            max => 50000
        )
        port map(
            clk    => clk_1MHz,
            output => clk_tb
        );

    -- Instância para gerar o sinal de A (de 1MHz para 1kHz) para validação na placa
    clock_A_inst : entity work.divisor_clock
        generic map(
            max => 500
        )
        port map(
            clk    => clk_1MHz,
            output => A_tb
        );

    --! Processo para criar sinal de clock que virá do Quartus
    clock_in : process
    begin
        clk_1MHz <= '0';
        wait for 500 ns;
        clk_1MHz <= '1';
        wait for 500 ns;
    end process clock_in;

    --! Processo para criar sinal de reset
    reset : process
    begin
        aclr_n_tb <= '0';
        wait for 3 ms;
        aclr_n_tb <= '1';
        wait;
    end process reset;

    ---! Processo para criar sinal B:
    -- **Se B estiver em 0 na borda de A, rotação no sentido horário
    -- **Se B estiver em 1 na borda de A, rotação no sentido anti-horário
    B_signal : process
        variable initial : std_logic := '0';

    begin
        if initial = '0' then
            B_tb    <= '1';
            wait for 0.25 ms;
            initial := '1';
        end if;

        B_tb <= '0';
        wait for 0.5 ms;
        B_tb <= '1';
        wait for 0.5 ms;
    end process B_signal;

end architecture stimulus;
