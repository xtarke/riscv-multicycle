library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Timer is
	generic(
		prescaler_size : integer := 16;
		compare_size   : integer := 32
	);
	port(
		clock       : in  std_logic;
		reset       : in  std_logic;
		timer_reset : in  std_logic;
		timer_mode  : in  unsigned(1 downto 0);
		prescaler   : in  unsigned(prescaler_size - 1 downto 0);
		top_counter : in  unsigned(compare_size - 1 downto 0);
		compare_0A  : in  unsigned(compare_size - 1 downto 0);
		compare_0B  : in  unsigned(compare_size - 1 downto 0);
		compare_1A  : in  unsigned(compare_size - 1 downto 0);
		compare_1B  : in  unsigned(compare_size - 1 downto 0);
		compare_2A  : in  unsigned(compare_size - 1 downto 0);
		compare_2B  : in  unsigned(compare_size - 1 downto 0);
		output_A    : out std_logic_vector(2 downto 0);
		output_B    : out std_logic_vector(2 downto 0)
	);
end entity Timer;

architecture RTL of Timer is
	signal counter                    : unsigned(compare_size - 1 downto 0) := (others => '0');
	signal internal_clock             : std_logic                           := '1';
	signal internal_counter_direction : std_logic                           := '0';
	--	type counter_direction_t is (Up, Down);

