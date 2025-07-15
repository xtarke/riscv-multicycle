-------------------------------------------------------------------
-- Name        : seven_segs.vhd
-- Author      : Joana Wasserberg
-- Version     : 0.1
-- Copyright   : Joana, Departamento de Eletrônica, Florianópolis, IFSC
-- Description : 
--              
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity animation_segs is
    port(
        clk : in std_logic;
        direction : in std_logic;
        rst : in std_logic;
        segs : out unsigned(7 downto 0)
    );
end entity animation_segs;

architecture RTL of animation_segs is
    signal output_sig : std_logic_vector(3 downto 0);
    
begin

    fsm_inst : entity work.fsm_animation_segs
    port map(
        direction => direction,
        rst       => rst,
        clk       => clk,
        output    => output_sig
    );

    seven_segs_inst : entity work.seven_segs
    port map(
        input => output_sig,
        segs => segs
    );

end architecture RTL;
