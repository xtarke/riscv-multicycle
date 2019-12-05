library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2c_master_testbench is
end entity i2c_master_testbench;

architecture RTL of i2c_master_testbench is
	signal sda : std_logic;
	signal scl : std_logic;
	signal clk : std_logic;
	signal clk_scl : std_logic;
	signal rst : std_logic;
	signal ena : std_logic;
	signal data_w : std_logic_vector(7 downto 0);
	signal ack_err : std_logic;
	signal rw : std_logic;
	signal addr : std_logic_vector(6 downto 0);
	
begin
	
	dut : entity work.i2c_master
		port map(
			sda     => sda,
			scl     => scl,
			clk     => clk,
			clk_scl => clk_scl,
			rst     => rst,
			ena     => ena,
			rw      => rw,
			addr    => addr,
			data_w  => data_w,
			ack_err => ack_err
		);
		
		addr <= "1101000";
		rw <= '0';
		
		
		process
		begin
			wait for 10 ns;
			clk <= '1';
			wait for 10 ns;
			clk <= '0';
			
		end process;
		
		process
		begin
			wait for 5 ns;
			loop
				wait for 10 ns;
				clk_scl <= '1';
				wait for 10 ns;
				clk_scl <= '0';
			end loop;
			
		end process;
		
		process
		begin
			rst <= '1';
			ena <= '0';
			
			data_w <= "10101100";
			wait for 20 ns;
			rst <= '0';
			ena <= '1';
			wait for 80 ns;
			ena <= '0';
			wait for 300 ns;
			
			data_w <= "10100011";
			ena <= '1';
			wait;			
		end process;
		
		process
		begin
			
			sda <= 'Z';
			wait for 235 ns;
			sda <= '0';
			wait for 20 ns;
			sda <= 'Z';
			wait for 180 ns;
			sda <= '0';
			wait for 20 ns;
			sda <= 'Z';
			wait;			
			
		end process;
		
		

end architecture RTL;
