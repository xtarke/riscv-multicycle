library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench_max7219cn is
end entity testbench_max7219cn;

architecture RTL of testbench_max7219cn is
    
signal clk       : std_logic;
signal rst       : std_logic;
signal data      : std_logic_vector(7 downto 0);
signal modo      : std_logic_vector(7 downto 0);
signal din       : std_logic;
signal clk_out   : std_logic;
signal cs        : std_logic;
signal program   : std_logic;
signal dado_bruto: std_logic_vector(15 downto 0) := "0000000100000001";

begin

    max7219cn_inst : entity work.max7219cn
        port map(
            clk     => clk,
            rst     => rst,
            data    => data,
            modo    => modo,
            program => program,
            din     => din,
            clk_out => clk_out,
            cs      => cs
        );

    clk_process: process is
    begin
        clk <= '1';
        wait for 1 ns;
        clk <= '0';
        wait for 1 ns;
    end process clk_process;
    
    enviar_dado: process is
    begin
        data <= dado_bruto(7 downto 0);
        modo <= dado_bruto(15 downto 8);
        rst <= '0';
        program <= '0';
        wait for 35 ns;
        program <= '1';
        wait for 35 ns;
        --rst <= '1';
        wait for 3 ns;
        program <= '0';

        wait for 100 ns;
        modo <= X"22";
        --rst <= '1';
        wait for 7 ns;
        program <= '1';
        wait for 3 ns;
        program <= '0';
        
        wait for 100 ns;

    end process enviar_dado;


end architecture RTL;
