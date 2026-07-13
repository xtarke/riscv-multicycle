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

    -- SDRAM signals --
    sdram_read_buffer  : in  io_buffer_t;
    sdram_wait_request : in  std_logic;
    sdram_addr         : out std_logic_vector(31 downto 0);
    sdram_chip_select  : out std_logic
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
  signal write_fifo_almost_full : std_logic;
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
  signal read_fifo_head_address : std_logic_vector(32 downto 0);
  
  signal rx_cache_miss       : std_logic;

  signal cache_state         : cache_state_t

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

  write_fifo_full     <= write_full;
  write_fifo_push     <= write_commit and (not write_full);
  write_fifo_data_in  <= write_address & write_data;

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

  process (clk, reset)
  begin
    if (reset) then
      read_fifo_reset <= '1';
    elsif rising_edge(clk) then
      read_fifo_reset <= '0';
      case cache_state is
        when CACHE_STATE_INIT =>
          cache_state <= CACHE_STATE_IDLE;
        when CACHE_STATE_IDLE =>
          -- If idle and nothing to do fill the read fifo cache --
          if read_fifo_used < (READ_FIFO_SIZE - SDRAM_READ_BURST_SIZE) then
            cache_state <= CACHE_STATE_READING;
          end if;
          
          -- Only start writing when read fifo has enough data --
          if write_fifo_used /= 0 and read_fifo_almost_empty /= 0 then
            cache_state <= CACHE_STATE_WRITING;
          end if;
        when CACHE_STATE_READING =>
          if sdram_wait_request = '0' then
            cache_state <= CACHE_STATE_IDLE;
          end if;
        when CACHE_STATE_WRITING =>
          if sdram_wait_request = '0' then
            cache_state <= CACHE_STATE_IDLE;
          end if;
        when CACHE_STATE_RX_CACHE_MISS => 
          -- Reset rx fifo for one cycle and start populating --
          if (usedw = 0) then
            cache_state <= CACHE_STATE_IDLE;
          end if;
      end case;
    end if;



  end process;

end sdram_cache_behavior;





