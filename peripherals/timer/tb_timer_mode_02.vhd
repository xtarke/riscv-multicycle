library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------
entity testbench_timer_mode_02 is
end entity testbench_timer_mode_02;
------------------------------

architecture stimulus of testbench_timer_mode_02 is

	constant prescaler_size_for_test : integer := 16;
	constant compare_size_for_test   : integer := 4;

	component Timer
		generic(
			prescaler_size : integer := prescaler_size_for_test;
			compare_size   : integer := compare_size_for_test
		);
		port(
			clock      : in  std_logic;
			reset      : in  std_logic;
			timer_mode : in  unsigned(1 downto 0);
			prescaler  : in  unsigned(prescaler_size - 1 downto 0);
			compare_0A : in  unsigned(compare_size - 1 downto 0);
			compare_0B : in  unsigned(compare_size - 1 downto 0);
			compare_1A : in  unsigned(compare_size - 1 downto 0);
			compare_1B : in  unsigned(compare_size - 1 downto 0);
			compare_2A : in  unsigned(compare_size - 1 downto 0);
			compare_2B : in  unsigned(compare_size - 1 downto 0);
			output_A     : out std_logic_vector(2 downto 0);
			output_B : out std_logic_vector(2 downto 0)
		);
	end component Timer;
	signal clock      : std_logic;
	signal reset      : std_logic;
	signal timer_mode : unsigned(1 downto 0);
	signal prescaler  : unsigned(prescaler_size_for_test - 1 downto 0);
	signal compare_0A : unsigned(compare_size_for_test - 1 downto 0);
	signal compare_0B : unsigned(compare_size_for_test - 1 downto 0);
	signal compare_1A : unsigned(compare_size_for_test - 1 downto 0);
	signal compare_1B : unsigned(compare_size_for_test - 1 downto 0);
	signal compare_2A : unsigned(compare_size_for_test - 1 downto 0);
	signal compare_2B : unsigned(compare_size_for_test - 1 downto 0);
	signal output_A     : std_logic_vector(2 downto 0);
	signal output_B : std_logic_vector(2 downto 0);

	constant clock_period : time := 20 ns;

begin
	dut : component Timer
		port map(
			clock      => clock,
			reset      => reset,
			timer_mode => timer_mode,
			prescaler  => prescaler,
			compare_0A => compare_0A,
			compare_0B => compare_0B,
			compare_1A => compare_1A,
			compare_1B => compare_1B,
			compare_2A => compare_2A,
			compare_2B => compare_2B,
			output_A     => output_A,
			output_B => output_B
		);

	test_clock : process
	begin
		clock <= '0';
		wait for clock_period;
		clock <= '1';
		wait for clock_period;
	end process;

	test : process
	begin
		-- reset:
		reset      <= '1';
		prescaler  <= (others => '0');
		timer_mode <= (others => '0');
		compare_0A <= (others => '0');
		compare_0B <= (others => '0');
		compare_1A <= (others => '0');
		compare_1B <= (others => '0');
		compare_2A <= (others => '0');
		compare_2B <= (others => '0');
		wait for 1 * clock_period;

		-- configure to mode 03:
		timer_mode <= "10";
		prescaler  <= x"0001";
		compare_0A <= x"A";
		compare_0B <= x"A";
		compare_1A <= x"C";
		compare_1B <= x"C";
		compare_2A <= x"E";
		compare_2B <= x"E";
		wait for 1 * clock_period;

		-- run timer:
		reset <= '0';
		wait for 300 * clock_period;

		-- reset timer:
		reset <= '1';
		wait for 1 * clock_period;

		-- run timer again:
		reset <= '0';
		wait for 10 * clock_period;

		wait;
	end process;

end architecture stimulus;
