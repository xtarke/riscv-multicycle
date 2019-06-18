library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench_sdram is
end entity testbench_sdram;

architecture RTL of testbench_sdram is

	  -- inputs:
	signal  address 		: std_logic_vector (31 DOWNTO 0);
	signal  byteenable  : std_logic_vector (3 DOWNTO 0);
	signal  chipselect 	: std_logic;
	signal  clk 				: std_logic;
  signal  clk2        : std_logic := '0';
	signal  reset 			: std_logic;
	signal  reset_req 	: std_logic;
	signal  write 			: std_logic;
	signal  read				: std_logic;
	signal  writedata 	: std_logic_vector (31 DOWNTO 0);
	
	  -- outputs:
	signal  readdata 		: std_logic_vector (31 DOWNTO 0);
	signal  waitrequest : std_logic;
  
	signal  DRAM_ADDR   : std_logic_vector( 12  downto 0  );
  signal  DRAM_BA     : std_logic_vector( 1  downto 0  );
  signal  DRAM_CAS_N  : std_logic;
  signal  DRAM_CKE    : std_logic;
  signal  DRAM_CLK    : std_logic;
  signal  DRAM_CS_N   : std_logic;
  signal  DRAM_DQ     : std_logic_vector( 31  downto 0  );
  signal  DRAM_DQM    : std_logic_vector( 3  downto 0  );
  signal  DRAM_RAS_N  : std_logic;
  signal  DRAM_WE_N   : std_logic;



begin

  sdram_controller_0 : entity work.sdram_controller
  port map(
    address 		=> address,
	  byteenable  => byteenable,
	  chipselect 	=> chipselect,
	  clk 				=> clk,
	  clken 			=> '1',
	  reset 			=> reset,
	  reset_req 	=> reset_req,
	  write 			=> write,
	  read				=> read,
	  writedata 	=> writedata,
	
	  -- outputs:
	  readdata 		=> readdata,
	  waitrequest => waitrequest,
	  
	  DRAM_ADDR   => DRAM_ADDR,
    DRAM_BA     => DRAM_BA,
    DRAM_CAS_N  => DRAM_CAS_N,
    DRAM_CKE    => DRAM_CKE,
    DRAM_CLK    => DRAM_CLK,
    DRAM_CS_N   => DRAM_CS_N,
    DRAM_DQ     => DRAM_DQ,
    DRAM_DQM    => DRAM_DQM,
    DRAM_RAS_N  => DRAM_RAS_N,
    DRAM_WE_N   => DRAM_WE_N
  );

  sdram : entity work.mt48lc8m16a2
  port map(
        Dq    => DRAM_DQ(15 downto 0),
        Addr  => DRAM_ADDR(11 downto 0),
        Ba    => DRAM_BA,
        Clk   => clk2,
        Cke   => DRAM_CKE,
        Cs_n  => DRAM_CS_N,
        Ras_n => DRAM_RAS_N,
        Cas_n => DRAM_CAS_N,
        We_n  => DRAM_WE_N,
        Dqm   => DRAM_DQM(1 downto 0)
  );


  clock_driver : process
		constant period : time := 10 ns;
	begin
		clk <= '0';
		wait for period / 2;
		clk <= '1';
		wait for period / 2;
	end process clock_driver;

	end_gen : process
	begin
    address     <= x"00000002";
	  byteenable  <= "1111";
	  chipselect  <= '0';
	  reset 		  <= '1';
	  reset_req   <= '0';
	  write 		  <= '0';
	  read			  <= '0';
	  writedata   <= x"00000004";
    wait for 30 ns;
    reset 		  <= '0';
    wait for 180 ns;
    write 		  <= '1';
    chipselect  <= '1';
    wait for 40 ns;
    write 		  <= '0';
    chipselect  <= '0';
    wait for 100 ns;
    read 		  <= '1';
    chipselect  <= '1';
    wait for 50 ns;
    read 		  <= '0';
    chipselect  <= '0';
    wait;
	end process;




  process
    begin   
         clk2 <= '0';
         wait for 4000 ps;
         clk2 <= '1';
         wait for 5000 ps;
         clk2 <= '0';
         wait for 1000 ps;
  end process;

end architecture RTL;
