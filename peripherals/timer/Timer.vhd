library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Timer is
	generic(
		prescaler_size : integer := 16;
		compare_size   : integer := 32
	);
	port(
		clock      : in  std_logic;
		reset      : in  std_logic;
		timer_mode : in  unsigned(1 downto 0);
		prescaler  : in  unsigned(prescaler_size - 1 downto 0);
		compare_0A    : in  unsigned(compare_size - 1 downto 0);
		compare_0B    : in  unsigned(compare_size - 1 downto 0);
		compare_1A    : in  unsigned(compare_size - 1 downto 0);
		compare_1B    : in  unsigned(compare_size - 1 downto 0);
		compare_2A    : in  unsigned(compare_size - 1 downto 0);
		compare_2B    : in  unsigned(compare_size - 1 downto 0);
		output_A     : out std_logic_vector(2 downto 0);
		output_B : out std_logic_vector(2 downto 0)
	);
end entity Timer;

architecture RTL of Timer is
	constant counter_max              : unsigned(compare_size - 1 downto 0) := (others => '1');
	signal counter                    : unsigned(compare_size - 1 downto 0) := (others => '0');
	signal internal_clock             : std_logic                           := '1';
	signal internal_counter_direction : std_logic                           := '0';
	--	type counter_direction_t is (Up, Down);

begin

	p1 : process(clock) is              -- @suppress "Incomplete sensitivity list. Missing signals: prescaler, internal_clock"
		variable temp_counter : unsigned(prescaler_size - 1 downto 0) := (others => '0'); -- 17 bits devido ao prescaler ser multiplicado por 2.
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
		variable internal_output   : std_logic_vector(2 downto 0) := (others => '0');
		variable counter_direction : std_logic := '0';
	begin
		if rising_edge(internal_clock) then

			if reset = '1' then
				internal_output   := (others => '0');
				counter           <= (others => '0');
				counter_direction := '0';

			else
				case timer_mode is
					when "00" =>        -- one shot mode

						if counter >= compare_0A - 1 then
							internal_output(0) := '1';
						else
							internal_output(0) := '0';
							counter         <= counter + 1;
						end if;
						
						if counter >= compare_1A - 1 then
							internal_output(1) := '1';
						else
							internal_output(1) := '0';
							counter         <= counter + 1;
						end if;
						
						if counter >= compare_2A - 1 then
							internal_output(2) := '1';
						else
							internal_output(2) := '0';
							counter         <= counter + 1;
						end if;

					when "01" =>        -- clear on compare mode, counter is as sawtooth wave

						-- the counter reset if reaches its maximum possible value
						-- the output is has a rectangular waveform like a simple PWM
						if counter >= counter_max then
							counter <= (others => '0');
						else
							counter <= counter + 1;
						end if;

						if (counter >= compare_0A - 1) and (counter < compare_0B - 1) then
							internal_output(0) := '1';
						else
							internal_output(0) := '0';
						end if;
						
						if (counter >= compare_1A - 1) and (counter < compare_1B - 1) then
							internal_output(1) := '1';
						else
							internal_output(1) := '0';
						end if;
						
						if (counter >= compare_2A - 1) and (counter < compare_2B - 1) then
							internal_output(2) := '1';
						else
							internal_output(2) := '0';
						end if;

					when "10" =>        -- clear on compare mode, counter is a centered triangle wave

						-- the counter change its direction (up or down) when it reaches its maximum possible value
						-- the output has a rectangular waveform centered to the top value, active when between A and B comparators. 
						if counter_direction = '0' then
							if counter >= counter_max then
								counter_direction := '1';
								counter <= counter - 1;
							else
								counter <= counter + 1;
							end if;
							
							if counter >= compare_0A - 1 then
								internal_output(0) := '1';
							else
								internal_output(0) := '0';
							end if;
							
							if counter >= compare_1A - 1 then
								internal_output(1) := '1';
							else
								internal_output(1) := '0';
							end if;
							
							if counter >= compare_2A - 1 then
								internal_output(2) := '1';
							else
								internal_output(2) := '0';
							end if;
							
						else
							if counter <= 0 then
								counter_direction := '0';
								counter <= counter + 1;
							else
								counter <= counter - 1;
							end if;
							
							if counter > compare_0B - 1 then
								internal_output(0) := '1';
							else
								internal_output(0) := '0';
							end if;
							
							if counter > compare_1B - 1 then
								internal_output(1) := '1';
							else
								internal_output(1) := '0';
							end if;
							
							if counter > compare_2B - 1 then
								internal_output(2) := '1';
							else
								internal_output(2) := '0';
							end if;
							
						end if;

						internal_counter_direction <= counter_direction;

					when others =>      -- none / error
						internal_output := (others => '0');

				end case;
			end if;

			output_A     <= internal_output;
			output_B <= not (internal_output);

		end if;

	end process p2;

end architecture RTL;
