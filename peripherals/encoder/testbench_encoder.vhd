-------------------------------------------------------------------
-- name        : testbench_counter.vhd
-- author      : Stanislau de Lira Kaszubowski
-- data        : 02/04/2024
-- copyright   : Instituto Federal de Santa Catarina
-- description : Realiza o testbench de counter.vhd
------------------------------------------------------------------- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench_encoder is

end entity testbench_encoder;

architecture RTL of testbench_encoder is
    signal  clk_tb: std_logic;
    signal  encoder_pulse_tb: std_logic;
    signal  aclr_n_tb: std_logic;
    signal  frequency_tb: unsigned (31 downto 0);
    signal  select_time_tb: std_logic_vector (2 downto 0)
;
    
begin
    
encoder_inst : entity work.encoder
    port map(
        clk           => clk_tb,
        aclr_n        => aclr_n_tb,
        select_time   => select_time_tb,
        encoder_pulse => encoder_pulse_tb,
        frequency     => frequency_tb
    );


        clock_driver : process
        constant period : time := 20 ns;  --50mhz
    begin
        clk_tb <= '0';
        wait for period / 2;
        clk_tb <= '1';
        wait for period / 2;
    end process clock_driver;
    
        encoder_driver : process
        constant period : time := 40 ns;  --25mhz
    begin
        encoder_pulse_tb <= '0';
        wait for period / 2;
        encoder_pulse_tb <= '1';
        wait for period / 2;
    end process encoder_driver;
    
    

    select_time_tb<= "000"; --1ms
    aclr_n_tb<= '1', '0'after 35 ns, '1' after 100 ns, '0'after 400000 ns, '1'after 500000 ns;

    
end architecture RTL;