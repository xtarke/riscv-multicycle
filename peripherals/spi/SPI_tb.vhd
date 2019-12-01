library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_tb is
end spi_tb;


architecture rtl of spi_tb is
	  constant n_bits : integer := 8;
	  signal i_clk       : std_logic;
	  signal i_rst       : std_logic;
	  signal i_tx_start  : std_logic; 
	  signal i_miso      : std_logic; 
	  signal i_data      : std_logic_vector(n_bits-1 downto 0);  
	  signal o_data      : std_logic_vector(n_bits-1 downto 0);  
	  signal o_tx_end    : std_logic; 
	  signal o_sclk      : std_logic;
	  signal o_ss        : std_logic;
	  signal o_mosi      : std_logic;
	  
	    -- debug-- remove it later
	 signal debug_idle_flag : std_logic;
	 signal debug_tx_flag   : std_logic;
	 signal debug_end_flag  : std_logic;
	
begin
	
	spi_t: entity work.SPI
	generic map(
	  n_bits      =>  n_bits	  )  
	port map (
	  i_clk        => i_clk,
	  i_rst        => i_rst,
	  i_tx_start   => i_tx_start,
	  i_data       => i_data,
	  i_miso       => o_mosi,
	  o_data       => o_data, 
	  o_tx_end     => o_tx_end,
	  o_sclk       => o_sclk, 
	  o_ss         => o_ss,
	  o_mosi       => o_mosi,
	  
	  debug_idle_flag  => debug_idle_flag,
	  debug_tx_flag    => debug_tx_flag,
	  debug_end_flag   => debug_end_flag
	 ); 
	
	i_miso  <=  o_mosi;
	
	clock: process
	begin
		i_clk  <= '0';
		wait for 5 ns;
		i_clk  <= '1'; 
		wait for 5 ns; 
	end process;
	
	reset : process 
	begin
		i_rst  <=  '0';
		wait for 15 ns;
		i_rst  <=  '1';
--		wait for 200 ns;
--	    i_rst  <=  '0';
--	    wait for 20 ns;
--	    i_rst  <=  '1';
	    wait;
	    
	end process;
	
	test : process
	 
	begin
		i_data  <=  x"a9";
		i_tx_start  <= '0';
		wait for 20 ns;
		i_tx_start  <= '1';
		wait until o_tx_end = '1';
		i_tx_start  <= '0';
		wait;
		
	end process;
	

end rtl;