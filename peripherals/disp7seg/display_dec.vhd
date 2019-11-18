-------------------------------------------------------------------
-- Name        : decoder.vhd
-- Author      : Leonardo Persike Martins
-------------------------------------------------------------------

-- Bibliotecas
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-------------------------------------
entity display_dec is
	port 
	(
		hex : in std_logic_vector(3 downto 0);
		dot : in std_logic;
		disp : out std_logic_vector(7 downto 0)
	);
end entity display_dec;
------------------------------

architecture behaviour of display_dec is
	
begin
	disp <= "11000000" when hex = x"0" else
			"11111001" when hex = x"1" else
			"10100100" when hex = x"2" else
			"10110000" when hex = x"3" else
			"10011001" when hex = x"4" else
			"10010010" when hex = x"5" else
			"10000010" when hex = x"6" else
			"11111000" when hex = x"7" else
			"10000000" when hex = x"8" else
			"10010000" when hex = x"9" else
			"10001000" when hex = x"A" else
			"10000011" when hex = x"B" else
			"10100111" when hex = x"C" else
			"10100001" when hex = x"D" else
			"10000110" when hex = x"E" else
			"10001110"; -- x"F"

end architecture behaviour;
