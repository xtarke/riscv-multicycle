library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench_decoder is
end entity;

architecture stimulus_decoder of testbench_decoder is
	
	signal clk  	    : std_logic := '0';
	signal reset		: std_logic := '0';
	signal mem_full    	: std_logic := '0';
	signal mem_init    	: std_logic := '0';
	signal start        : std_logic := '0';
	signal input_a		: unsigned(31 downto 0) := x"00000000";
	signal input_b		: unsigned(31 downto 0) := x"00000000";
	signal input_c		: unsigned(31 downto 0) := x"00000000";
	signal output		: unsigned(31 downto 0);
	signal rst			: std_logic;
	signal enable		: std_logic := '0';
	
begin

	dut : entity work.decoder_tft
		port map(
			clk      => clk,
			mem_init => mem_init,
			mem_full => mem_full,
			start    => start,
			input_a  => input_a,
			input_b  => input_b,
			input_c  => input_c,
			output   => output,
			enable   => enable,
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
		
		mem_full <= '0';
		mem_init <= '0';
		start    <= '0';
		
		wait until rising_edge(clk);
		mem_init <= '1';
		wait until rising_edge(clk);
		
		-- Reset state (Command: 0xFFFF)
		input_a <= x"FFFF0000"; 
		input_b <= x"00000000";
		input_c <= x"00000000";
		wait until rising_edge(clk);
		start <= '1';
		wait until rising_edge(clk);
		start <= '0';
		
		wait for 500 ns; 
		
		-- Clean state (Command: 0x0001, Color: 0xF800 [Red])
		input_a <= x"0001F800"; 
		input_b <= x"00000000";
		input_c <= x"00000000";
		wait until rising_edge(clk);
		start <= '1';
		wait until rising_edge(clk);
		start <= '0';
		
		wait for 500 ns;
		
		-- Rect state (Command: 0x0003, Color: 0x07E0 [Green])
		-- input_b: pos_x (upper 16) = 10 (0x000A), pos_y (lower 16) = 20 (0x0014)
		-- input_c: len_x (upper 16) = 50 (0x0032), len_y (lower 16) = 40 (0x0028)
		input_a <= x"000307E0"; 
		input_b <= x"000A0014"; 
		input_c <= x"00320028";
		wait until rising_edge(clk);
		start <= '1';
		wait until rising_edge(clk);
		start <= '0';
		
		wait for 2000 ns;
		wait;
	end process;

end architecture;
