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
ENTITY testbench_mux32 IS
END ENTITY testbench_mux32;
------------------------------

ARCHITECTURE stimulus_mux32 OF testbench_mux32 IS

	-- declaração de sinais
	SIGNAL a   : unsigned(31 downto 0) := x"FF000000";
	SIGNAL b   : unsigned(31 downto 0) := x"00FF0000";
	SIGNAL sel : std_logic             := '0';
	SIGNAL S   : unsigned(31 downto 0);

BEGIN                                   -- inicio do corpo da arquitetura

	dut : entity work.mux32
		port map(
			a   => a,
			b   => b,
			sel => sel,
			S   => S
		);
	process
	begin
		wait for 10 ns;
		sel <= '1';
		wait;
	end process;

END ARCHITECTURE stimulus_mux32;
