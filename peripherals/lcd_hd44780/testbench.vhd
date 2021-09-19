-------------------------------------------------------------------------------
--! @file lcd_hd44780.vhd
--! @brief HD44780 LCD decoder peripheral for RISC-V MAX10 softcore
--! @author Rodrigo da Costa
--! @date 21/08/2021
-------------------------------------------------------------------------------

--! Use standard library
library ieee;
--! Use standard logic elements 
use ieee.std_logic_1164.all;
--! Use conversion functions
use ieee.numeric_std.all;

entity lcd_hd44780_tb is
end entity lcd_hd44780_tb;

architecture simulation of lcd_hd44780_tb is
si
	--! Internal signals (RISC-V Datapath)
	signal clk            : std_logic
	signal rst            : std_logic;
	signal lcd_character  : std_logic_vector(7 downto 0);
	signal lcd_init       : std_Logic;
	signal lcd_write_char : std_logic;
	signal lcd_clear      : std_logic;
	signal lcd_goto_l1    : std_logic;
	signal lcd_goto_l2    : std_logic;
	signal lcd_is_busy    : std_logic;  --! During initialization and sending states LCD is busy
	-- TODO: 16x2 8-bit RAM peripheral memory shared with RISC-V

	--! External signals (IOs)
	signal lcd_data : std_logic_vector(7 downto 0);
	signal lcd_rs   : std_logic;        --! Controls if command or char data
	signal lcd_e    : std_logic;        --! Pulse in every command/data
begin

	dut : entity work.lcd_hd44780
		port map(
			clk            => clk,
			rst            => rst,
			lcd_character  => lcd_character,
			lcd_init       => lcd_init,
			lcd_write_char => lcd_write_char,
			lcd_clear      => lcd_clear,
			lcd_goto_l1    => lcd_goto_l1,
			lcd_goto_l2    => lcd_goto_l2,
			lcd_is_busy    => lcd_is_busy,
			lcd_data       => lcd_data,
			lcd_rs         => lcd_rs,
			lcd_e          => lcd_e
		);

	--! 1MHz clock
	process
	begin
		wait for 500 ns;
		clk <= '1';
		wait for 500 ns;
		clk <= '0';
	end process;

	--! Inititialize display and write characters
	process
	begin
		rst      <= '0';
		wait for 10 us;
		lcd_init <= '1';
	end process;

	-- Async reset
	process
	begin
		wait for 2 us;
		--rst <= '0';
	end process;

end architecture simulation;
