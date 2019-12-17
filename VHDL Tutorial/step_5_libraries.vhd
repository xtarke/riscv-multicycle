--------------------------------------------------------------------------------
-- TODO "Library mapping"
--      Sigasi Studio fully supports VHDL's library mechanism, but it needs to
--      know where the library sources are.
--
--      On the line below, Sigasi reports an unknown library `my_lib`, which
--      results in an unknown entity in the `clock_inst` instantiation.
--
--      Right click the `my_lib` folder in the **Project Explorer** and select 
--      **Set Library > Library my_lib**. This tells Sigasi to compile all files
--      in the `my_lib` folder to the `my_lib` library.
-- 
--      Note that the errors below get resolved.
--------------------------------------------------------------------------------

library my_lib;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity foo is
end entity foo;

architecture STR of foo is
	signal clk : std_logic;
begin
	clock_inst : entity my_lib.clock_generator(BEH)
		generic map(PERIOD => 20 ns)
		port map(clk => clk);
end architecture STR;
