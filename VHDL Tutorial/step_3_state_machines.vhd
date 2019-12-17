library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity dut is
	----------------------------------------------------------------------------
	-- If you arrived here via **Open Declaration**, you can navigate back to
	-- your previous location, just like in your webbrowser, by pressing
	-- **ALT+LEFT** or by clicking the yellow left pointing arrow in the toolbar.
	-- Next, navigate back here with **ALT+RIGHT** and scroll to the next TODO.
	----------------------------------------------------------------------------
	generic(
		iterations : integer := 10
	);
	port(
		data_out : out unsigned(7 downto 0);
		data_in  : in  unsigned(7 downto 0);
		valid    : out std_logic;
		start    : in  std_logic;
		clk      : in  std_logic;
		rst      : in  std_logic
	);
end entity dut;                         -- entity dut

use work.constants.all;
architecture RTL of dut is
	signal count  : integer range 0 to MAX_COUNT;
	signal result : unsigned(7 downto 0);
begin
	assert iterations <= MAX_COUNT;

	----------------------------------------------------------------------------
	-- TODO "Quickfix"
	--      Some VHDL problems can be automatically resolved with **quickfixes**.
	--      These problems have markers annotated with a lightbulb icon, like
	--      the *sensitivity list* problem below.  
	--      Trigger a quickfix: click the problem marker (or press **Ctrl+1**)
	--      and select the quickfix.
	----------------------------------------------------------------------------
	
	COUNTER : process(clk) is
		variable state : state_t;
	begin
		if rst = '1' then
			state  := idle;
			count  <= 0;
			valid  <= '0';
			result <= (others => '0');
		elsif rising_edge(clk) then
			--------------------------------------------------------------------
			-- TODO "Missing choices"
			--      The line below has an error because not all choices of the
			--      enumeration type "state_t" are covered.  
			--      Click on the lightbulb icon to the left of the line to add
			--      the missing choices.
			--------------------------------------------------------------------
			case state is
				when idle =>
					if start = '1' then
						count <= 0;
						state := preparing;
					end if;
					valid  <= '0';
					result <= (others => '0');
				when preparing =>
					state := running;
				when running =>
					if count = iterations then
						state  := ready;
						result <= resize(result * data_in, result'length);
					end if;
					count <= count + 1;
				----------------------------------------------------------------
				-- TODO "Declare new enumeration literal"
				--      The line below has an error because there is no state
				--      called `almost_ready` in the enumeration datatype
				--      `state_t`.  
				--      Click on the lightbulb icon to the left of the line and
				--      select **Declare as new enumeration literal**
				----------------------------------------------------------------
				when almost_ready =>
					state := ready;
				when ready =>
					data_out <= result;
					valid    <= '1';
					state    := idle;
			end case;
		end if;
	end process COUNTER;

end architecture RTL;
