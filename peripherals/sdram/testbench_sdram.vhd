-- SDRAM controller testbench: sweep write / burst read.
--
-- The controller writes a single word per transaction (mode register A9 = 1,
-- write burst = single) but reads back an 8-word burst. So the test fills a
-- contiguous region one word at a time, then reads it back burst-by-burst and
-- compares every word. A single final assert reports pass/fail.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sdram_pkg.all;

entity testbench_sdram is
end entity testbench_sdram;

architecture stimulus of testbench_sdram is

  signal sdram_addr        : std_logic_vector(31 downto 0);
  signal chipselect_sdram  : std_logic;
  signal clk_sdram         : std_logic;
  signal rst               : std_logic;
  signal d_we              : std_logic;
  signal sdram_d_rd        : std_logic;
  signal ddata_w           : io_buffer_t;
  signal sdram_read        : io_buffer_t;
  signal read_valid_count  : integer range 0 to 8;
  signal waitrequest       : std_logic;
  signal DRAM_ADDR         : std_logic_vector(12 downto 0);
  signal DRAM_BA           : std_logic_vector(1 downto 0);
  signal DRAM_CAS_N        : std_logic;
  signal DRAM_CKE          : std_logic;
  signal DRAM_CLK          : std_logic;
  signal DRAM_CS_N         : std_logic;
  signal DRAM_DQ           : std_logic_vector(15 downto 0);
  signal DRAM_DQM          : std_logic_vector(1 downto 0);
  signal DRAM_RAS_N        : std_logic;
  signal DRAM_WE_N         : std_logic;

  constant CLK_PERIOD : time    := 10 ns;
  -- Region under test: NUM_BURSTS * 8 contiguous words starting at BASE_ADDR.
  constant NUM_BURSTS : natural := 8;
  constant NUM_WORDS  : natural := NUM_BURSTS * 8;
  constant BASE_ADDR  : natural := 0;

  -- Each word reads back its own address, so a mis-addressed write can't pass.
  function pattern(addr : natural) return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(addr, 16));
  end function pattern;

begin

  dut : entity work.sdram_controller
    -- Micron sim model presents read data one cycle earlier than the real
    -- ISSI part, so DATA_AVAL is 1 in simulation (default 2 targets the HW).
    generic map(
      DATA_AVAL => 1
    )
    port map(
      address          => sdram_addr,
      byteenable       => "11",
      chipselect       => chipselect_sdram,
      clk              => clk_sdram,
      clken            => '1',
      reset            => rst,
      reset_req        => rst,
      write            => d_we,
      read             => sdram_d_rd,
      write_data       => ddata_w,
      -- outputs:
      read_data        => sdram_read,
      read_valid_count => read_valid_count,
      waitrequest      => waitrequest,
      DRAM_ADDR        => DRAM_ADDR,
      DRAM_BA          => DRAM_BA,
      DRAM_CAS_N       => DRAM_CAS_N,
      DRAM_CKE         => DRAM_CKE,
      DRAM_CLK         => DRAM_CLK,
      DRAM_CS_N        => DRAM_CS_N,
      DRAM_DQ          => DRAM_DQ,
      DRAM_DQM         => DRAM_DQM,
      DRAM_RAS_N       => DRAM_RAS_N,
      DRAM_WE_N        => DRAM_WE_N
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
  begin
    clk_sdram <= '0';
    wait for CLK_PERIOD / 2;
    clk_sdram <= '1';
    wait for CLK_PERIOD / 2;
  end process clock_driver;

  stim : process
    variable error_count : natural := 0;
    variable rbuf        : io_buffer_t;
    variable expected    : std_logic_vector(15 downto 0);

    procedure do_write(addr : in natural; value : in std_logic_vector(15 downto 0)) is
    begin
      sdram_addr       <= std_logic_vector(to_unsigned(addr, 32));
      ddata_w          <= (0 => value, others => (others => '0'));
      chipselect_sdram <= '1';
      d_we             <= '1';
      wait until waitrequest = '0';
      d_we             <= '0';
      chipselect_sdram <= '0';
      wait until waitrequest = '0';
    end procedure do_write;

    -- 8-word burst read starting at base. read_data holds all 8 words by DONE.
    procedure do_read(base : in natural; buf : out io_buffer_t) is
    begin
      sdram_addr       <= std_logic_vector(to_unsigned(base, 32));
      chipselect_sdram <= '1';
      sdram_d_rd       <= '1';
      wait until waitrequest = '0';
      buf              := sdram_read;
      sdram_d_rd       <= '0';
      chipselect_sdram <= '0';
      wait until waitrequest = '0';
    end procedure do_read;

  begin
    -- Idle inputs and reset.
    sdram_addr       <= (others => '0');
    chipselect_sdram <= '0';
    rst              <= '1';
    d_we             <= '0';
    sdram_d_rd       <= '0';
    ddata_w          <= (others => (others => '0'));
    wait for 20 ns;
    rst <= '0';

    -- Let the power-up / mode-register init sequence finish and reach IDLE.
    wait for 2 us;

    -- Write phase: fill the region one word at a time.
    for i in 0 to NUM_WORDS - 1 loop
      do_write(BASE_ADDR + i, pattern(BASE_ADDR + i));
    end loop;

    -- Read phase: read back burst-by-burst and compare every word.
    for b in 0 to NUM_BURSTS - 1 loop
      do_read(BASE_ADDR + b * 8, rbuf);
      for j in 0 to 7 loop
        expected := pattern(BASE_ADDR + b * 8 + j);
        if rbuf(j) /= expected then
          error_count := error_count + 1;
          report "mismatch @ word " & integer'image(BASE_ADDR + b * 8 + j)
               & ": got " & integer'image(to_integer(unsigned(rbuf(j))))
               & " expected " & integer'image(to_integer(unsigned(expected)))
            severity error;
        end if;
      end loop;
    end loop;

    assert error_count = 0
      report "SDRAM RW sweep FAILED: " & integer'image(error_count) & " mismatch(es)"
      severity failure;
    report "SDRAM RW sweep PASSED (" & integer'image(NUM_WORDS) & " words)"
      severity note;

    wait;
  end process stim;

end architecture stimulus;
