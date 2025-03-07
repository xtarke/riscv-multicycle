library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SEG_HEX is
    Port (
        -- Entrada de 4 bits (dígito hexadecimal)
        iDIG    : in  STD_LOGIC_VECTOR(3 downto 0);
        -- Saída para o display de 7 segmentos
        oHEX_D  : out STD_LOGIC_VECTOR(6 downto 0)
    );
end SEG_HEX;

architecture Behavioral of SEG_HEX is
begin
    -- Processo para decodificar o valor de entrada em um padrão de 7 segmentos
    process(iDIG)
    begin
        case iDIG is
            when "0000" => oHEX_D <= "1000000"; -- 0
            when "0001" => oHEX_D <= "1111001"; -- 1
            when "0010" => oHEX_D <= "0100100"; -- 2
            when "0011" => oHEX_D <= "0110000"; -- 3
            when "0100" => oHEX_D <= "0011001"; -- 4
            when "0101" => oHEX_D <= "0010010"; -- 5
            when "0110" => oHEX_D <= "0000010"; -- 6
            when "0111" => oHEX_D <= "1111000"; -- 7
            when "1000" => oHEX_D <= "0000000"; -- 8
            when "1001" => oHEX_D <= "0011000"; -- 9
            when "1010" => oHEX_D <= "0001000"; -- A
            when "1011" => oHEX_D <= "0000011"; -- B
            when "1100" => oHEX_D <= "1000110"; -- C
            when "1101" => oHEX_D <= "0100001"; -- D
            when "1110" => oHEX_D <= "0000110"; -- E
            when "1111" => oHEX_D <= "0001110"; -- F
            when others => oHEX_D <= "1000000"; -- 0 (default)
        end case;
    end process;
end Behavioral;