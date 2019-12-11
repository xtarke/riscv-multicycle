library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux32 is
	port(
		input_a : in  unsigned(31 downto 0);
		input_b : in  unsigned(31 downto 0);
		sel     : in  std_logic;
		output  : out unsigned(31 downto 0)
	);
end entity;

architecture rtl of mux32 is
begin

	output <= input_a when sel = '0' else input_b;

end architecture;
