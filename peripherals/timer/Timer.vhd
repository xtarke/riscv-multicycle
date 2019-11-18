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

	signal counter        : unsigned(31 downto 0) := (others => '0');
	signal internal_clock : std_logic             := '1';

begin

	p1 : process(clock) is -- @suppress "Incomplete sensitivity list. Missing signals: internal_clock, prescaler"
		variable temp_counter : unsigned(16 downto 0) := (others => '0'); -- 17 bits devido ao prescaler ser multiplicado por 2.

	begin
		if rising_edge(clock) OR falling_edge(clock) then
			temp_counter := temp_counter + 1;
			if temp_counter >= prescaler then
				internal_clock <= not (internal_clock);
				temp_counter   := (others => '0');
			end if;
		end if;
	end process p1;

	p2 : process(internal_clock) is
		variable internal_output : std_logic := '0';
	begin
		if rising_edge(internal_clock) then

			if reset = '1' then
				internal_output := '0';
				counter         <= (others => '0');
			else
				case timer_mode is
					when "00" =>        -- one shot mode

						if counter >= compare -1 then
							internal_output := '1';
						else
							internal_output := '0';
							counter <= counter + 1;
						end if;

					when "01" =>        -- clear on compare mode

						-- counter reset if reaches its maximum possible value
						if counter = counter'high -1 then
							counter <= (others => '0');
						else
							counter <= counter + 1;
						end if;

						if counter >= compare -1 then
							internal_output := '1';
						else
							internal_output := '0';
						end if;

					when others =>      -- none / error
						internal_output := '0';
				end case;
			end if;

			output     <= internal_output;
			inv_output <= not (internal_output);

		end if;

	end process p2;

end architecture RTL;
