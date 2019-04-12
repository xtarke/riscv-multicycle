library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.decoder_types.all;

entity testbench is
	generic (
		--! Num of 32-bits memory words 
		IMEMORY_WORDS : integer := 1024;	--!= 4K (1024 * 4) bytes
		DMEMORY_WORDS : integer := 1024  	--!= 2k (512 * 2) bytes
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
	
	
	component iram_quartus
		PORT
		(
			address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
			byteena		: IN STD_LOGIC_VECTOR (3 DOWNTO 0) :=  (OTHERS => '1');
			clock		: IN STD_LOGIC  := '1';
			data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			wren		: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	end component;
	
	    
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
			d_rd	  : out std_logic;
			dcsel	  : out std_logic_vector(1 downto 0);
			dmask     : out std_logic_vector(3 downto 0);	--! Byte enable mask
			state	  : out cpu_state_t 
		);
	end component core;

	component trace_debug
		generic(MEMORY_WORDS : integer);
		port(
			pc   : in integer range 0 to MEMORY_WORDS - 1;
			data : in std_logic_vector(31 downto 0)
		);
	end component trace_debug;
	
	signal clk : std_logic;
	signal rst : std_logic;
	
	signal idata          : std_logic_vector(31 downto 0);
	
	signal daddress :  integer range 0 to DMEMORY_WORDS-1;
	signal ddata_r	:  	std_logic_vector(31 downto 0);
	signal ddata_w  :	std_logic_vector(31 downto 0);
	signal dmask         : std_logic_vector(3 downto 0);
	signal dcsel : std_logic_vector(1 downto 0);
	signal d_we            : std_logic := '0';
	
		
	signal iaddress  : integer range 0 to IMEMORY_WORDS-1 := 0;

	
	
	signal address : std_logic_vector(9 downto 0);
	signal ddata_r_mem : std_logic_vector(31 downto 0);
	signal d_rd : std_logic;
		
	signal input_out	: std_logic_vector(31 downto 0);
	signal cpu_state    : cpu_state_t;
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

	-- IMem shoud be read from instruction and data buses
	-- Not enough RAM ports for instruction bus, data bus and in-circuit programming
	--with dcsel select 
	--	address <= std_logic_vector(to_unsigned(daddress,10)) when "01",
	--			   std_logic_vector(to_unsigned(iaddress,10)) when others;				   
	process(d_rd, dcsel, daddress, iaddress)
	begin
		if (d_rd = '1') and (dcsel = "00") then
			address <= std_logic_vector(to_unsigned(daddress,10));
		else
			address <= std_logic_vector(to_unsigned(iaddress,10));
		end if;		
	end process;

	iram_quartus_inst : iram_quartus PORT MAP (
			address	 => address,
			byteena	 => "1111",
			clock	 => clk,
			data	 => (others => '0'),
			wren	 => '0',
			q	 => idata
		);		
	
--	imem: component imemory
--		generic map(
--			MEMORY_WORDS => IMEMORY_WORDS
--		)
--		port map(
--			clk            => clk,
--			data           => idata,
--			read_address_a => iaddress,
--			read_address_b => daddress,
--			q_a            => idata,
--			csel           => dcsel(0),
--			q_b            => ddata_r
--		);
	
	-- RAMaddress <= to_integer(unsigned(daddress));
	
	
	dmem: component dmemory
		generic map(
			MEMORY_WORDS => DMEMORY_WORDS
		)
		port map(
			rst => rst,
			clk => clk,
			data => ddata_w,
			address => daddress, --RAMaddress,
			we => d_we,
			csel => dcsel(0),
			dmask => dmask,
			q => ddata_r_mem
		);
		
	with dcsel select 
		ddata_r <= idata when "00",
		           ddata_r_mem when "01",
		           input_out when "10",
		           (others => '0') when others;
	

	myRiscv: component core
		generic map(
			IMEMORY_WORDS => IMEMORY_WORDS,
			DMEMORY_WORDS => DMEMORY_WORDS
		)
		port map(
			clk => clk,
			rst => rst,
			iaddress => iaddress,
			idata => idata,
			daddress => daddress,
			ddata_r => ddata_r,
			ddata_w => ddata_w,
			d_we => d_we,
			d_rd => d_rd,
			dcsel => dcsel,
			dmask => dmask,
			state => cpu_state
		);
		
	debug: component trace_debug
		generic map(
			MEMORY_WORDS => IMEMORY_WORDS
		)
		port map(
			pc   => iaddress,
			data => idata
		);
	

end architecture RTL;
