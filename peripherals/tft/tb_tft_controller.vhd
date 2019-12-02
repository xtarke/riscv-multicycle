-------------------------------------------------------------------
-- Name        : 
-- Author      : 
-- Version     : 
-- Copyright   : 
-- Description : 
-------------------------------------------------------------------

-- Bibliotecas e clásulas
library ieee;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
-------------------------------------
ENTITY testbench_tft_controller IS
END ENTITY testbench_tft_controller;
------------------------------

ARCHITECTURE stimulus_tft_controller OF testbench_tft_controller IS

	SIGNAL clk    	: std_logic;
	SIGNAL reset  	: std_logic;
	SIGNAL wr_en  	: std_logic;
	SIGNAL wr_data	: unsigned(31 downto 0);

	signal output 	: unsigned(7 downto 0); -- := x"00";
	signal cs     	: std_logic := '0';
	signal rs     	: std_logic := '0';
	signal wr     	: std_logic := '0';

BEGIN                                   -- inicio do corpo da arquitetura

	tft_controller_inst : entity work.tft_controller
		port map(
			clk    => clk,
			reset  => reset,
			cs     => cs,
			rs     => rs,
			wr     => wr,
			output => output
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
		wr_data <= x"00000000";
		wr_en   <= '0';
		--clk     <= '0';
		reset   <= '1';
		wait for 1 ns;
		--clk     <= '1';
		wait for 1 ns;
		reset   <= '0';

		wait;
	end process;

END ARCHITECTURE stimulus_tft_controller;
