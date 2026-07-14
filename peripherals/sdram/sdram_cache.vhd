library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

use work.sdram_pkg.all;


entity sdram_cache is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    -- Read domain --
    read_enable  : in  std_logic;
    read_address : in  std_logic_vector(31 downto 0);
    read_data    : out std_logic_vector(15 downto 0);
    read_lock    : out std_logic;

    -- Write domain --
    write_commit    : in  std_logic;
    write_address   : in  std_logic_vector(31 downto 0);
    write_data      : in  std_logic_vector(15 downto 0);
    write_fifo_full : out std_logic;
    write_fifo_almost_full : out std_logic;

    read_used       : out std_logic_vector(8 downto 0);

    -- SDRAM signals --
    sdram_read_buffer      : in  io_buffer_t;
    sdram_read_valid_count : in  integer range 0 to 8;
    sdram_wait_request     : in  std_logic;
    sdram_addr             : out std_logic_vector(31 downto 0);
    sdram_read             : out std_logic;
    sdram_write            : out std_logic;
    sdram_write_data       : out io_buffer_t;
    sdram_chip_select      : out std_logic
  );
end entity sdram_cache;

architecture sdram_cache_behavior of sdram_cache is

  type cache_state_t is (
    CACHE_STATE_INIT,
    CACHE_STATE_IDLE,
    CACHE_STATE_READING,
    CACHE_STATE_WRITING,
    CACHE_STATE_RX_CACHE_MISS
  );

  constant READ_FIFO_SIZE : natural := 512;
  constant WRITE_FIFO_SIZE : natural := 16;
  
  constant SDRAM_READ_BURST_SIZE : natural := 8;

  -- Write post FIFO (fifo_16): 48-bit {addr(31:0), data(15:0)}, depth 16
  signal write_fifo_data_in  : std_logic_vector(47 downto 0);
  signal write_fifo_data_out : std_logic_vector(47 downto 0);
  signal write_fifo_push     : std_logic;
  signal write_fifo_pop      : std_logic;
  signal write_fifo_empty    : std_logic;
  signal write_full          : std_logic;
  signal write_fifo_used     : std_logic_vector(3 downto 0);

  -- Read FIFO (fifo_512): 16-bit, depth 512
  signal read_fifo_data_in   : std_logic_vector(15 downto 0);
  signal read_fifo_data_out  : std_logic_vector(15 downto 0);
  signal read_fifo_push      : std_logic;
  signal read_fifo_pop       : std_logic;
  signal read_fifo_empty     : std_logic;
  signal read_fifo_full      : std_logic;
  signal read_fifo_almost_empty : std_logic;
  signal read_fifo_used      : std_logic_vector(8 downto 0);
  signal read_fifo_reset     : std_logic;

  -- Address of the sdram that the head points --
  signal read_fifo_head_address : std_logic_vector(31 downto 0);

  -- Next sdram address to burst read into the read fifo --
  signal read_burst_address : std_logic_vector(31 downto 0);
  -- Words of the current burst already pushed into the read fifo --
  signal read_words_pushed  : integer range 0 to 8;
  -- Gate: only unload once a fresh transaction boundary is seen after reset --
  signal read_unload_armed  : std_logic;
  
  signal rx_cache_miss       : std_logic;
  signal read_hit            : std_logic;

  signal cache_state         : cache_state_t;

