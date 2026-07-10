library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sdram_pkg.all;

entity testbench_sdram is
end entity testbench_sdram;

architecture RTL of testbench_sdram is
	signal sdram_addr       : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal chipselect_sdram : STD_LOGIC;
	signal clk_sdram        : STD_LOGIC;
	signal rst              : STD_LOGIC;
	signal d_we             : STD_LOGIC;
	signal sdram_d_rd       : std_logic;
	signal ddata_w          : io_buffer_t;
	signal sdram_read       : io_buffer_t;
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

	constant TEST_PATTERN : io_buffer_t := (
		x"1111", x"2222", x"3333", x"4444",
		x"5555", x"6666", x"7777", x"8888"
	);

begin

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
			write_data  => ddata_w,
			-- outputs:
			read_data   => sdram_read,
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

	-- SDRAM model
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
		constant period : time := 10 ns;
	begin
		clk_sdram <= '0';
		wait for period / 2;
		clk_sdram <= '1';
		wait for period / 2;
	end process clock_driver;

	process
	begin
		sdram_addr       <= x"00000000";
		chipselect_sdram <= '1';
		rst              <= '1';
		d_we             <= '0';
		sdram_d_rd       <= '0';
		ddata_w          <= (others => (others => '0'));
		wait for 20 ns;
		rst <= '0';
		wait for 1000 ns;

		-- write burst
		ddata_w    <= TEST_PATTERN;
		sdram_addr <= x"00000000";
		d_we       <= '1';
		wait for 400 ns;
		d_we       <= '0';
		wait for 200 ns;

		-- read burst
		sdram_addr <= x"00000000";
		sdram_d_rd <= '1';
		wait for 400 ns;
		sdram_d_rd <= '0';
		wait for 200 ns;

		-- check read back equals written
		for i in 0 to 7 loop
			assert sdram_read(i) = TEST_PATTERN(i)
				report "word " & integer'image(i) & " mismatch: got " & to_hstring(sdram_read(i)) & " expected " & to_hstring(TEST_PATTERN(i))
				severity error;
		end loop;
		assert sdram_read /= TEST_PATTERN
			report "PASS: read data matches written data"
			severity note;

		wait;
	end process;

end architecture RTL;