begin

	p1 : process(clock, reset) is       -- @suppress "Incomplete sensitivity list. Missing signals: internal_clock, prescaler"
		variable temp_counter : unsigned(prescaler_size - 1 downto 0) := (others => '0');
	begin
		if reset = '0' then
			if prescaler = x"0001" then
				internal_clock <= clock;
			elsif rising_edge(clock) then
				temp_counter := temp_counter + 1;
				if temp_counter >= prescaler - 1 then
					internal_clock <= not (internal_clock);
					temp_counter   := (others => '0');
				end if;
			end if;
		else
			temp_counter := (others => '0');
		end if;
	end process p1;

	p2 : process(internal_clock, reset) is
		variable internal_output_A : std_logic_vector(2 downto 0) := (others => '0');
		variable internal_output_B : std_logic_vector(2 downto 0) := (others => '0');
		variable counter_direction : std_logic                    := '0';
	begin
		if reset = '0' then
			if rising_edge(internal_clock) then
				if timer_reset = '1' then
					internal_output_A := (others => '0');
					internal_output_B := (others => '0');
					counter           <= (others => '0');
					counter_direction := '0';
				else
					case timer_mode is
						when "00" =>    -- one shot mode

							if counter >= compare_0A - 1 then
								internal_output_A(0) := '1';
							else
								internal_output_A(0) := '0';
								counter              <= counter + 1;
							end if;

							if counter >= compare_0B - 1 then
								internal_output_B(0) := '1';
							else
								internal_output_B(0) := '0';
								counter              <= counter + 1;
							end if;

							if counter >= compare_1A - 1 then
								internal_output_A(1) := '1';
							else
								internal_output_A(1) := '0';
								counter              <= counter + 1;
							end if;

							if counter >= compare_1B - 1 then
								internal_output_B(1) := '1';
							else
								internal_output_B(1) := '0';
								counter              <= counter + 1;
							end if;

							if counter >= compare_2A - 1 then
								internal_output_A(2) := '1';
							else
								internal_output_A(2) := '0';
								counter              <= counter + 1;
							end if;

							if counter >= compare_2B - 1 then
								internal_output_B(2) := '1';
							else
								internal_output_B(2) := '0';
								counter              <= counter + 1;
							end if;

						when "11" =>    -- clear on compare mode, counter is as sawtooth wave

							-- the counter resets if reaches B comparator.
							-- the output has a rectangular waveform like a simple PWM, but active when between A and B comparators
							if counter >= top_counter - 1 then
								counter <= (others => '0');
							else
								counter <= counter + 1;
							end if;

							if (counter >= compare_0A - 1) and (counter < compare_0B - 1) then
								internal_output_A(0) := '1';
								internal_output_B(0) := '0';
							else
								internal_output_A(0) := '0';
								internal_output_B(0) := '1';
							end if;

							if (counter >= compare_1A - 1) and (counter < compare_1B - 1) then
								internal_output_A(1) := '1';
								internal_output_B(1) := '0';
							else
								internal_output_A(1) := '0';
								internal_output_B(1) := '1';
							end if;

							if (counter >= compare_2A - 1) and (counter < compare_2B - 1) then
								internal_output_A(2) := '1';
								internal_output_B(2) := '0';
							else
								internal_output_A(2) := '0';
								internal_output_B(2) := '1';
							end if;

						when "10" =>    -- clear on compare mode, counter is a centered triangle wave

							-- the counter change its direction (up or down) when it reaches its maximum possible value
							-- the output has a rectangular waveform centered to the top value, active when between A and B comparators. 
							if counter_direction = '0' then
								if counter >= top_counter - 1 then
									counter_direction := '1';
									counter           <= counter - 1;
								else
									counter <= counter + 1;
								end if;

								if counter >= compare_0A - 1 then
									internal_output_A(0) := '1';
								else
									internal_output_A(0) := '0';
								end if;

								if counter >= compare_0B - 1 then
									internal_output_B(0) := '0';
								else
									internal_output_B(0) := '1';
								end if;

								if counter >= compare_1A - 1 then
									internal_output_A(1) := '1';
								else
									internal_output_A(1) := '0';
								end if;

								if counter >= compare_1B - 1 then
									internal_output_B(1) := '0';
								else
									internal_output_B(1) := '1';
								end if;

								if counter >= compare_2A - 1 then
									internal_output_A(2) := '1';
								else
									internal_output_A(2) := '0';
								end if;

								if counter >= compare_2B - 1 then
									internal_output_B(2) := '0';
								else
									internal_output_B(2) := '1';
								end if;

							else
								if counter <= 0 then
									counter_direction := '0';
									counter           <= counter + 1;
								else
									counter <= counter - 1;
								end if;

								if counter > compare_0A - 1 then
									internal_output_A(0) := '1';
								else
									internal_output_A(0) := '0';
								end if;

								if counter > compare_0B - 1 then
									internal_output_B(0) := '0';
								else
									internal_output_B(0) := '1';
								end if;

								if counter > compare_1A - 1 then
									internal_output_A(1) := '1';
								else
									internal_output_A(1) := '0';
								end if;

								if counter > compare_1B - 1 then
									internal_output_B(1) := '0';
								else
									internal_output_B(1) := '1';
								end if;

								if counter > compare_2A - 1 then
									internal_output_A(2) := '1';
								else
									internal_output_A(2) := '0';
								end if;

								if counter > compare_2B - 1 then
									internal_output_B(2) := '0';
								else
									internal_output_B(2) := '1';
								end if;

							end if;

							internal_counter_direction <= counter_direction;

						when "01" =>    -- clear on top mode, counter is as sawtooth wave

							-- the counter resets if reaches its maximum possible value
							-- the output has a rectangular waveform like a simple PWM
							if counter >= top_counter - 1 then
								counter <= (others => '0');
							else
								counter <= counter + 1;
							end if;

							if counter >= compare_0A - 1 then
								internal_output_A(0) := '1';
							else
								internal_output_A(0) := '0';
							end if;

							if counter >= compare_0B - 1 then
								internal_output_B(0) := '1';
							else
								internal_output_B(0) := '0';
							end if;

							if counter >= compare_1A - 1 then
								internal_output_A(1) := '1';
							else
								internal_output_A(1) := '0';
							end if;

							if counter >= compare_1B - 1 then
								internal_output_B(1) := '1';
							else
								internal_output_B(1) := '0';
							end if;

							if counter >= compare_2A - 1 then
								internal_output_A(2) := '1';
							else
								internal_output_A(2) := '0';
							end if;

							if counter >= compare_2B - 1 then
								internal_output_B(2) := '1';
							else
								internal_output_B(2) := '0';
							end if;

						when others =>  -- none / error
							internal_output_A := (others => '0');
							internal_output_B := (others => '0');

					end case;
				end if;
			end if;

			output_A <= internal_output_A;
			output_B <= internal_output_B;
		else
			internal_output_A := (others => '0');
			internal_output_B := (others => '0');
			output_A <= internal_output_A;
			output_B <= internal_output_B;
			counter_direction := '0';
		end if;

	end process p2;

end architecture RTL;
