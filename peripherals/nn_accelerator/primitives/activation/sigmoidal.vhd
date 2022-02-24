-------------------------------------------------------
--! @file    sigmoidal.vhd
--! @author  Leonardo Benitez
--! @date    2021-11-02
--! @version 0.1
--! @brief   Decoder for seven segments display; 
--!          Leds are active in 0
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sigmoidal is
    port (
        input:       in  std_logic_vector(3 downto 0);
        segs:        out std_logic_vector(7 downto 0)
    );
end entity sigmoidal;

architecture rtl of sigmoidal is
begin
	process (input)
	begin
		case input is				
			--    ABCD		        .gfedcba
			when "0000" => segs <= "11000000";	-- 0
			when "0001" => segs <= "11111001";	-- 1
			when "0010" => segs <= "10100100";	-- 2
			when "0011" => segs <= "10110000";	-- 3
			when "0100" => segs <= "10011001";	-- 4
			when "0101" => segs <= "10010010";	-- 5
			when "0110" => segs <= "10000010";	-- 6
			when "0111" => segs <= "11111000";	-- 7
			when "1000" => segs <= "10000000";	-- 8
			when "1001" => segs <= "10010000";	-- 9
			when "1010" => segs <= "10001000";	-- A
			when "1011" => segs <= "10000011";	-- B
			when "1100" => segs <= "10100111";	-- C
			when "1101" => segs <= "10100001";	-- D
			when "1110" => segs <= "10000110";	-- E
			when others => segs <= "10001110";	-- F
		end case;
	end process;
end architecture rtl;