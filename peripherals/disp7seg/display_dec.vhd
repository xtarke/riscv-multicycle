-------------------------------------------------------------------
-- Name        : decoder.vhd
-- Author      : Renan Augusto Starke
-------------------------------------------------------------------

-- Bibliotecas
library ieee;
use ieee.std_logic_1164.all;

-------------------------------------
entity display_dec is
	port 
	(
		data_in : in std_logic_vector(3 downto 0);
		disp : out std_logic_vector(7 downto 0)
	);
end entity display_dec;
------------------------------

architecture behaviour of display_dec is
	
begin
	disp <= "11000000" when data_in = x"0" else
			"11111001" when data_in = x"1" else
			"10100100" when data_in = x"2" else
			"10110000" when data_in = x"3" else
			"10011001" when data_in = x"4" else
			"10010010" when data_in = x"5" else
			"10000010" when data_in = x"6" else
			"11111000" when data_in = x"7" else
			"10000000" when data_in = x"8" else
			"10010000" when data_in = x"9" else
			"10001000" when data_in = x"A" else
			"10000011" when data_in = x"B" else
			"10100111" when data_in = x"C" else
			"10100001" when data_in = x"D" else
			"10000110" when data_in = x"E" else
			"10001110"; -- x"F"

end architecture behaviour;
