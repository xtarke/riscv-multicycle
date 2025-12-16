
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_arith.all;
	use ieee.std_logic_unsigned.all;

entity tb is

end tb;

architecture giovanna_tb of tb is

	signal	tb_clock		: std_logic := '0';
	signal	tb_reset        : std_logic := '0';
	signal	tb_enable       : std_logic := '0';
	signal	tb_progr_regr   : std_logic := '0';
	signal	tb_leds			: std_logic_vector(3 downto 0) := (others => '0');
	signal	tb_debug		: std_logic;

begin

	tb_clock <= not tb_clock after 10 ns;
	
	tb_reset <= '1',
				'0' after 17 ns;
				
	tb_enable <= '1';
	
	tb_progr_regr <= '0',
					 '1' after 400ns,
					 '0' after 500ns;
				

	duv: entity work.fsm
	port map
	(
		clock		=> tb_clock,
		reset		=> tb_reset,
		enable		=> tb_enable,
		progr_regr	=> tb_progr_regr,
		leds		=> tb_leds,
		debug		=> tb_debug
	);




end giovanna_tb;
