library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Timer is
	port(
		clock      : in  std_logic;
		reset      : in  std_logic;
		timer_mode : in  unsigned(1 downto 0);
		prescaler  : in  unsigned(15 downto 0);
		compare    : in  unsigned(31 downto 0);
		output     : out std_logic;
		inv_output : out std_logic
	);
end entity Timer;

architecture RTL of Timer is
	
	
		
	
begin
	
		
end architecture RTL;
