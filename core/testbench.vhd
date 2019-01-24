library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
	generic (
		--! Num of 32-bits memory words 
		IMEMORY_WORDS : integer := 1024;	--!= 4K (1024 * 4) bytes
		DMEMORY_WORDS : integer := 512  	--!= 2k (512 * 2) bytes
	);
	
end entity testbench;

architecture RTL of testbench is
	
	component imemory
		generic(MEMORY_WORDS : integer);
		port(
			clk : in std_logic;							--! Clock input
			data: in std_logic_vector (31 downto 0);	--! Write data input
			read_address_a: in integer range 0 to MEMORY_WORDS-1;	--! Address to be written
	    	read_address_b: in integer range 0 to MEMORY_WORDS-1;	--! Address to be read
	    	q_a:  out std_logic_vector (31 downto 0);		--! Read output
	    	csel : in std_logic;    	
	    	q_b:  out std_logic_vector (31 downto 0)		--! Read output
		);
	end component imemory;
	
	    
    component dmemory
    	generic(MEMORY_WORDS : integer);
    	port(
    		rst : in std_logic;
    		clk     : in  std_logic;
    		data    : in  std_logic_vector(31 downto 0);
    		address : in  integer range 0 to MEMORY_WORDS - 1;
    		we      : in  std_logic;
    		csel : in std_logic;	
    		dmask   : in std_logic_vector(3 downto 0);
    		q       : out std_logic_vector(31 downto 0)
    	);
    end component dmemory;
	
	
	component core
		generic (
			--! Num of 32-bits memory words 
			IMEMORY_WORDS : integer := 256; 
			DMEMORY_WORDS : integer := 512
		);
		port(
			clk : in std_logic;
			rst : in std_logic;
			
			iaddress  : out  integer range 0 to IMEMORY_WORDS-1;
			idata	  : in 	std_logic_vector(31 downto 0);
			
			daddress  : out  integer range 0 to DMEMORY_WORDS-1;
			
			ddata_r	  : in 	std_logic_vector(31 downto 0);
			ddata_w   : out	std_logic_vector(31 downto 0);
			d_we      : out std_logic;
			dcsel	  : out std_logic_vector(1 downto 0);
			dmask     : out std_logic_vector(3 downto 0)	--! Byte enable mask 
		);
	end component core;
	
	signal clk : std_logic;
	signal rst : std_logic;
	
	signal idata          : std_logic_vector(31 downto 0);
	
	signal daddress :  integer range 0 to DMEMORY_WORDS-1;
	signal ddata_r	:  	std_logic_vector(31 downto 0);
	signal ddata_w  :	std_logic_vector(31 downto 0);
	signal dmask         : std_logic_vector(3 downto 0);
	signal dcsel : std_logic_vector(1 downto 0);
	signal d_we            : std_logic := '0';
	
	signal RAMaddress :  integer range 0 to 256 - 1;
	
	
	signal iaddress  : integer range 0 to IMEMORY_WORDS-1 := 0;

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
	
--	imem: component imemory
--		generic map(
--			MEMORY_WORDS => IMEMORY_WORDS
--		)
--		port map(
--			clk           => clk,
--			data          => idata,
--			write_address => 0,
--			read_address  => iaddress,
--			we            => '0',
--			q             => idata 
--	);
	
	imem: component imemory
		generic map(
			MEMORY_WORDS => IMEMORY_WORDS
		)
		port map(
			clk            => clk,
			data           => idata,
			read_address_a => iaddress,
			read_address_b => daddress,
			q_a            => idata,
			csel           => dcsel(0),
			q_b            => ddata_r
		);
	
	-- RAMaddress <= to_integer(unsigned(daddress));
	
	
	dmem: component dmemory
		generic map(
			MEMORY_WORDS => DMEMORY_WORDS
		)
		port map(
			rst => rst,
			clk     => clk,
			data    => ddata_w,
			address => daddress, --RAMaddress,
			csel	=> dcsel(1),
			we      => d_we,
			dmask   => dmask,
			q       => ddata_r
		);

	-- RAMaddress <= to_integer(unsigned(daddress));
	

	myRiscv: component core
		generic map(
			IMEMORY_WORDS => IMEMORY_WORDS,
			DMEMORY_WORDS => DMEMORY_WORDS
		)
		port map(
			clk      => clk,
			rst      => rst,
			iaddress => iaddress,
			idata    => idata,
			daddress => daddress,
			ddata_r  => ddata_r,
			ddata_w  => ddata_w,
			dcsel	 => dcsel,
			d_we     => d_we,
			dmask    => dmask
		);
		
	

end architecture RTL;
