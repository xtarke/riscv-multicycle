library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench_controlador is
end entity testbench_controlador;

architecture RTL of testbench_controlador is
	signal clk_tb : std_logic;
	signal reset_tb : std_logic;
	signal start_tb : std_logic;
    signal restart_tb : std_logic;
	signal din_tb : std_logic_vector (23 downto 0);
	signal dout_tb : std_logic;

begin

    controlador_RGB: entity work.controlador
        port map(
            clk   => clk_tb,
            reset => reset_tb,
            start => start_tb,
            restart => restart_tb,
            din   => din_tb,
            dout  => dout_tb
        );


    process
    begin
        clk_tb <= '0';
        wait for 10 ns;
        clk_tb <= '1';
        wait for 10 ns; 
    end process;

    process
    begin
        start_tb <= '0';
        wait for 200 ns; 
        start_tb <= '1';
        wait for 40000 ns;
        start_tb <= '0';
        wait for 40000 ns;
    end process;

    process
    begin
        reset_tb <= '1';
        wait for 10 ns;
        reset_tb <= '0';
        wait for 60000 ns;
    end process;

    process
    begin
        din_tb <= x"0000FF";  -- Azul
        wait for 100 ns;
    end process;



end architecture RTL;