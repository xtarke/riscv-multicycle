library ieee;
use ieee.std_logic_1164.all;

package sdram_pkg is
	-- 8-word burst buffer (burst length programmed in the SDRAM mode register)
	type io_buffer_t is array (0 to 7) of std_logic_vector(15 downto 0);
end package sdram_pkg;
