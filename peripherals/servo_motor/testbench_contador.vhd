library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
    generic(
        constant N : integer:=31
    );
end entity testbench;


architecture rtl of testbench is
    
    signal clk_tb : std_logic; 
    signal rst_tb : std_logic;
    signal cont_tb : unsigned(N downto 0);
      
    --signal test_tb : integer range 0 to 20000;
    
    

begin
    
    contador_inst : entity work.contador
        generic map(
            T => N
        )
        port map(
            clk  => clk_tb,
            rst  => rst_tb,
            cont => cont_tb
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