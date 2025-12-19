---------------------------------------------------------------------------------------------------
-- Name        : motor_test_bldc.vhd
-- Author      : João Pedro de Araújo Duarte
-- Created     : 18/12/2025
-- Description :
-- O código descreve um periférico de teste para motor BLDC controlado por ESC com foco na aplicação em UAV's.
-- É gerado um sinal de controle do tipo RC (servo), com período fixo de 20 ms
-- (frequência de 50 Hz) e largura de pulso ajustável entre 1000 µs e 2000 µs.
--
-- A largura de pulso de 1000 µs representa o comando mínimo (motor parado),
-- enquanto 2000 µs representa o comando máximo (motor em rotação máxima).
--
-- A aceleração do motor é realizada automaticamente por
-- rampas de incremento da largura de pulso ao longo do tempo.
--
-- São definidos três modos de operação:
-- 1. Modo de teste com rampa de aceleração incremental de 1% do intervalo
--    total (1000 µs a 2000 µs) por segundo, até o valor máximo, seguido de parada.
-- 2. Modo de teste com rampa de aceleração incremental de 5% do intervalo
--    total por segundo, até o valor máximo, seguido de parada.
-- 3. Modo de teste com rampa de aceleração incremental de 10% do intervalo
--    total por segundo, até o valor máximo, seguido de parada.
--
-- Durante todos os modos de operação, é monitorado um sinal de entrada que
-- representa a relação grama-força referente à força de empuxo gerada pelo motor.
--
-- Em todos os modos, após o comando atingir pelo menos 10% do intervalo total
-- de controle, caso o valor do sinal referente ao "peso" seja zerado em qualquer momento, o motor
-- é imediatamente desligado e o sistema entra em estado de falha.
--
-- Adicionalmente, é implementado um sinal de segurança denominado
-- motor_emergency_stop que, quando ativado, força a saída de controle do motor
-- para nível lógico baixo (GND), promovendo o desligamento imediato do motor.

--------------------------------------------------------------------------------------------------


-- Bibliotecas utilizadas e clásulas
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity motor_test_bldc is
    generic (
        PERIOD_SEC : unsigned(27 downto 0) := to_unsigned(50000000, 28)  -- Período de 50.000.000 ciclos de clock (50 MHz → 1 s)
    );
    
    port(
        clk        : in  std_logic; 
        mode       : in std_logic_vector(2 downto 0); 
        enter      : in  std_logic;      
        motor_emergency_stop       : in  std_logic;
        weight     : in  unsigned(19 downto 0); -- 1000..2000
        pwm_out    : out std_logic;
        fault      : out std_logic;
        segs0     : out std_logic_vector(7 downto 0) := (others => '1');
        segs1     : out std_logic_vector(7 downto 0) := (others => '1');
        segs2     : out std_logic_vector(7 downto 0) := (others => '1');
        segs3     : out std_logic_vector(7 downto 0) := (others => '1');
        segs4     : out std_logic_vector(7 downto 0) := (others => '1');
        segs5     : out std_logic_vector(7 downto 0) := (others => '1')    
    );
end entity;




architecture rtl of motor_test_bldc is
    type state_type is (IDLE, MODE_ST, A_1, A_5, A_10, SUCESS, FAIL);
    signal state : state_type := IDLE;  
    signal duty_comando  : unsigned(19 downto 0); 
    signal sec_counter  : unsigned(27 downto 0) := (others => '0');
    signal one_sec_tick : std_logic := '0';
    signal stop_int : std_logic;
    signal fault_i : std_logic := '0';



begin


    pwm_inst : entity work.pwm_bldc_tester -- Instancia o módulo PWM anteriormente já implementada
    port map (
        clk        => clk,
        stop       => stop_int,
        duty_cycle => duty_comando,
        pwm_out    => pwm_out
    );

    stop_int <= motor_emergency_stop or fault_i;

    process(clk) -- Processo para gerar o pulso de 1 segundo
    begin
        if rising_edge(clk) then
            if sec_counter = PERIOD_SEC - 1 then
                sec_counter  <= (others => '0');
                one_sec_tick <= '1';
            else
                sec_counter  <= sec_counter + 1;
                one_sec_tick <= '0';
            end if;
        end if;
    end process;




    process(clk) -- Máquina de estados (FSM) para o controle do motor BLDC
    begin
        if rising_edge(clk) then

           fault_i  <= '0';
            if motor_emergency_stop = '1' then
                state         <= IDLE;
                segs0     <= (others => '1');
                segs1     <= (others => '1');
                segs2     <= (others => '1');
                segs3     <= (others => '1');
                segs4     <= (others => '1');
                segs5     <= (others => '1');    
                duty_comando  <= to_unsigned(1000, 20);
            else
                case state is
                    when IDLE =>
                        duty_comando <= to_unsigned(1000,20);
                        state <= MODE_ST;               
                    when MODE_ST =>
                        
                        if mode = "001" and enter = '1' then
                            state <= A_1;
                        elsif mode = "010" and enter = '1' then
                            state <= A_5;
                        elsif mode = "011" and enter = '1' then
                            state <= A_10;
                        else
                            state <= MODE_ST;
                        end if;
                    when A_1 =>
                        if one_sec_tick = '1' then
                                duty_comando <= duty_comando + 10;
                            end if;
                        if duty_comando >= to_unsigned(2000,20) then
                            state <= SUCESS;
                        elsif duty_comando >= to_unsigned(1100,20) and weight = to_unsigned(0,20) then
                            state <= FAIL;
                        end if;
                    when A_5 =>
                        if one_sec_tick = '1' then
                                duty_comando <= duty_comando + 50;
                            end if;
                        if duty_comando >= to_unsigned(2000,20) then
                            state <= SUCESS;
                        elsif duty_comando >= to_unsigned(1100,20) and weight = to_unsigned(0,20) then
                            state <= FAIL;
                        end if;
                    when A_10 =>
                        if one_sec_tick = '1' then
                                duty_comando <= duty_comando + 100;
                            end if;
                        if duty_comando >= to_unsigned(2000,20) then
                            state <= SUCESS;
                        elsif duty_comando >= to_unsigned(1100,20) and weight = to_unsigned(0,20) then
                            state <= FAIL;
                        end if;
                        
                    when SUCESS =>
                        state <= IDLE;
                    when FAIL =>
                        fault_i  <= '1';
                        duty_comando <= to_unsigned(1000,20);
                        if motor_emergency_stop = '1' then
                            state <= IDLE;
                        else
                            state <= FAIL;
                            segs0   <= "11111111"; -- off
                            segs1   <= "11000111"; -- L
                            segs2   <= "11111001"; -- I
                            segs3   <= "10001000"; -- A
                            segs4   <= "10001110"; -- F
                            segs5   <= "11111111"; -- off
                        end if;
                end case;
            end if;
        end if;
    end process;
fault <= fault_i;
end architecture rtl;