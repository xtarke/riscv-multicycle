-- SDRAM cache testbench: write N words through the cache, read them back
-- through the cache, and check they match. A match proves the full round trip
-- cache -> controller -> SDRAM -> controller -> cache.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
  -- N_WORDS words at BASE_ADDR. BASE is 8-aligned and away from 0 so the
  -- read-back forces a cache miss + refill (instead of hitting stale prefetch).
  constant N_WORDS   : natural := 8;
  constant BASE_ADDR : natural := 16#100#;

  function addr(a : natural) return std_logic_vector is   -- 32-bit cache address
  begin return std_logic_vector(to_unsigned(a, 32)); end function;

  function pattern(a : natural) return std_logic_vector is -- 16-bit data = address
  begin return std_logic_vector(to_unsigned(a, 16)); end function;

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
    -- DATA_AVAL = 1 matches the Micron sim model (real ISSI part uses 2).
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
  begin
    -- Reset, then let the controller finish its power-up / init sequence.
    read_enable  <= '0';
    write_commit <= '0';
    rst          <= '1';
    wait for 20 ns;
    rst <= '0';
    wait for 2 us;

    -- Write N words through the cache, one commit per clock.
    for i in 0 to N_WORDS - 1 loop
      write_address <= addr(BASE_ADDR + i);
      write_data    <= pattern(BASE_ADDR + i);
      write_commit  <= '1';
      wait until rising_edge(clk_sdram);
    end loop;
    write_commit <= '0';

    -- Writes only drain once the read prefetch fifo is full; give it time.
    wait for 20 us;

    -- Read the words back. The stream is continuous: hold read_enable high and
    -- step read_address; each hit delivers one word (read_lock low).
    read_address <= addr(BASE_ADDR);
    read_enable  <= '1';
    wait until rising_edge(clk_sdram);   -- let the miss engage before polling
    for i in 0 to N_WORDS - 1 loop
      wait until rising_edge(clk_sdram) and read_lock = '0';
      assert read_data = pattern(BASE_ADDR + i)
        report "word " & integer'image(BASE_ADDR + i) & " mismatch: got "
             & integer'image(to_integer(unsigned(read_data)))
        severity failure;
      read_address <= addr(BASE_ADDR + i + 1);
    end loop;

    report "SDRAM cache RW test PASSED (" & integer'image(N_WORDS) & " words)"
      severity note;
    wait;
  end process stim;

end architecture stimulus;
