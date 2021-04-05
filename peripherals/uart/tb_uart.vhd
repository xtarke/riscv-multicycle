library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_uart is
	generic (
		constant SIZE : integer := 8
	);
	
end entity tb_uart;

architecture RTL of tb_uart is
	
	signal clk_1M_state : boolean;
	signal clk_in_1M : std_logic;
	
	signal clk_baud : std_logic;
	signal clk_baudState : boolean;
	
	signal csel : std_logic;
	signal data_in : std_logic_vector(SIZE-1 downto 0);
	signal tx : std_logic;
	signal tx_cmp : std_logic;
	
	signal data_out : std_logic_vector(SIZE-1 downto 0);
	signal rx : std_logic;
	signal rx_cmp : std_logic;
	signal to_rx : std_logic_vector(7 downto 0);
	signal cnt_rx : integer := 0;
	signal config_all  : std_logic_vector (31 downto 0);
	
begin

	config_all <= (others => '0');
	
	dut: entity work.uart
		generic map(
			SIZE => SIZE
		)
		port map(
			clk_in_1M => clk_in_1M,
			clk_baud  => clk_baud,
			csel	  => csel,
			data_in   => data_in,
			tx        => tx,
			tx_cmp    => tx_cmp,
			data_out  => data_out,
			rx        => rx,
			rx_cmp    => rx_cmp,
			config_all => config_all
		);

	clock_1M: process
	begin
		clk_in_1M <= '0';
		wait for 1 ns;
		for i in 0 to 40 loop
			clk_in_1M <= '0';
			clk_1M_state <= FALSE;
			wait for 1 ns;
			clk_in_1M <= '1';
			clk_1M_state <= TRUE;
			wait for 1 ns;  
		end loop;
		wait;	
	end process;			
	
	clock_baud: process
	begin
		for i in 0 to 20 loop
			clk_baud <= '0';
			clk_baudState <= FALSE;
			wait for 2 ns;
			clk_baud <= '1';
			clk_baudState <= TRUE;
			wait for 2 ns;  
		end loop;
		wait;	
	end process;
	
	transmitt: process
	begin
		data_in <= x"aa";
		csel <= '1';
		wait until clk_1M_state;
		wait;
	end process;
	
	receive: process
	begin
		to_rx <= x"61";
		rx <= '1';
		wait until clk_1M_state;
		rx <= '0'; -- Start bit
		wait until clk_1M_state;
		for i in 0 to 7 loop
			rx <= (to_rx(cnt_rx));
			cnt_rx <= cnt_rx + 1;
			wait until clk_baudState;
		end loop;
		rx <= '1'; -- Stop bit
		wait;
	end process;
		
end architecture RTL;
