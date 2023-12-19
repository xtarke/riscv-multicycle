library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end entity testbench;

architecture RTL of testbench is -- sinais do testbench
    signal clk_tb: std_logic;
    signal rst_tb: std_logic;
    signal entrada_tb:integer;
    signal buzzer_tb: std_logic;
    signal ledt_tb : std_logic;
    signal led3t_tb : std_logic;
    signal ledf_tb : std_logic;
begin
    final: entity work.MorseCodeBuzzer -- relaciona os sinais do testbench com as entradas e saídas do arq. principal
        port map(
            clk    => clk_tb,
            rst    => rst_tb,
            entrada => entrada_tb,
            ledt => ledt_tb,
            led3t => led3t_tb,
            ledf => ledf_tb,
            buzzer => buzzer_tb
        );
        process
    begin-- faz o processo do clock 1 nseg em cada nivel logico
        clk_tb <= '0';
        wait for 1 ns;
        clk_tb <= '1';
        wait for 1 ns;
    end process;

    process
    begin
        rst_tb<= '1';-- reset
        wait for 1 ns;
        rst_tb<= '0';
        wait for 20000 ns;
    end process;
    
        process
    begin
        entrada_tb<= 4;     --entra valor de 4
        wait for 500 ns;
        entrada_tb<= 1;     --entra valor de 1
        wait for 500 ns;
        entrada_tb<= 2;     --entra valor de 2
        wait for 500 ns;
        entrada_tb<= 3;     --entra valor de 3
        wait for 500 ns;
        entrada_tb<= 4;     --entra valor de 4
        wait for 500 ns;
        entrada_tb<= 5;     --entra valor de 5
        wait for 500 ns;
        entrada_tb<= 6;     --entra valor de 6
        wait for 500 ns;
        entrada_tb<= 7;     --entra valor de 7
        wait for 500 ns;
        entrada_tb<= 8;     --entra valor de 8
        wait for 500 ns;
        entrada_tb<= 9;     --entra valor de 9
        wait for 500 ns;
        
    end process;
end architecture RTL;
