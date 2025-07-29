-----------------------------------------------------------------------------------------------
-- Name        : encoder.vhd
-- Author      : Greicili dos Santos Ferreira
-- Version     : 0.1
-- Description : Bloco para obter velocidade do encoder e apresentá-la em 4 displays 7-seg
-- sendo 3 display para o valor e 1 para o sentido de rotação 
-----------------------------------------------------------------------------------------------
-- Bibliotecas e clásulas
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Biblioteca pessoal para conversão do código para o display 7seg
use work.my_package.all;

-- Entidade e portas
entity encoder is
    port(
        clk    : in  std_logic;         -- Clock de 10Hz que serve como Timmer
        aclr_n : in  std_logic;         -- Sinal para reset do bloco
        A      : in  std_logic;         -- Sinal do encoder para a contagem dos pulsos
        B      : in  std_logic;         -- Sinal do encoder para verificar o sentido de rotação
        segs_a : out std_logic_vector(7 downto 0); -- Apresenta a velocidade bits[3  0]
        segs_b : out std_logic_vector(7 downto 0); -- Apresenta a velocidade bits[7  4]
        segs_c : out std_logic_vector(7 downto 0); -- Apresenta a velocidade bits[11 8]
        segs_d : out std_logic_vector(7 downto 0); -- Apresenta a velocidade bits[15 12]
        segs_e : out std_logic_vector(7 downto 0) := (others => '1') -- Apresenta a sentido de rotação: Apagado (horário) | Sinal negativo (anti-horário)
    );
end entity encoder;

-- Arquitetura
architecture rtl of encoder is
    signal pulse_count : unsigned(11 downto 0)  := (others => '0'); -- Contagem dos pulso de A
    signal flag        : std_logic             := '0'; -- Sinal para informar o quando ocorre a borda de subida do clk (timmer): disponibiliza a velocidade e reinicia contagem
    signal velocidade  : unsigned(15 downto 0) := (others => '0'); -- Sinal para obter a velocidade
    signal flag_B      : std_logic             := '0'; -- Sinal para informar que o motor mudou de sentido

begin
    -- Informar o "estouro" do timmer
    process(aclr_n, clk, flag)
    begin
        if aclr_n = '0' then
            flag <= '0';
        elsif flag = '1' then
            flag <= '0';                -- Reseta a flag para reiniciar a contagem
        elsif rising_edge(clk) then
            flag <= '1';
        end if;
    end process;

    -- Contagem dos pulsos do encoder
    process(aclr_n, A, flag)
        variable var_count : unsigned(11 downto 0) := (others => '0');
    begin
        if aclr_n = '0' then
            var_count := (others => '0');
        elsif flag = '1' then
            var_count := (others => '0');
        elsif rising_edge(A) then
            var_count := var_count + 1;
            if flag_B = '1' then
                var_count := (others => '0');
            end if;
        end if;
        pulse_count <= var_count;
    end process;

    -- Checa B: se B mudou de valor, indica mudança no sentido de rotação e o motor diminuiu a velocidade
    process(A) is
        variable B_anterior : std_logic := '0';
    begin
        if rising_edge(A) then
            if B_anterior /= B then
                flag_B <= '1';
            else
                flag_B <= '0';
            end if;
            B_anterior := B;
        end if;
    end process;

    -- Obtendo a velocidade
    process(aclr_n, flag, pulse_count)
        -- O PPR (pulsos por rotação) do encoder é 412.
        -- Cálculo da velocidade -> RPM = contagem_pulsos * frequência_timmer * 60 /PPR
        -- O uso da operação de divisão em VHDL não é recomendada, portanto, o resultado da operação com as constantes será armazenado na constante 'multiplicador'. 
        -- frequência_timmer *60 / PPR = 1,46
        -- Esse valor será multiplicador por 10 ->  multiplicador = 14
        -- Deste modo, a velocidade terá um dígito a mais de precisão 
        constant multiplicador  : unsigned(3 downto 0)  := to_unsigned(14, 4); -- 10Hz (período de 100ms, referente ao clk) * 60/412 = pulsos por minuto
        variable var_velocidade : unsigned(15 downto 0) := (others => '0');
    begin
        if aclr_n = '0' then
            var_velocidade := (others => '0');
        elsif flag = '1' then
            var_velocidade := pulse_count * multiplicador;
        end if;
        velocidade <= var_velocidade;
    end process;

    -- Apresenta nos displays:
    segs_a <= conversion_bin_to_7seg(velocidade(3 downto 0));
    segs_b <= conversion_bin_to_7seg(velocidade(7 downto 4));
    segs_c <= conversion_bin_to_7seg(velocidade(11 downto 8));
    segs_d <= conversion_bin_to_7seg(velocidade(15 downto 12));

    Direction : process(A) is
    begin
        if rising_edge(A) then
            if B = '0' then
                segs_e <= "11111111";   -- Sentido horário
            else
                segs_e <= "10111111";   -- Sentido anti-horário
            end if;
        end if;

    end process direction;

end architecture rtl;
