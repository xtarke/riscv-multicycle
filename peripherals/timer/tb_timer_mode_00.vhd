library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------
entity testbench_timer_mode_00 is
end entity testbench_timer_mode_00;
------------------------------

architecture stimulus of testbench_timer_mode_00 is

	component Timer
		port(
			clock      : in  std_logic;
			reset      : in  std_logic;
			timer_mode : in  unsigned(1 downto 0);
			prescaler  : in  unsigned(15 downto 0);
			compare    : in  unsigned(31 downto 0);
			output     : out std_logic;
			inv_output : out std_logic
		);
	end component Timer;
	signal clock      : std_logic;
	signal reset      : std_logic;
	signal timer_mode : unsigned(1 downto 0);
	signal prescaler  : unsigned(15 downto 0);
	signal compare    : unsigned(31 downto 0);
	signal output     : std_logic;
	signal inv_output : std_logic;

	constant clock_period : time := 20 ns;

begin
	dut : component Timer
		port map(
			clock      => clock,
			reset      => reset,
			timer_mode => timer_mode,
			prescaler  => prescaler,
			compare    => compare,
			output     => output,
			inv_output => inv_output
		);

	test_clock : process
	begin
		clock <= '0';
		wait for clock_period;
		clock <= '1';
		wait for clock_period;
	end process;
	
	test: process
	begin
		-- reset:
		reset <= '1';
		prescaler <= (others => '0');
		timer_mode <= (others => '0');
		compare <= (others => '0');
		wait for 1*clock_period;
		
		-- configure to mode 00:
		timer_mode <= "00";
		prescaler <= x"0002";
		compare <= x"00000003";
		wait for 1*clock_period;
		
		-- run timer:
		reset <= '0';
		wait for 10*clock_period;
		
		-- reset timer:
		reset <= '1';
		wait for 1*clock_period;

		-- run timer again:
		reset <= '0';
		wait for 10*clock_period;
		
		wait;
	end process;

end architecture stimulus;
