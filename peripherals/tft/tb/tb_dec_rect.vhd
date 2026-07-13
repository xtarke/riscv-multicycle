library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-------------------------------------
entity testbench_dec_rect is
end entity testbench_dec_rect;
------------------------------

architecture stimulus_dec_rect of testbench_dec_rect is

	signal clk       : std_logic;
	signal sel       : unsigned(7 downto 0);
	signal pos_x     : unsigned(15 downto 0);
	signal pos_y     : unsigned(15 downto 0);
	signal len_x     : unsigned(15 downto 0);
	signal len_y     : unsigned(15 downto 0);
	signal color     : unsigned(15 downto 0);
	signal full      : std_logic;
	signal wr_en     : std_logic;
	signal wr_data   : unsigned(31 downto 0);
	signal completed : std_logic;
	signal rst       : std_logic;
	signal rd_en     : std_logic;
	signal rd_data   : unsigned(31 downto 0);
	signal empty     : std_logic;

begin

	data_mem_inst : entity work.data_mem
		generic map(
			RAM_WIDTH => 32,
			RAM_DEPTH => 512,
			HEAD_INIT => 0
		)
		port map(
			clk     => clk,
			rst     => rst,
			wr_en   => wr_en,
			wr_data => wr_data,
			rd_en   => rd_en,
			rd_data => rd_data,
			empty   => empty,
			full    => full
		);

	dec_rect_inst : entity work.dec_rect
		generic map(
			WIDTH  => 240,
			HEIGHT => 320
		)
		port map(
			clk       => clk,
			sel       => sel,
			mem_full  => full,
			color     => color,
			pos_x     => pos_x,
			pos_y     => pos_y,
			len_x     => len_x,
			len_y     => len_y,
			write_en  => wr_en,
			output    => wr_data,
			completed => completed
		);

	-- Set concurrent parameters
	pos_x <= x"000A";
	pos_y <= x"000A";
	len_x <= x"0002";
	len_y <= x"0002";
	color <= x"FAFA";

	clock : process
	begin
		clk <= '0';
		wait for 1 ns;
		clk <= '1';
		wait for 1 ns;
	end process;

	-- comandos
	process
	begin
		sel   <= x"00";
		rst   <= '1';
		rd_en <= '0';
		
		wait for 5 ns;
		wait until rising_edge(clk);
		
		rst   <= '0';
		wait until rising_edge(clk);
		
		-- Pulse the selector for exactly one clock cycle
		sel   <= x"04"; 
		wait until rising_edge(clk);
		sel   <= x"00"; -- Return to 0 to prevent FSM looping
		
		-- wait for the module 'completed' flag
		wait until completed = '1';
		wait until rising_edge(clk);
		
		-- Read data back from the memory buffer
		while empty = '0' loop
			rd_en <= '1';
			wait until rising_edge(clk);
		end loop;
		
		rd_en <= '0';
		
		wait;
	end process;

end architecture;