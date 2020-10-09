library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lcd_tb is
end entity lcd_tb;

architecture RTL of lcd_tb is
	signal clk : std_logic;
	signal reset : std_logic := '0';
		
	signal char : std_logic_vector(7 downto 0);
	signal rst : std_logic;
	signal ce : std_logic;
	signal dc : std_logic;
	signal din : std_logic;
	signal serial_clk : std_logic;
	signal light : std_logic := '0';

begin

	char <= x"41"; -- caractere A

    dut : entity work.lcd
		port map(
			clk => clk,
			reset => reset,
			char => char,
			rst => rst,
			ce => ce,
			dc => dc,
			din => din,
			serial_clk => serial_clk,
			light => light
		);

	process
	begin
		wait for 2 us;
		reset <= '1';
	end process;

    process
    begin
		clk <= '0';
        wait for 5 us;
        clk <= '1';
        wait for 5 us;           
    end process;
    
end architecture RTL;
