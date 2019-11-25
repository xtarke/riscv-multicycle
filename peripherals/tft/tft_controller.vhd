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

	SIGNAL clk        : std_logic;
	SIGNAL rst        : std_logic;
	SIGNAL wr_en      : std_logic;
	SIGNAL wr_data    : unsigned(31 downto 0);
	SIGNAL rd_en      : std_logic;
	SIGNAL rd_valid   : std_logic;
	SIGNAL rd_data    : unsigned(31 downto 0);
	SIGNAL empty      : std_logic;
	SIGNAL full       : std_logic;
	SIGNAL fill_count : integer range 61 downto 0;

	signal start    	: std_logic := '0';
	signal ready    	: std_logic := '0';
	
	signal output		: unsigned(7 downto 0);-- := x"00";
	signal cs			: std_logic := '0';
	signal rs			: std_logic := '0';
	signal wr			: std_logic := '0';
	
	signal empty_2		: std_logic := '1';
	signal read_en2		: std_logic;
	
    SIGNAL b		: unsigned (31 downto 0);
    SIGNAL mux_sel	: std_logic;
    SIGNAL mux_out	: unsigned (31 downto 0);
	

BEGIN                                   -- inicio do corpo da arquitetura
	
	mux32_inst : entity work.mux32
		port map(
			a   => rd_data,
			b   => b,
			sel => mux_sel,
			S   => mux_out
		);
		
	ring_buffer_inst : entity work.ring_buffer
		generic map(
			RAM_WIDTH => 32,
			RAM_DEPTH => 62,
			HEAD_INIT => 42,
			FILENAME  => "ili9320_init.txt"
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
	
	write_cdmdata_inst : entity work.write_cdmdata
		port map(
			clk    => clk,
			reset  => rst,
			start  => start,
			ready  => ready,
			data   => mux_out,
			output => output,
			cs     => cs,
			rs     => rs,
			wr     => wr
		);
		
		fsm_inst : entity work.fsm
			port map(
				clk      => clk,
				reset    => rst,
				ready    => ready,
				start    => start,
				mux_sel  => mux_sel,
				empty_1  => empty,
				empty_2  => empty_2,
				read_en1 => rd_en,
				read_en2 => read_en2
			);
	
	clock: process
	begin
		clk <= '0';
		wait for 1 ns;
		clk <= '1';
		wait for 1 ns;
	end process;
	
	process
	begin
		
		wr_data <= x"00000000";
		wr_en <= '0';
		--clk     <= '0';
		rst     <= '1';
		wait for 1 ns;
		--clk     <= '1';
		wait for 1 ns;
		rst     <= '0';


		wait;
	end process;

END ARCHITECTURE stimulus_tft_controller;
