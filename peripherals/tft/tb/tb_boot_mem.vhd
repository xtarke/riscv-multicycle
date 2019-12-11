library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-------------------------------------
entity testbench_boot_mem is
end entity testbench_boot_mem;
------------------------------

architecture stimulus_boot_mem of testbench_boot_mem is

	signal clk        : std_logic;
	signal rst        : std_logic;
	signal rd_en      : std_logic;
	signal rd_data    : unsigned(31 downto 0);
	signal empty      : std_logic;

begin
	boot_mem_inst : entity work.boot_mem
		port map(
			clk     => clk,
			rst     => rst,
			rd_en   => rd_en,
			rd_data => rd_data,
			empty   => empty
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
		
		rst 	<= '1';
		rd_en   <= '0';

		wait for 2 ns;
		rst 	<= '0';
		
		wait for 4 ns;
		rd_en   <= '1';
		
		wait for 130 ns;
		rst 	<= '1';

		wait for 2 ns;
		rst 	<= '0';
		

		wait;
	end process;

end architecture;
