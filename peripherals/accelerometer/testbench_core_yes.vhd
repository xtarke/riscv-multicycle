library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.decoder_types.all;

entity e_testbench is
  generic (
    --! Num of 32-bits memory words
    IMEMORY_WORDS : integer := 1024; --!= 4K (1024 * 4) bytes
    DMEMORY_WORDS : integer := 1024; --!= 2k (512 * 2) bytes
    constant SIZE : integer := 8 -- 8 bytes UART package
  );

  port (
    ----------- LEDR ------------
    LEDR : out std_logic_vector(9 downto 0);
    ----------- SEG7 ------------
    HEX0 : out std_logic_vector(7 downto 0);
    HEX1 : out std_logic_vector(7 downto 0);
    HEX2 : out std_logic_vector(7 downto 0);
    HEX3 : out std_logic_vector(7 downto 0);
    HEX4 : out std_logic_vector(7 downto 0);
    HEX5 : out std_logic_vector(7 downto 0);
    ----------- SW ------------
    SW : in std_logic_vector(9 downto 0); 
    ---------- ARDUINO IO -----
    ARDUINO_IO : inout std_logic_vector(15 downto 0)
  ); 
 
end entity e_testbench;

architecture rtl of e_testbench is

  constant MY_CHIPSELECT   : std_logic_vector(1 downto 0) :=  "10";
  constant MY_WORD_ADDRESS : std_logic_vector(7 downto 0) := x"10";

  signal clk             : std_logic;
  signal rst             : std_logic;
  signal idata           : std_logic_vector(31 downto 0);
  signal daddress        : natural;
  signal ddata_r         : std_logic_vector(31 downto 0);
  signal ddata_w         : std_logic_vector(31 downto 0);
  signal dmask           : std_logic_vector(3 downto 0);
  signal dcsel           : std_logic_vector(1 downto 0);
  signal d_we            : std_logic := '0';
  signal iaddress        : integer range 0 to IMEMORY_WORDS - 1 := 0;
  signal address         : std_logic_vector(31 downto 0);
  signal ddata_r_mem     : std_logic_vector(31 downto 0);
  signal d_rd            : std_logic;
  signal cpu_state       : cpu_state_t;
  signal debugString     : string(1 to 40) := (others => '0');
  signal dmemory_address : natural;
  signal d_sig           : std_logic;
 
  -- I/O signals
  signal input_in   : std_logic_vector(31 downto 0);
  signal interrupts : std_logic_vector(31 downto 0);

  -- accelerometer
  -- gpios input
  signal miso    : std_logic;
  signal mosi    : std_logic;
  signal sclk    : std_logic;
  signal ss_n    : std_logic;  
  -- result
  signal acceleration_x : STD_LOGIC_VECTOR(15 downto 0);
  signal acceleration_y : STD_LOGIC_VECTOR(15 downto 0);
  signal acceleration_z : STD_LOGIC_VECTOR(15 downto 0);

  begin

  -- instatiation: 32-bits x 1024 words quartus RAM
  e_iram_quartus : entity work.iram_quartus
    port map(
      address => address(9 downto 0), 
      byteena => "1111", 
      clock   => clk, 
      data    => (others => '0'), 
      wren    => '0', 
      q       => idata
    );

  -- instatiation: data nemory RAM
  e_data_memory : entity work.dmemory
    generic map(
      MEMORY_WORDS => DMEMORY_WORDS
    )
    port map(
      rst        => rst, 
      clk        => clk, 
      data       => ddata_w, 
      address    => dmemory_address, 
      we         => d_we, 
      signal_ext => d_sig, 
      csel       => dcsel(0), 
      dmask      => dmask, 
      q          => ddata_r_mem
    );

  -- instatiation: softcore
  e_softcore : entity work.core
    generic map(
      IMEMORY_WORDS => IMEMORY_WORDS, 
      DMEMORY_WORDS => DMEMORY_WORDS
    )
    port map(
      clk      => clk, 
      rst      => rst, 
      iaddress => iaddress, 
      idata    => idata, 
      daddress => daddress, 
      ddata_r  => ddata_r, 
      ddata_w  => ddata_w, 
      d_we     => d_we, 
      d_rd     => d_rd, 
      -- d_sig => d_sig,
      dcsel      => dcsel, 
      dmask      => dmask, 
      interrupts => interrupts, 
      state      => cpu_state
    );
 
  -- instatiation: accelerometer
  e_accel_bs : entity work.accel_bus_tb
    generic map(
      MY_CHIPSELECT   => MY_CHIPSELECT, 
      MY_WORD_ADDRESS => MY_WORD_ADDRESS
    )
    port map(
      -- core data bus
      daddress => daddress, 
      ddata_w  => ddata_w, 
      ddata_r  => ddata_r, 
      d_we     => d_we, 
      d_rd     => d_rd, 
      dcsel    => dcsel, 
      dmask    => dmask, 
      -- accelerometer spi
      clk            => clk, 
      rst            => rst,
      miso           => miso, 
      sclk           => sclk, 
      ss_n(0)        => ss_n, 
      mosi           => mosi, 
      -- accelerometer axes
      acceleration_x => acceleration_x, 
      acceleration_y => acceleration_y, 
      acceleration_z => acceleration_z
    );

  -- instatiation: file output debug
  e_debug : entity work.trace_debug
    generic map(
      MEMORY_WORDS => IMEMORY_WORDS
    )
    port map(
      pc   => iaddress, 
      data => idata, 
      inst => debugString
    );

  -- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
  -- sequential
  -- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----

  imem : process (d_rd, dcsel, daddress, iaddress)
    begin
    if (d_rd = '1') and (dcsel = "00") then
      address <= std_logic_vector(to_unsigned(daddress, 32));
    else
      address <= std_logic_vector(to_unsigned(iaddress, 32));
    end if;
  end process;

  clock : process
    constant period : time := 10 ns;
    begin
    clk <= '0'; wait for period / 2;
    clk <= '1'; wait for period / 2;
  end process;

  reset : process
    begin
    rst <= '1'; wait for 5 ns;
    rst <= '0'; wait;
  end process;

  -- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
  -- parallel
  -- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
  dmemory_address           <= to_integer(to_unsigned(daddress, 10));

  with dcsel select ddata_r <= 
              idata when "00", 
        ddata_r_mem when "01", 
           input_in when "10", 
    (others => '0') when others;

    -- turn off LED's 1 to 9
  LEDR(0) <= rst;
  LEDR(9 downto 1) <= (others =>'0');
  -- Turn off all HEX displays
  HEX0 <= (others => '0');
  HEX1 <= (others => '0');  
  HEX2 <= (others => '0');
  HEX3 <= (others => '0');
  HEX4 <= (others => '0');
  HEX5 <= (others => '0');

end architecture rtl;