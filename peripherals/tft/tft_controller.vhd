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
entity tft_controller is
	port(
		clk    : IN  std_logic;
		reset  : IN  std_logic;
		--CMD			: IN  unsigned (63 downto 0);

		cs     : out std_logic;
		rs     : out std_logic;
		wr     : out std_logic;
		output : out unsigned(7 downto 0)
	);
end entity tft_controller;
------------------------------

ARCHITECTURE RTL_tft OF tft_controller IS

	SIGNAL wr_en_1      : std_logic;
	SIGNAL wr_data_1    : unsigned(31 downto 0);
	SIGNAL rd_en_1      : std_logic;
	--SIGNAL rd_valid_1   : std_logic;
	SIGNAL rd_data_1    : unsigned(31 downto 0);
	SIGNAL empty_1      : std_logic;
	SIGNAL full_1       : std_logic;
	--SIGNAL fill_count_1 : integer range 64 downto 0;

	SIGNAL wr_en_2      : std_logic;
	SIGNAL wr_data_2    : unsigned(31 downto 0);
	SIGNAL rd_en_2      : std_logic;
	--SIGNAL rd_valid_2   : std_logic;
	SIGNAL rd_data_2    : unsigned(31 downto 0);
	SIGNAL empty_2      : std_logic;
	SIGNAL full_2       : std_logic;
	--SIGNAL fill_count_2 : integer range 64 downto 0;

	signal start : std_logic;
	signal ready : std_logic;

	SIGNAL mux_sel : std_logic;
	SIGNAL mux_out : unsigned(31 downto 0);

BEGIN                                   -- inicio do corpo da arquitetura

	mux32_inst : entity work.mux32
		port map(
			a   => rd_data_1,
			b   => rd_data_2,
			sel => mux_sel,
			S   => mux_out
		);

	ring_buffer_init : entity work.ring_buffer
		generic map(
			RAM_WIDTH => 32,
			RAM_DEPTH => 60,
			HEAD_INIT => 42,
			FILENAME  => "ili9320_init.txt"
		)
		port map(
			clk        => clk,
			rst        => reset,
			wr_en      => wr_en_1,
			wr_data    => wr_data_1,
			rd_en      => rd_en_1,
			--rd_valid   => rd_valid_1,
			rd_data    => rd_data_1,
			empty      => empty_1,
			full       => full_1
			--fill_count => fill_count_1
		);

	ring_buffer_data : entity work.ring_buffer
		generic map(
			RAM_WIDTH => 32,
			RAM_DEPTH => 60,
			HEAD_INIT => 1,
			FILENAME  => "empty.txt"
		)
		port map(
			clk        => clk,
			rst        => reset,
			wr_en      => wr_en_2,
			wr_data    => wr_data_2,
			rd_en      => rd_en_2,
			--rd_valid   => rd_valid_2,
			rd_data    => rd_data_2,
			empty      => empty_2,
			full       => full_2
			--fill_count => fill_count_2
		);

	write_cdmdata_inst : entity work.write_cdmdata
		port map(
			clk    => clk,
			reset  => reset,
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
			reset    => reset,
			ready    => ready,
			start    => start,
			mux_sel  => mux_sel,
			empty_1  => empty_1,
			empty_2  => empty_2,
			read_en1 => rd_en_1,
			read_en2 => rd_en_2
		);
		
		wr_data_1 <= x"00000000";
		wr_en_1 <= '0';
		
		wr_data_2 <= x"00000000";
		wr_en_2 <= '0';
		
END ARCHITECTURE;
