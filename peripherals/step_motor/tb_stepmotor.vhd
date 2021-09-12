--! Bibliotecas !--
library ieee;                                       --! Biblioteca padrão
use ieee.std_logic_1164.all;                        --! Elementos lógicos
use ieee.numeric_std.all;                           --! Conversões entre tipos

entity tb_stepmotor is
end entity tb_stepmotor;


architecture RTL of tb_stepmotor is
    signal clk, reverse, rst, stop,ena : std_logic;
    signal half_full : std_logic;
    signal in1: std_logic;
    signal in2: std_logic;
    signal in3: std_logic;
    signal in4: std_logic;
    signal speed : unsigned(2 downto 0);
    signal outputs: std_logic_vector(3 downto 0); -- @suppress "signal outputs is never read"
begin
    outputs(0) <= in1; outputs(1) <= in2;
    outputs(2) <= in3; outputs(3) <= in4;
    
    motor0: entity work.stepmotor
        port map(
            clk       => clk,
            reverse   => reverse,
            rst       => rst,
            stop      => stop,
            ena       => ena,
            half_full => half_full,
            in1       => in1,
            in2       => in2,
            in3       => in3,
            in4       => in4,
            speed     => speed
        );

    clk0: process is
    begin
        clk <= '0';
        wait for 1 ms;
        clk <= '1';
        wait for 1 ms;
    end process clk0;

    en0: process is
    begin
        ena <= '0';
        wait for 6 ms;
        ena <= '1';
        wait;
    end process en0;

    speed0: process is
    begin
        rst <='0';
        stop <='0';
        speed <= to_unsigned(0, speed'length);
        wait for 140 ms;
        stop <= '1';
        wait for 10 ms;
        stop <= '0';
        rst <= '1';
        wait for 2 ms;
        rst <= '0';
                for i in 0 to 7 loop
            speed <= to_unsigned(i, speed'length);
            wait for 20 ms;
        end loop;
        wait;
    end process speed0;

    hf0: process is
    begin
        half_full <= '0';
        wait for 140 ms;
        half_full <= '1';
        wait for 140 ms;
        half_full <= '0';
        wait;        
    end process hf0;
    
    rev0: process is
    begin
        reverse <= '0';
        wait for 70 ms;
        reverse <= '1';
        wait for 140 ms;
        reverse <= '0';
        wait;
    end process rev0; 

end architecture RTL;