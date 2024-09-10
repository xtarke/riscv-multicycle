-------------------------------------------------------------------
-- name        : seven_segment_cntrl.vhd
-- author      : Stanislau de Lira Kaszubowski
-- data        : 02/04/2024
-- copyright   : Instituto Federal de Santa Catarina
-- description : Traduz uma entrada de 4 bits para o acionamento de um display de 7 segmentos.
------------------------------------------------------------------- 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seven_segment_cntrl is
    port (
        input: in unsigned (4-1 downto 0);
        segs : out std_logic_vector (7 downto 0)
    );
end entity seven_segment_cntrl;

architecture rtl of seven_segment_cntrl is
begin

   process (input)
   begin
       case input is
        when "0000" =>
            segs <= "11000000"; --0
        when "0001" =>
            segs <= "11111001"; --1
        when "0010" =>
            segs <= "10100100"; --2
        when "0011" =>
            segs <= "10110000"; --3
        when "0100" =>
            segs <= "10011001"; --4
        when "0101" =>
            segs <= "10010010"; --5
        when "0110" =>
            segs <= "10000010"; --6
        when "0111" =>
            segs <= "11111000"; --7
        when "1000" =>
            segs <= "10000000"; --8
        when "1001" =>
            segs <= "10010000"; --9
        when "1010" =>
            segs <= "10001000"; -- A 
        when "1011" =>
            segs <= "10000011"; -- b
        when "1100" =>
            segs <= "11000110"; -- C
        when "1101" =>
            segs <= "10100001"; -- d
        when "1110" =>
            segs <= "10000110"; -- E
        when "1111" =>
            segs <= "10001110"; -- F
        when others =>
            segs <= "00000000"; -- Default (off)
        end case;
    end process;

end architecture rtl;