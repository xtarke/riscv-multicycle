library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_sram is
end entity tb_sram;

architecture RTL of tb_sram is
	component sram
		PORT(
			SRAM_OE_N     : out   std_logic;
			SRAM_WE_N     : out   std_logic;
			SRAM_CE_N     : out   std_logic;
			SRAM_ADDR     : out   std_logic_vector(19 downto 0);
			SRAM_DQ       : inout std_logic_vector(15 downto 0);
			SRAM_UB_N     : out   std_logic;
			SRAM_LB_N     : out   std_logic;
			--
	
			clk           : IN    STD_LOGIC;
			chipselect    : IN    STD_LOGIC;
			write         : IN    STD_LOGIC;
			read		  : IN 	  STD_LOGIC;
			data_in          : out  STD_LOGIC_VECTOR(15 DOWNTO 0);
			address       : in    std_logic_vector(19 downto 0);
			--read_address  : IN    unsigned(15 downto 0);
			--write_address : IN    unsigned(15 downto 0);
			--we            : IN  STD_LOGIC;
			data_out             : in   STD_LOGIC_VECTOR(15 DOWNTO 0)
		);
	end component sram;

	signal SRAM_OE_N : std_logic;
	signal SRAM_WE_N : std_logic;
	signal SRAM_CE_N : std_logic;
	signal SRAM_ADDR : std_logic_vector(19 downto 0);
	signal SRAM_DQ   : std_logic_vector(15 downto 0);
	signal SRAM_UB_N : std_logic;
	signal SRAM_LB_N : std_logic;
	--

	signal clk           : STD_LOGIC;
	signal chipselect    : STD_LOGIC;
	signal write         : STD_LOGIC;
	signal read			 : STD_LOGIC;
	signal address       : std_logic_vector(19 downto 0);
	signal data_in 		 : STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal data_out 		 : STD_LOGIC_VECTOR(15 DOWNTO 0);
	

begin
	
	dut: sram
	port map(
		SRAM_OE_N =>SRAM_OE_N,
		SRAM_WE_N => SRAM_WE_N,
		SRAM_CE_N => SRAM_CE_N,
		SRAM_ADDR => SRAM_ADDR,
		SRAM_DQ => SRAM_DQ,
		SRAM_UB_N => SRAM_UB_N,
		SRAM_LB_N => SRAM_LB_N,
		
		clk => clk,
		chipselect => chipselect,
		write => write,
		read => read,
		data_in => data_in,
		data_out => data_out,
		address => address
	);
	
	address <= "00000100001000000010";
	data_out <= "0010001000010001";
	chipselect <= '1';
	
	process
	begin
		clk       <= '0';
		
		wait for 10 ns;
		clk       <= '1';
		
		wait for 10 ns;
		clk       <= '0';
		write     <= '1';
		wait for 10 ns;
		clk       <= '1';
		
		wait for 10 ns;
		clk       <= '0';
		wait for 10 ns;
		clk       <= '1';
		
		wait for 10 ns;
		clk       <= '0';
		wait for 10 ns;
		clk       <= '1';
		
		wait for 10 ns;
		clk       <= '0';
		read     <= '1';
		wait for 10 ns;
		clk       <= '1';
		
		wait for 10 ns;
		clk       <= '0';
		read     <= '1';
		
		wait for 10 ns;
		clk       <= '1';
		
		wait for 10 ns;
		clk       <= '0';
		wait for 10 ns;
		clk       <= '1';
		
		wait for 10 ns;
		clk       <= '0';
		wait for 10 ns;
		clk       <= '1';
		
		wait for 10 ns;
		clk       <= '0';
		wait for 10 ns;
		clk       <= '1';
		
		wait for 10 ns;
		clk       <= '0';
		read     <= '1';
		wait for 10 ns;
		clk       <= '1';
		
		wait for 10 ns;
		clk       <= '0';
		read     <= '1';

		wait;
	end process;

end architecture RTL;
