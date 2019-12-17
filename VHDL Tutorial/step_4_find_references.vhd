library ieee;
use ieee.std_logic_1164.all;
package constants is

	----------------------------------------------------------------------------
	-- TODO "Find References"
	--      Sigasi Studio can help you search through your projects. To find out
	--      where the constant `MAX_COUNT` is used, click on `MAX_COUNT` and
	--      press **Ctrl-Shift-G** (or right-click and select **Find References**).
	--      The *Search View* will activate and list all usages of `MAX_COUNT`
	--      in your project. You can expand the search results by clicking the
	--      `+` icon in the top right of the view.
	----------------------------------------------------------------------------

	constant MAX_COUNT : integer := 2 ** 8 - 1; -- Maximum value

	constant ANSWER : integer := 4 * 10 + 2;

	constant MAGIC_NUMNER : std_logic_vector(15 downto 0) := X"da01";

	----------------------------------------------------------------------------
	-- If you got here by using the **declare as enumertion literal** quickfix: 
	-- 
	-- Great! 
	-- 
	-- Now first: you should save this file, since it was edited automatically.  
	-- Next, "Go Back" (**ALT+LEFT**) to verify the error is gone.  
	-- Next, navigate back here with **ALT+RIGHT** and scroll to the next `TODO`.
	----------------------------------------------------------------------------
	type state_t is (idle, preparing, running, ready, waiting); -- FSM State type

	----------------------------------------------------------------------------
	-- TODO "Rename"
	--      With Sigasi you can rename VHDL identifiers in a single operation
	--      that keeps all of your files in sync.  
	--      On the line above, right click `state_t` and select
	--      **Refactor > Rename element**.  
	--      Enter `fsm_t` as new name and confirm with **Enter**
	----------------------------------------------------------------------------

end package constants;
