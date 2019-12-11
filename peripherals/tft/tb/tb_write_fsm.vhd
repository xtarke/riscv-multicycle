library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench_write_fsm is
end entity testbench_write_fsm;

architecture stimulus_write_fsm of testbench_write_fsm is
	
	signal clk  	    : std_logic := '0';
	signal reset		: std_logic := '0';
	signal start    	: std_logic := '0';
	signal ready    	: std_logic := '0';
	signal data			: unsigned(31 downto 0) := x"89ABCDEF";
	signal output		: unsigned(7 downto 0) := x"00";
	signal cs			: std_logic := '0';
	signal rs			: std_logic := '0';
	signal wr			: std_logic := '0';
	
begin

	dut : entity work.write_cdmdata
		port map(
			clk    => clk,
			reset  => reset,
			start  => start,
			ready  => ready,
			data   => data,
			output => output,
			cs     => cs,
			rs     => rs,
			wr     => wr
		);
	
	-- clock
	process
	begin
		clk <= '0';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;
	end process;
	
	-- execução
	process
	begin
		wait for 4 ns;
		reset <= '1';
		wait for 10 ns;
		reset <= '0';
		wait for 5 ns;
		start <= '1';
		wait for 10 ns;
		start <= '0';
		wait for 300 ns;
		data <= x"FFFF0010";
		wait for 1 ns;
		start <= '1';
		wait for 10 ns;
		start <= '0';
		wait for 300 ns;
		data <= x"12345678";
		wait for 1 ns;
		start <= '1';
		wait for 10 ns;
		start <= '0';
		wait;
	end process;

end architecture stimulus_write_fsm;
