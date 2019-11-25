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
ENTITY testbench IS
END ENTITY testbench;
------------------------------

ARCHITECTURE stimulus OF testbench IS

	component ring_buffer
		generic(
			RAM_WIDTH : natural;
			RAM_DEPTH : natural;
			HEAD_INIT : natural;
			FILENAME  : string
		);
		port(
			clk        : IN  std_logic;
			rst        : IN  std_logic;
			wr_en      : IN  std_logic;
			wr_data    : IN  std_logic_vector(RAM_WIDTH - 1 downto 0);
			rd_en      : IN  std_logic;
			rd_valid   : OUT std_logic;
			rd_data    : OUT std_logic_vector(RAM_WIDTH - 1 downto 0);
			empty      : OUT std_logic;
			full       : OUT std_logic;
			fill_count : OUT integer range RAM_DEPTH - 1 downto 0
		);
	end component ring_buffer;

	SIGNAL clk        : std_logic;
	SIGNAL rst        : std_logic;
	SIGNAL wr_en      : std_logic;
	SIGNAL wr_data    : std_logic_vector(31 downto 0);
	SIGNAL rd_en      : std_logic;
	SIGNAL rd_valid   : std_logic;
	SIGNAL rd_data    : std_logic_vector(31 downto 0);
	SIGNAL empty      : std_logic;
	SIGNAL full       : std_logic;
	SIGNAL fill_count : integer range 61 downto 0;

BEGIN                                   -- inicio do corpo da arquitetura
	dut : ring_buffer
		generic map(
			RAM_WIDTH => 32,
			RAM_DEPTH => 62,
			HEAD_INIT => 42,
			FILENAME => "ili9320_init.txt"
		)
		port map(
			clk        => clk,
			rst        => rst,
			wr_en      => wr_en,
			wr_data    => wr_data,
			rd_en      => rd_en,
			rd_valid   => rd_valid,
			rd_data    => rd_data,
			empty      => empty,
			full       => full,
			fill_count => fill_count
		);

	process
	begin
		
		wr_en   <= '0';
		wr_data <= x"000FF000";
		rd_en   <= '0';
		
		clk     <= '0';
		rst     <= '1';
		wait for 1 ns;
		clk     <= '1';
		wait for 1 ns;
		rst     <= '0';
		clk     <= '0';
		
		
		wait for 1 ns;
		clk     <= '1';
		wait for 1 ns;
		clk     <= '0';
		
		wr_en   <= '0';
		wr_data <= x"000FF000";
		rd_en   <= '1';

		wait for 1 ns;

		for I in 0 to 50 loop
			clk     <= '1';
			wait for 1 ns;
			clk     <= '0';
			wait for 1 ns;
		end loop;

		wait;
	end process;

END ARCHITECTURE stimulus;
