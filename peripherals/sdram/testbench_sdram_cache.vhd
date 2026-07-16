-- SDRAM cache testbench: write through the cache, read it back through the cache.
--
-- The cache sits between a word-at-a-time user interface and the burst SDRAM
-- controller. This test drives only the user side:
--   1. push N words into the cache write port,
--   2. wait for the cache to flush them out to the SDRAM,
--   3. stream the same N words back through the cache read port and compare.
-- A match proves the data made a full round trip (cache -> controller -> SDRAM
-- -> controller -> cache). A single final assert reports pass/fail.
--
-- Note on write gating: the cache only drains its write FIFO once the read
-- prefetch FIFO holds at least 64 words (ALMOST_EMPTY_VALUE), so after pushing
-- the writes we wait a generous fixed time for the prefetch to fill and the
-- writes to reach SDRAM before reading back.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;

use work.sdram_pkg.all;

entity testbench_sdram_cache is
end entity testbench_sdram_cache;

architecture stimulus of testbench_sdram_cache is

  signal clk_sdram : std_logic;
  signal rst       : std_logic;

  -- Cache user side --
  signal read_enable  : std_logic;
  signal read_address : std_logic_vector(31 downto 0);
  signal read_data    : std_logic_vector(15 downto 0);
  signal read_lock    : std_logic;

  signal write_commit  : std_logic;
  signal write_address : std_logic_vector(31 downto 0);
  signal write_data    : std_logic_vector(15 downto 0);

  -- Cache <-> controller --
  signal sdram_addr        : std_logic_vector(31 downto 0);
  signal sdram_cs          : std_logic;
  signal sdram_read        : std_logic;
  signal sdram_write       : std_logic;
  signal sdram_write_data  : io_buffer_t;
  signal sdram_read_buffer : io_buffer_t;
  signal read_valid_count  : integer range 0 to 8;
  signal waitrequest       : std_logic;

  -- Controller <-> SDRAM model --
  signal DRAM_ADDR  : std_logic_vector(12 downto 0);
  signal DRAM_BA    : std_logic_vector(1 downto 0);
  signal DRAM_CAS_N : std_logic;
  signal DRAM_CKE   : std_logic;
  signal DRAM_CLK   : std_logic;
  signal DRAM_CS_N  : std_logic;
  signal DRAM_DQ    : std_logic_vector(15 downto 0);
  signal DRAM_DQM   : std_logic_vector(1 downto 0);
  signal DRAM_RAS_N : std_logic;
  signal DRAM_WE_N  : std_logic;

  constant CLK_PERIOD : time    := 10 ns;
  -- N_WORDS words starting at BASE_ADDR. BASE is 8-aligned (one read burst) and
  -- kept away from address 0 so the read-back forces a cache miss + refill.
  constant N_WORDS   : natural := 8;
  constant BASE_ADDR : natural := 16#100#;

  -- Each word carries its own address as data, so a mis-addressed access fails.
  function pattern(addr : natural) return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(addr, 16));
  end function pattern;

begin

  cache : entity work.sdram_cache
    port map(
      clk   => clk_sdram,
      reset => rst,

      read_enable  => read_enable,
      read_address => read_address,
      read_data    => read_data,
      read_lock    => read_lock,
      read_flush   => '0',

      write_commit           => write_commit,
      write_address          => write_address,
      write_data             => write_data,
      write_fifo_full        => open,
      write_fifo_almost_full => open,
      read_used              => open,

      sdram_read_buffer      => sdram_read_buffer,
      sdram_read_valid_count => read_valid_count,
      sdram_wait_request     => waitrequest,
      sdram_addr             => sdram_addr,
      sdram_read             => sdram_read,
      sdram_write            => sdram_write,
      sdram_write_data       => sdram_write_data,
      sdram_chip_select      => sdram_cs
    );

  sdram_controller : entity work.sdram_controller
    -- Micron sim model presents read data one cycle earlier than the real
    -- ISSI part, so DATA_AVAL is 1 in simulation (default 2 targets the HW).
    generic map(
      DATA_AVAL => 1
    )
    port map(
      address          => sdram_addr,
      byteenable       => "11",
      chipselect       => sdram_cs,
      clk              => clk_sdram,
      clken            => '1',
      reset            => rst,
      reset_req        => rst,
      write            => sdram_write,
      read             => sdram_read,
      write_data       => sdram_write_data,
      -- outputs:
      read_data        => sdram_read_buffer,
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
  begin
    -- Idle inputs and reset.
    read_enable   <= '0';
    read_address  <= (others => '0');
    write_commit  <= '0';
    write_address <= (others => '0');
    write_data    <= (others => '0');
    rst           <= '1';
    wait for 20 ns;
    rst <= '0';

    -- Let the controller finish its power-up / mode-register init.
    wait for 2 us;

    -- Write phase: push N words into the cache write port, one per clock.
    for i in 0 to N_WORDS - 1 loop
      write_address <= std_logic_vector(to_unsigned(BASE_ADDR + i, 32));
      write_data    <= pattern(BASE_ADDR + i);
      write_commit  <= '1';
      wait until rising_edge(clk_sdram);
    end loop;
    write_commit <= '0';

    -- Give the cache time to fill its read prefetch (which un-gates writes)
    -- and drain every queued word out to the SDRAM.
    wait for 20 us;

    -- Read phase: stream the words back. The first access to BASE_ADDR misses
    -- (read_lock high) and refills from SDRAM; then each word arrives on a
    -- cycle with read_lock low.
    read_address <= std_logic_vector(to_unsigned(BASE_ADDR, 32));
    read_enable  <= '1';
    -- Let the new address settle and the cache miss engage before polling,
    -- so we don't sample a stale word still sitting in the prefetch FIFO.
    wait until rising_edge(clk_sdram);
    for i in 0 to N_WORDS - 1 loop
      wait until rising_edge(clk_sdram) and read_lock = '0';
      if read_data /= pattern(BASE_ADDR + i) then
        error_count := error_count + 1;
        report "mismatch @ word " & integer'image(BASE_ADDR + i)
             & ": got " & to_hstring(read_data)
             & " expected " & to_hstring(pattern(BASE_ADDR + i))
          severity error;
      end if;
      read_address <= std_logic_vector(to_unsigned(BASE_ADDR + i + 1, 32));
    end loop;
    read_enable <= '0';

    assert error_count = 0
      report "SDRAM cache RW test FAILED: " & integer'image(error_count) & " mismatch(es)"
      severity failure;
    report "SDRAM cache RW test PASSED (" & integer'image(N_WORDS) & " words)"
      severity note;

    finish;
  end process stim;

end architecture stimulus;
