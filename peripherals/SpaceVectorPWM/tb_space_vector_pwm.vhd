-------------------------------------------------------
-- Testbench  : tb_space_vector_pwm
-- Autor      : Eduardo Francisco Pereira
-- Data       : 16/06/2026
-- Descrição  : Arquivo de simulação para validar a 
--              máquina de estados e a geração de PWM.
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_space_vector_pwm is
    -- Testbench não possui portas
end entity tb_space_vector_pwm;

architecture sim of tb_space_vector_pwm is

    -- Sinais para conectar ao componente
    signal clk_tb   : std_logic := '0';
    signal reset_tb : std_logic := '1';
    
    -- Sinais de entrada do DUT (Device Under Test)
    signal v_bar_tb : unsigned(15 downto 0) := to_unsigned(100, 16);
    signal u_cmd_tb : signed(15 downto 0)   := to_signed(0, 16);
    
    -- Sinais de saída do DUT
    signal g_s1_tb  : std_logic;
    signal g_s2_tb  : std_logic;
    signal g_s3_tb  : std_logic;
    signal g_s4_tb  : std_logic;

    -- Configuração do Clock (50 MHz -> T = 20 ns)
    constant CLK_PERIOD : time := 20 ns;

begin

    -- Instância do Componente (DUT)
    DUT: entity work.space_vector_pwm
        generic map (
            INPUT_CLK_FREQ  => 50000000,
            F_SW            => 10000,
            DEADTIME_CYCLES => 50
        )
        port map (
            clock   => clk_tb,
            reset   => reset_tb,
            v_bar   => v_bar_tb,
            u_cmd   => u_cmd_tb,
            gate_s1 => g_s1_tb,
            gate_s2 => g_s2_tb,
            gate_s3 => g_s3_tb,
            gate_s4 => g_s4_tb
        );

    -- Processo Gerador de Clock
    clk_process: process
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD / 2;
        clk_tb <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Processo de Estímulos (Geração dos sinais de teste)
    stimulus_process: process
    begin
        -- 1. Inicialização e Reset
        reset_tb <= '1';
        wait for 100 ns;
        reset_tb <= '0';
        wait for 100 ns;

        -- 2. Teste de Tensão Positiva (u_cmd > 0)
        -- A máquina deve seguir o caminho esquerdo do seu fluxograma (S1_S4_ON)
        v_bar_tb <= to_unsigned(100, 16);
        u_cmd_tb <= to_signed(60, 16); -- Duty cycle focado no lado positivo
        -- Aguarda 2 períodos completos de comutação (10 kHz = 100 us por período)
        wait for 200 us; 

        -- 3. Teste de Tensão Negativa (u_cmd < 0)
        -- A máquina deve seguir o caminho direito do seu fluxograma (S2_S3_ON)
        u_cmd_tb <= to_signed(-40, 16);
        wait for 200 us;

        -- 4. Teste de Tensão Nula (u_cmd = 0)
        -- O delta_t1 deve zerar, maximizando os tempos dos vetores nulos (V0 e V3)
        u_cmd_tb <= to_signed(0, 16);
        wait for 200 us;
        
        -- 5. Teste de Tensão Máxima Positiva
        u_cmd_tb <= to_signed(100, 16);
        wait for 200 us;


        wait;
    end process;

end architecture sim;