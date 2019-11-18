library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench_sdram is
end entity testbench_sdram;

architecture RTL of testbench_sdram is
	signal sdram_addr       : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal chipselect_sdram : STD_LOGIC;
	signal clk_sdram        : STD_LOGIC;
	signal rst              : STD_LOGIC;
	signal d_we             : STD_LOGIC;
	signal sdram_d_rd       : std_logic;
	signal ddata_w          : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal burst            : std_logic;
	signal sdram_read       : STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal waitrequest      : std_logic;
	signal DRAM_ADDR        : std_logic_vector(12 downto 0);
	signal DRAM_BA          : std_logic_vector(1 downto 0);
	signal DRAM_CAS_N       : std_logic;
	signal DRAM_CKE         : std_logic;
	signal DRAM_CLK         : std_logic;
	signal DRAM_CS_N        : std_logic;
	signal DRAM_DQ          : std_logic_vector(15 downto 0);
	signal DRAM_DQM         : std_logic_vector(1 downto 0);
	signal DRAM_RAS_N       : std_logic;
	signal DRAM_WE_N        : std_logic;

begin

	-- SDRAM instatiation
	sdram_controller : entity work.sdram_controller
		port map(
			address     => sdram_addr,
			byteenable  => "11",
			chipselect  => chipselect_sdram,
			clk         => clk_sdram,
			clken       => '1',
			reset       => rst,
			reset_req   => rst,
			write       => d_we,
			read        => sdram_d_rd,
			writedata   => ddata_w,
			burst       => burst,
			-- outputs:
			readdata    => sdram_read,
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

	-- SDRAM model instatiation
	sdram : entity work.mt48lc8m16a2
		generic map(
			addr_bits => 13
		)
		port map(
			Dq    => DRAM_DQ,
			Addr  => DRAM_ADDR,
			Ba    => DRAM_BA,
			Clk   => clk_sdram,
			Cke   => DRAM_CKE,
			Cs_n  => DRAM_CS_N,
			Ras_n => DRAM_RAS_N,
			Cas_n => DRAM_CAS_N,
			We_n  => DRAM_WE_N,
			Dqm   => DRAM_DQM
		);

	clock_driver : process
		constant period : time := 5 ns;
	begin
		clk_sdram <= '0';
		wait for period / 2;
		clk_sdram <= '1';
		wait for period / 2;
	end process clock_driver;

	end_gen : process
	begin
		sdram_addr    <= x"00000000";
		chipselect_sdram <= '1';
		rst      		<= '1';
		d_we             <= '0';
		sdram_d_rd       <= '0';
		ddata_w  <= x"00000004";
		burst <= '1';
		wait for 10 ns;
		rst      <= '0';
		wait for 200 ns;
		burst <= '0';
		wait for 500 ns;
		
		d_we      	<= '1';
		ddata_w  	<= x"00001234";
		sdram_addr    <= x"00000000";
		wait for 200 ns;
		d_we      <= '0';
		wait for 200 ns;
		
		sdram_d_rd     <= '1';
		sdram_addr    <= x"00000000";
		wait for 200 ns;
		sdram_d_rd     <= '0';
		wait for 200 ns;
		
		d_we      <= '1';
		ddata_w  	<= x"00000001";
		sdram_addr    <= x"00000001";
		wait for 200 ns;
		d_we      <= '0';
		wait for 200 ns;
		
		sdram_d_rd     <= '1';
		sdram_addr    <= x"00000001";
		wait for 200 ns;
		sdram_d_rd     <= '0';
		wait for 200 ns;
		
		d_we      <= '1';
		ddata_w  	<= x"00000003";
		sdram_addr    <= x"00000003";
		wait for 200 ns;
		d_we      <= '0';
		wait for 200 ns;
		
		sdram_d_rd     <= '1';
		sdram_addr    <= x"00000003";
		wait for 200 ns;
		sdram_d_rd     <= '0';
		wait for 200 ns;

		wait;
	end process;

end architecture RTL;