begin

  write_fifo : entity work.fifo_16
    port map (
      clock       => clk,
      sclr        => reset,
      data        => write_fifo_data_in,
      wrreq       => write_fifo_push,
      rdreq       => write_fifo_pop,
      q           => write_fifo_data_out,
      empty       => write_fifo_empty,
      full        => write_full,
      almost_full => write_fifo_almost_full,
      usedw       => write_fifo_used
    );

  write_fifo_full     <= '1' when write_full = '1' or write_fifo_used >= WRITE_FIFO_SIZE - 1 else '0';
  write_fifo_push     <= write_commit and (not write_full);
  write_fifo_data_in  <= write_address & write_data;

  read_used <= read_fifo_used;

  read_fifo : entity work.fifo_512
    port map (
      clock        => clk,
      sclr         => read_fifo_reset,
      data         => read_fifo_data_in,
      wrreq        => read_fifo_push,
      rdreq        => read_fifo_pop,
      q            => read_fifo_data_out,
      empty        => read_fifo_empty,
      full         => read_fifo_full,
      almost_empty => read_fifo_almost_empty,
      usedw        => read_fifo_used
    );

  read_hit      <= '1' when read_fifo_head_address = read_address and read_fifo_empty = '0' else '0';
  rx_cache_miss <= read_enable when read_fifo_head_address /= read_address else '0';
  read_fifo_pop <= read_enable and read_hit;
  read_data     <= read_fifo_data_out;
  read_lock     <= read_enable and (not read_hit);

  process (clk, reset)
  begin
    if reset = '1' then
      read_fifo_reset <= '1';
      cache_state <= CACHE_STATE_INIT;
      read_burst_address <= (others => '0');
      sdram_addr <= (others => '0');
      sdram_write_data <= (others => (others => '0'));
      write_fifo_pop <= '0';
    elsif rising_edge(clk) then
      read_fifo_reset <= '0';
      write_fifo_pop <= '0';
      case cache_state is
        when CACHE_STATE_INIT =>
          cache_state <= CACHE_STATE_IDLE;
        when CACHE_STATE_IDLE =>

          -- If idle and nothing to do fill the read fifo cache --
          if read_fifo_used < (READ_FIFO_SIZE - SDRAM_READ_BURST_SIZE) then
            sdram_addr <= read_burst_address;
            cache_state <= CACHE_STATE_READING;
          end if;

          -- Only start writing when read fifo has enough data --
          if write_fifo_empty = '0' and read_fifo_almost_empty = '0' then
            sdram_addr <= write_fifo_data_out(47 downto 16);
            sdram_write_data(0) <= write_fifo_data_out(15 downto 0);
            cache_state <= CACHE_STATE_WRITING;
          end if;

          -- Cache miss: flush the cached data and refill from the missed address --
          if rx_cache_miss = '1' then
            read_fifo_reset <= '1';
            read_burst_address <= read_address;
            cache_state <= CACHE_STATE_RX_CACHE_MISS;
          end if;
        when CACHE_STATE_READING =>
          -- Burst done: advance to the next burst address --
          if sdram_wait_request = '0' then
            read_burst_address <= read_burst_address + SDRAM_READ_BURST_SIZE;
            cache_state <= CACHE_STATE_IDLE;
          end if;
        when CACHE_STATE_WRITING =>
          if sdram_wait_request = '0' then
            write_fifo_pop <= '1';
            cache_state <= CACHE_STATE_IDLE;
          end if;
        when CACHE_STATE_RX_CACHE_MISS =>
          -- Wait until the flush emptied the read fifo --
          if read_fifo_used = 0 then
            cache_state <= CACHE_STATE_IDLE;
          end if;
      end case;
    end if;
  end process;

  -- User side read: track the sdram address cached at the fifo head --
  process (clk, reset)
  begin
    if reset = '1' then
      read_fifo_head_address <= (others => '0');
    elsif rising_edge(clk) then
      if cache_state = CACHE_STATE_RX_CACHE_MISS and read_fifo_used = 0 then
        read_fifo_head_address <= read_address;
      elsif read_fifo_pop = '1' then
        read_fifo_head_address <= read_fifo_head_address + 1;
      end if;
    end if;
  end process;

  -- Read process: push burst words into the read fifo as they arrive --
  process (clk, reset)
  begin
    if reset = '1' then
      read_fifo_push <= '0';
      read_words_pushed <= 0;
      read_unload_armed <= '0';
    elsif rising_edge(clk) then
      read_fifo_push <= '0';
      if sdram_read_valid_count = 0 then
        read_words_pushed <= 0;
        read_unload_armed <= '1';
      elsif read_unload_armed = '1' and read_words_pushed < sdram_read_valid_count then
        read_fifo_data_in <= sdram_read_buffer(read_words_pushed);
        read_fifo_push <= '1';
        read_words_pushed <= read_words_pushed + 1;
      end if;
    end if;
  end process;

  process (cache_state)
  begin
    case cache_state is
      when CACHE_STATE_READING =>
        sdram_read <= '1';
        sdram_chip_select <= '1';
      when CACHE_STATE_WRITING =>
        sdram_write <= '1';
        sdram_chip_select <= '1';
      when others =>
        sdram_read <= '0';
        sdram_write <= '0';
        sdram_chip_select <= '0';
    end case;
  end process;

end sdram_cache_behavior;





