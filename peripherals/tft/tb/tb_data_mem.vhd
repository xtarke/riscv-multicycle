library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-------------------------------------
entity testbench_data_mem is
end entity testbench_data_mem;
------------------------------

architecture stimulus_data_mem of testbench_data_mem is

	signal clk        : std_logic;
	signal rst        : std_logic;
	signal wr_en      : std_logic;
	signal wr_data    : unsigned(31 downto 0);
	signal rd_en      : std_logic;
	signal rd_data    : unsigned(31 downto 0);
	signal empty      : std_logic;
	signal full       : std_logic;
    

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
	
	
	clock : process
	begin
		clk <= '0';
		wait for 1 ns;
		clk <= '1';
		wait for 1 ns;
	end process;
	
	process
	begin

		wr_en   <= '0';
		wr_data <= x"00000000";
		rd_en   <= '0';
		rst     <= '1';
		
		wait for 5 ns;
		wait until rising_edge(clk);
		
		rst     <= '0';
		wait until rising_edge(clk);
		
		wr_en   <= '1';
		wr_data <= x"000FF000";
		wait until rising_edge(clk);
		
		wr_data <= x"AAAAAAAA";
		wait until rising_edge(clk);
		
		wr_data <= x"BBBBBBBB";
		wait until rising_edge(clk);
		
		wr_en   <= '0';
		wait until rising_edge(clk);
		
		rd_en   <= '1';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		
		rd_en   <= '0';
		
		wait;
	end process;
	
end architecture;
