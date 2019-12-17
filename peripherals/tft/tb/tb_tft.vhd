--No código de inicialização do display há delays de inicialização em milisegundos, 
--para conseguir aferir o funcionamento na simulação, é recomendado que altere o
--valor da constante ADJ presente no arquivo "writer.vhd" para o valor 1.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-------------------------------------
entity testbench_tft_controller is
end entity testbench_tft_controller;
------------------------------

architecture stimulus_tft_controller of testbench_tft_controller is

	signal clk : std_logic;

	signal input_a : unsigned(31 downto 0);
	signal input_b : unsigned(31 downto 0);
	signal input_c : unsigned(31 downto 0);

	signal pin_output : unsigned(7 downto 0);
	signal pin_cs     : std_logic := '0';
	signal pin_rs     : std_logic := '0';
	signal pin_wr     : std_logic := '0';
	signal pin_rst    : std_logic := '0';
	
	signal daddress :  natural;
	signal dcsel    : std_logic_vector(1 downto 0);
	signal d_we     : std_logic := '0';
	
	signal ret       : unsigned(31 downto 0);
	
begin

	tft_inst : entity work.tft
		port map(
			clk        => clk,
			daddress   => daddress,
			dcsel      => dcsel,
			d_we       => d_we,
			input_a    => input_a,
			input_b    => input_b,
			input_c    => input_c,
			ret        => ret,
			pin_output => pin_output,
			pin_cs     => pin_cs,
			pin_rs     => pin_rs,
			pin_wr     => pin_wr,
			pin_rst    => pin_rst
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
		daddress <= 8;
		dcsel <= "10";
		d_we <= '1';
		input_a <= x"ffffffff";
		input_b <= x"00000000";
		input_c <= x"00000000";
		wait for 20 us;
		
		d_we <= '0';
		wait for 10 ns;
	
		d_we <= '1';
		input_a <= x"0001fafa";
		input_b <= x"00000000";
		input_c <= x"00000000";
		wait for 100 ns;
		
		d_we <= '0';
		wait for 10 ns;
	
		d_we <= '1';
		input_a <= x"0003ffff";
		input_b <= x"00020002";
		input_c <= x"00020002";
		wait;
	end process;

end architecture stimulus_tft_controller;
