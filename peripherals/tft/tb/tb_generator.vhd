library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench_generator is
end entity;

architecture stimulus_generator of testbench_generator is
	
	signal clk  	    : std_logic := '0';
	signal reset		: std_logic := '0';
	signal mem_full    	: std_logic := '0';
	signal mem_init    	: std_logic := '0';
	signal input_a		: unsigned(31 downto 0) := x"00000000";
	signal input_b		: unsigned(31 downto 0) := x"00000000";
	signal input_c		: unsigned(31 downto 0) := x"00000000";
	signal output		: unsigned(31 downto 0);
	signal rst			: std_logic;
	signal write_en		: std_logic := '0';
	
begin

	dut : entity work.generator
		port map(
			clk      => clk,
			mem_init => mem_init,
			mem_full => mem_full,
			input_a  => input_a,
			input_b  => input_b,
			input_c  => input_c,
			output   => output,
			enable   => write_en,
			rst      => rst
		);
	
	-- clock
	process
	begin
		clk <= '0';
		wait for 1 ns;
		clk <= '1';
		wait for 1 ns;
	end process;
	
	-- execução
	process
	begin
		wait for 1 ns;
		
		reset <= '1';
		wait for 1 ns;
		
		reset <= '0';
		wait for 2 ns;
		
		input_a <= x"FFFF0000";
		wait until (rst = '1');
		mem_init <= '0';
		
		wait for 2 ns;
		input_a <= x"7FFF0000";
		
		wait for 10 ns;
		input_a <= x"80010000";
		
		wait for 5 ns;
		input_a <= x"00010000";
		
		wait for 100 ns;
		mem_init <= '1';
		
		wait for 10 ns;
		input_a <= x"8001FFFF";
		
		wait for 5 ns;
		input_a <= x"0001FFFF";
		
		wait;
	end process;

end architecture;
