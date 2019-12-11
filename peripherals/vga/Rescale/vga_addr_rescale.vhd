library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_addr_rescale is
	GENERIC(
		column_size : INTEGER := 90;
		row_size    : INTEGER := 90
	);
	port(
		rst          : in  std_logic;
		column       : in  integer;
		row          : in  integer;
		addr_rescale : out std_logic_vector(12 downto 0)
	);
end entity vga_addr_rescale;

architecture RTL of vga_addr_rescale is

begin
	proc : process(column, row, rst)
		variable addr_count : INTEGER RANGE 0 TO row_size * column_size := 0;
	begin
	if rst = '1' then
		addr_count := 0;
	elsif column = 0 and row= 0 then
		addr_count := 0;
	elsif row < row_size then
		if column < column_size then
			addr_count := addr_count + 1;
		end if;
	end if;
		addr_rescale <= Std_logic_vector(To_unsigned(addr_count, addr_rescale'length));
	end process;

end architecture RTL;
