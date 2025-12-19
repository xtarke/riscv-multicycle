---------------------------------------------------------------------------------------------------
-- Name        : pwm_bldc_tester.vhd
-- Author      : João Pedro de Araújo Duarte
-- Created     : 01/12/2025
-- Description : 
-- O código descreve um periférico de teste para motor.
-- Gera um sinal PWM fixo de 50 Hz com ciclo de trabalho ajustável e de período de 2 ms.
-- A aceleração e desaceleração do motor são controladas pelo ajuste do ciclo de trabalho do PWM. 1000 a 2000.
-- Sendo 1000 o valor mínimo (motor parado) e 2000 o valor máximo (motor na velocidade máxima).
-- Além disso, é implementado um sinal de motor_emergency_stop que quando ativado, joga o sinal do motor para GND
-- desligando rapidamente o motor.
--------------------------------------------------------------------------------------------------

-- Bibliotecas utilizadas e clásulas
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_bldc_tester is
    generic (
        PERIOD : unsigned(19 downto 0) := to_unsigned(1000000, 20)  -- Período de 1.000.000 ciclos de clock (1 MHz → 1 s)
    );
    
    port(
        clk        : in  std_logic;         
        stop       : in  std_logic;
        duty_cycle : in  unsigned(19 downto 0); -- 1000..2000
        pwm_out    : out std_logic
      
    );
end entity;

architecture rtl of pwm_bldc_tester is

    signal count       : unsigned(19 downto 0) := (others => '0');
    signal pulse_width : unsigned(19 downto 0);

begin
    process(clk, stop)
    begin
 
        if stop = '1' then
            pwm_out <= '0';
            count <= (others => '0');

        elsif rising_edge(clk) then

            -- conversão segura de 1000..2000 → 50000..100000
            pulse_width <= to_unsigned(50 * to_integer(duty_cycle), 20);

            if duty_cycle < 1000 then
                pulse_width <= to_unsigned(50000, 20);
            elsif duty_cycle > 2000 then
                pulse_width <= to_unsigned(100000, 20);
            end if;

            -- contador de 0 até PERIOD (=1.000.000)
            if count = PERIOD then
                count <= (others => '0');
            else
                count <= count + 1;
            end if;

            

            -- geração do PWM
            if count < pulse_width then
                pwm_out <= '1';
            else
                pwm_out <= '0';
            end if;

        end if;
    end process;

end architecture;
