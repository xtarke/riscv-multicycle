library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------
entity tb_wtd_mode_1 is
end entity tb_wtd_mode_1;
------------------------------

architecture stimulus of tb_wtd_mode_1 is

	constant prescaler_size_for_test : integer := 16;

	component watchdog2
		generic(
			prescaler_size : integer := prescaler_size_for_test;
			WTD_BASE_ADDRESS : unsigned(15 downto 0)	:= x"0090"
		);
		port(
			clock       : in  std_logic;
			reset       : in  std_logic;
			
			wtd_reset 	: in  std_logic;
			wtd_mode  	: in  unsigned(1 downto 0);
			prescaler   : in  unsigned(prescaler_size - 1 downto 0);
			top_counter : in  unsigned(prescaler_size - 1 downto 0);
			
			wtd_clear	: in  std_logic;	
			wtd_interrupt_clr : in  std_logic;
			wtd_hold	: in  std_logic;
			wtd_interrupt: out std_logic;
			wtd_out		: out std_logic
		);
	end component watchdog2;
	
	signal clock       			: std_logic;
	signal reset       			: std_logic;
	signal wtd_reset 			: std_logic;
	signal wtd_mode  			: unsigned(1 downto 0);
	signal prescaler   			: unsigned(prescaler_size_for_test - 1 downto 0);
	signal top_counter 			: unsigned(prescaler_size_for_test - 1 downto 0);
	signal wtd_hold				: std_logic;
	signal wtd_clear			: std_logic;
	signal wtd_interrupt_clr	: std_logic;
	signal wtd_interrupt		: std_logic;
	signal wtd_out				: std_logic;

	constant clock_period : time := 20 ns;

begin
	
	dut: component watchdog2
		port map(
			clock        	=> clock,
			reset       	=> reset,
			wtd_reset  		=> wtd_reset,
			wtd_mode   		=> wtd_mode,
			prescaler    	=> prescaler,
			top_counter  	=> top_counter,
			wtd_clear    	=> wtd_clear,
			wtd_interrupt_clr => wtd_interrupt_clr,
			wtd_hold     	=> wtd_hold,
			wtd_interrupt 	=> wtd_interrupt,
			wtd_out    		=> wtd_out
		);

	test_clock : process
	begin
		clock <= '0';
		wait for clock_period;
		clock <= '1';
		wait for clock_period;
	end process;

	test : process
	begin
		-- reset:
		reset       <= '1';
		wtd_reset 	<= '0';
		prescaler  	<= (others => '0');
		wtd_mode 	<= "00";
		wtd_hold 	<= '0';
		wtd_clear 	<= '0';

		wait for 1 * clock_period;
		reset       <= '0';
		
		-- configure to mode 01:
		wtd_reset <= '1';
		wtd_mode 	<= "01";
		prescaler  	<= x"0001";
		top_counter <= x"0008";
		wait for 4 * clock_period;

		-- ativa WTD:
		wtd_reset <= '0';
		
		-- expected event:
		wait for 8 * clock_period;
		wtd_reset 	<= '1';
		
		wait for 6 * clock_period;
		wtd_reset 	<= '0';
		
		wait for 4 * clock_period;
		wtd_hold <= '1';
		wait for 4 * clock_period;
		wtd_hold <= '0';
		
		wait for 14 * clock_period;
		wtd_reset 	<= '1';
		
		wait;
	end process;

end architecture stimulus;
