library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end entity testbench;

architecture rtl of testbench is
    
    signal clk_tb : std_logic; 
    signal rst_tb : std_logic;
    signal pwm_tb : std_logic;  

begin
    
    pwm_inst : entity work.pwm
        port map(
            clk  => clk_tb,
            rst  => rst_tb,
            pwm => pwm_tb
        );   

    process is
    begin
        clk_tb <= '0';
        wait for   500 ns;
        clk_tb <= '1';
        wait for 500 ns;   
    end process;

    process is
    begin
        rst_tb <= '1';
        wait for  2 ns;
        rst_tb <= '0';  
        wait for 40000000 ns;   

    end process;


end architecture rtl;