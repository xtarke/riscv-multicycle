library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
	
end entity testbench;

architecture RTL of testbench is
	
	component imemory
		port(
			clk           : in  std_logic;
			data          : in  std_logic_vector(31 downto 0);
			write_address : in  integer range 0 to 31;
			read_address  : in  integer range 0 to 31;
			we            : in  std_logic;
			q             : out std_logic_vector(31 downto 0)
		);
	end component imemory;
	
	component core
		port(
			clk      : in  std_logic;
			rst      : in  std_logic;
			iaddress : out integer range 0 to 31;
			idata    : in  std_logic_vector(31 downto 0)
		);
	end component core;
	
	signal clk : std_logic;
	signal rst : std_logic;
	
	signal data          : std_logic_vector(31 downto 0);
	signal write_address : integer range 0 to 31;
	signal iaddress  : integer range 0 to 31 := 0;
	signal we            : std_logic := '0';
	signal q             : std_logic_vector(31 downto 0);
	
begin
	
	clock_driver : process
		constant period : time := 10 ns;
	begin
		clk <= '0';
		wait for period / 2;
		clk <= '1';
		wait for period / 2;
	end process clock_driver;
	
	reset : process is
	begin
		rst <= '1';
		wait for 5 ns;
		rst <= '0';
		wait;
	end process reset;
		
	mem: component imemory
		port map(
			clk           => clk,
			data          => data,
			write_address => write_address,
			read_address  => iaddress,
			we            => we,
			q             => q
	);
	
	myRiscv: core
		port map(
			clk      => clk,
			rst      => rst,
			iaddress => iaddress,
			idata    => q
		);
			

	

end architecture RTL;
