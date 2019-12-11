library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decoder is
	port(
		clk      : in  std_logic;
		mem_init : in  std_logic;
		mem_full : in  std_logic;
		input_a  : in  unsigned(31 downto 0);
		input_b  : in  unsigned(31 downto 0);
		input_c  : in  unsigned(31 downto 0);
		output   : out unsigned(31 downto 0);
		enable   : out std_logic;
		rst      : out std_logic
	);
end entity;

architecture rtl_decoder of decoder is
	
	constant n_block : natural := 3;
	type MUX is array (0 to n_block) of unsigned(output'range);

	signal ready    : std_logic;
	signal color    : unsigned(15 downto 0);
	signal output_a : unsigned(31 downto 0);
	signal output_b : unsigned(31 downto 0);
	signal sel      : unsigned(7 downto 0);

	signal mux_completed : unsigned(n_block - 1 downto 0);
	signal mux_enable    : unsigned(n_block - 1 downto 0);
	signal mux_output    : MUX;

begin

	controller_inst : entity work.dec_fsm
		port map(
			clk      => clk,
			ready    => ready,
			input_a  => input_a,
			input_b  => input_b,
			input_c  => input_c,
			color    => color,
			output_a => output_a,
			output_b => output_b,
			sel      => sel
		);
	
	mux_enable(0) <= '0';
	mux_output(0) <= x"00000000";
	reset_inst : entity work.dec_reset
		port map(
			clk       => clk,
			sel       => sel,
			mem_init  => mem_init,
			completed => mux_completed(0),
			rst       => rst
		);

	clean_inst : entity work.dec_clean
		generic map(
			SIZE_DISPLAY => 76800
		)
		port map(
			clk       => clk,
			sel       => sel,
			completed => mux_completed(1),
			mem_full  => mem_full,
			color     => color,
			output    => mux_output(1),
			write_en  => mux_enable(1)
		);
		
	draw_rect_inst : entity work.dec_rect
		generic map(
			WIDTH  => 240,
			HEIGHT => 320
		)
		port map(
			clk       => clk,
			sel       => sel,
			pos_x     => output_a(31 downto 16),
			pos_y     => output_a(15 downto  0),
			len_x     => output_b(31 downto 16),
			len_y     => output_b(15 downto  0),
			color     => color,
			mem_full  => mem_full,
			write_en  => mux_enable(2),
			output   => mux_output(2),
			completed => mux_completed(2)
		);
		
		output <= mux_output(0) when sel = x"01" else
				  mux_output(1) when sel = x"02" else
				  mux_output(2) when sel = x"03" else 
				  mux_output(2) when sel = x"04" else 
				  x"00000000";
		
		enable <= mux_enable(0) when sel = x"01" else
				  mux_enable(1) when sel = x"02" else
				  mux_enable(2) when sel = x"03" else 
				  mux_enable(2) when sel = x"04" else 
				  '0';
				  
		ready  <= mux_completed(0) when sel = x"01" else
				  mux_completed(1) when sel = x"02" else
				  mux_completed(2) when sel = x"03" else 
				  mux_completed(2) when sel = x"04" else 
				  '0';

end architecture;
