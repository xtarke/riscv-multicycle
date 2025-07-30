-------------------------------------------------------------------
-- Name        : seven_segs.vhd
-- Author      : Joana Wasserberg
-- Version     : 0.1
-- Copyright   : Joana, Departamento de Eletrônica, Florianópolis, IFSC
-- Description : Implementa um decodificador para display de 7 segmentos
--               do tipo ânodo comum. A ativação dos segmentos é feita
--               utilizando uma estrutura case baseada em um valor binário
--               de entrada com 4 bits.
--
-- Obs: Os segmentos seguem o padrão: dp g f e d c b a (bit 7 a 0)
--      Um bit em '0' ativa o segmento correspondente (ânodo comum).
-------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seven_segs is
    port(
        input : in  std_logic_vector(3 downto 0);   -- Valor binário de entrada (saída da FSM)
        segs  : out std_logic_vector(7 downto 0)    -- Saída para os 7 segmentos + ponto decimal (dp)
    );
end entity seven_segs;

architecture RTL of seven_segs is
begin
    process(input)
    begin
        case input is
            -- Display: dp g f e d c b a
            when "0000" =>  -- apagados
                segs <= "11111111";  
            when "0001" =>  -- a
                segs <= "11111110"; 
            when "0010" =>  -- ab
                segs <= "11111100";  
            when "0011" =>  -- b
                segs <= "11111101";  
            when "0100" =>  -- bc
                segs <= "11111001"; 
            when "0101" =>  -- c
                segs <= "11111011"; 
            when "0110" => -- cd
                segs <= "11110011";
            when "0111" =>  -- d
                segs <= "11110111"; 
            when "1000" =>  -- de
                segs <= "11100111";  
            when "1001" =>  -- e
                segs <= "11101111";  
            when "1010" =>  -- ef
                segs <= "11001111"; 
            when "1011" =>  -- f
                segs <= "11011111"; 
            when "1100" => -- fa
                segs <= "11011110";
            when "1101" => -- g
                segs <= "10111111";
            when "1110" => -- dp
                segs <= "01111111";
            when "1111" => -- abcdef
                segs <= "11000000";
            when others =>
                segs <= "11111111";
        end case;
    end process;
end architecture RTL;
