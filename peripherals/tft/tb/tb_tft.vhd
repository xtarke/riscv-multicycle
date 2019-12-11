library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-------------------------------------
entity testbench_tft_controller is
end entity testbench_tft_controller;
------------------------------

architecture stimulus_tft_controller of testbench_tft_controller is

	signal clk : std_logic;

	signal input_a : unsigned(31 downto 0);
	signal input_b : unsigned(31 downto 0);
	signal input_c : unsigned(31 downto 0);

	signal output : unsigned(7 downto 0);
	signal cs     : std_logic := '0';
	signal rs     : std_logic := '0';
	signal wr     : std_logic := '0';

begin

	tft_inst : entity work.tft
		port map(
			clk     => clk,
			input_a => input_a,
			input_b => input_b,
			input_c => input_c,
			output  => output,
			cs      => cs,
			rs      => rs,
			wr      => wr
		);

	clock : process
	begin
		clk <= '0';
		wait for 1 ns;
		clk <= '1';
		wait for 1 ns;
	end process;

	process
	begin
		input_a <= x"00000000";
		input_b <= x"00000000";
		input_c <= x"00000000";
		wait for 10 ns;

		input_a <= x"ffffffff";
		input_b <= x"00000000";
		input_c <= x"00000000";
		wait for 20 us;

		input_a <= x"00000000";
		input_b <= x"00000000";
		input_c <= x"00000000";
		wait for 100 ns;

--		input_a <= x"8001fafa";
--		input_b <= x"00000000";
--		input_c <= x"00000000";
--		wait for 100 ns;

		input_a <= x"00000000";
		input_b <= x"00000000";
		input_c <= x"00000000";
		wait for 100 ns;

		input_a <= x"8003ffff";
		input_b <= x"00020002";
		input_c <= x"00020002";
		wait;
	end process;

end architecture stimulus_tft_controller;
