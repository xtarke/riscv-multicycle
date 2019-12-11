library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tft is
	port(
		clk     : in  std_logic;
		input_a : in  unsigned(31 downto 0);
		input_b : in  unsigned(31 downto 0);
		input_c : in  unsigned(31 downto 0);
		output  : out unsigned(7 downto 0);
		cs      : out std_logic;
		rs      : out std_logic;
		wr      : out std_logic;
		rst     : out std_logic
	);
end entity;

architecture rtl_tft of tft is

	signal reset : std_logic;

	signal rd_en_1   : std_logic;
	signal rd_data_1 : unsigned(31 downto 0);
	signal empty_1   : std_logic;

	signal wr_en_2   : std_logic;
	signal wr_data_2 : unsigned(31 downto 0);
	signal rd_en_2   : std_logic;
	signal rd_data_2 : unsigned(31 downto 0);
	signal empty_2   : std_logic;
	signal full_2    : std_logic;

	signal start : std_logic;
	signal ready : std_logic;

	signal mux_sel : std_logic;
	signal mux_out : unsigned(31 downto 0);

begin
	rst <= not reset;
	
	mux32_inst : entity work.mux32
		port map(
			input_a => rd_data_1,
			input_b => rd_data_2,
			sel     => mux_sel,
			output  => mux_out
		);

	boot_mem_inst : entity work.boot_mem
		port map(
			clk     => clk,
			rst     => reset,
			rd_en   => rd_en_1,
			rd_data => rd_data_1,
			empty   => empty_1
		);

	data_mem_inst : entity work.data_mem
		generic map(
			RAM_WIDTH => 32,
			RAM_DEPTH => 320,
			HEAD_INIT => 0
		)
		port map(
			clk     => clk,
			rst     => reset,
			wr_en   => wr_en_2,
			wr_data => wr_data_2,
			rd_en   => rd_en_2,
			rd_data => rd_data_2,
			empty   => empty_2,
			full    => full_2
		);

	write_cdmdata_inst : entity work.writer
		port map(
			clk    => clk,
			reset  => reset,
			start  => start,
			ready  => ready,
			input   => mux_out,
			output => output,
			cs     => cs,
			rs     => rs,
			wr     => wr
		);

	fsm_inst : entity work.controller
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

	decoder_inst : entity work.decoder
		port map(
			clk      => clk,
			mem_init => empty_1,
			mem_full => full_2,
			input_a  => input_a,
			input_b  => input_b,
			input_c  => input_c,
			output   => wr_data_2,
			enable   => wr_en_2,
			rst      => reset
		);

end architecture;
