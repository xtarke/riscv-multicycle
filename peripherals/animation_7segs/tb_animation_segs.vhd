library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_animation_segs is
end entity;

architecture sim of tb_animation_segs is

    signal clk       : std_logic := '0';
    signal rst       : std_logic := '0';
    signal direction : std_logic := '0';
    signal speed     : std_logic_vector(1 downto 0) := "11";
    signal segs      : std_logic_vector(7 downto 0);

begin

    -- Instanciação do DUT
    uut : entity work.animation_segs
        port map (
            clk       => clk,
            rst       => rst,
            direction => direction,
            speed     => speed,
            segs      => segs
        );

    -- Geração de clock
    clk_process : process
    begin
            clk <= '1';
            wait for 500 ns;
            clk <= '0';
            wait for 500 ns;
    end process;

    
    reset_inst : process
    begin
        -- Reset inicial
        rst <= '1';
        wait for 1 ms;
        rst <= '0';
        wait;
    end process;

    direction_inst: process
    begin
        speed <= "11";
        -- Direção direta
        direction <= '1';
        wait for 14 ms;

        -- Inverte direção
        direction <= '0';
        wait for 14 ms;
    end process;

end architecture;
