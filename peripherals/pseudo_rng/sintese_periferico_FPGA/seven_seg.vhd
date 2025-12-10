-------------------------------------------------------------------
-- Name        : seven_seg.vhd
-- Author      : Elisa Anes Romero 
-- Created     : 21/09/2025
-- Description : Esta eh a entidade do decodificador case 7 seg em VHDL.
-------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- a, b, c, d, e, f, g, ponto
-- ponto g, f,e,d,c,b,a
-- low - active anodo comum
entity seven_seg is
    port(
        signal input : in std_logic_vector(3 downto 0);
        signal output : out std_logic_vector(7 downto 0)
    );
end entity seven_seg;

architecture behavior of seven_seg is
begin
process (input)
    -- passar tudo pra hexa mais facil
    -- trocar 1 por zero pq é catodo comum
    begin
        case input is
            when x"0" => output <= "11000000"; -- 0
            when x"1" => output <= "11111001"; -- 1
            when x"2" => output <= "10100100"; -- 2
            when x"3" => output <= "10110000"; -- 3
            when x"4" => output <= "10011001"; -- 4
            when x"5" => output <= "10010010"; -- 5
            when x"6" => output <= "00000010"; -- 6
            when x"7" => output <= "11111000"; -- 7
            when x"8" => output <= "10000000"; -- 8
            when x"9" => output <= "00010000"; -- 9
            when x"A" => output <= "10001000"; -- A
            when x"B" => output <= "10000011"; -- B
            when x"C" => output <= "11000110"; -- C
            when x"D" => output <= "10100001"; -- D
            when x"E" => output <= "10000110"; -- E
            when x"F" => output <= "10001110"; -- F
            when others => output <= "11111111";

        end case;
        
    end process;   
    
end architecture behavior;

