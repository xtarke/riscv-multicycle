library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_animation_segs is
end entity;

architecture sim of tb_animation_segs is

    signal clk       : std_logic := '0';
    signal rst       : std_logic := '0';
    signal direction : std_logic := '1';
    signal segs      : unsigned(7 downto 0);

begin

    -- Instanciação do DUT
    uut : entity work.animation_segs
        port map (
            clk       => clk,
            rst       => rst,
            direction => direction,
            segs      => segs
        );

    -- Geração de clock
    clk_process : process
    begin
            clk <= '1';
            wait for 500 us;
            clk <= '0';
            wait for 500 us;
    end process;

    -- Estímulos
    stim_proc : process
    begin
        -- Reset inicial
        rst <= '1';
        wait for 1 ms;
        rst <= '0';
        wait;
    end process;

    process
    begin
        -- Direção direta
        direction <= '1';
        wait for 14 ms;

        -- Inverte direção
        direction <= '0';
        wait for 14 ms;
    end process;

end architecture;
