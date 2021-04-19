
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use work.decoder_types.all;

entity de10_lite is
  generic (
    --! Num of 32-bits memory words
    IMEMORY_WORDS : integer := 1024;  --!= 4K (1024 * 4) bytes
    DMEMORY_WORDS : integer := 1024   --!= 2k ( 512 * 2) bytes
  );
  port (
	 -- clk input for PLL
    MAX10_CLK1_50: in std_logic;
	 --spi accelerometer
    GSENSOR_INT:  in std_logic_vector(2 downto 1);
    GSENSOR_CS_N: out std_logic;
    GSENSOR_SCLK: out std_logic;
    GSENSOR_SDI: inout std_logic;
    GSENSOR_SDO: inout std_logic;
	 -- displays 7 seg
    HEX0: out std_logic_vector(7 downto 0);
    HEX1: out std_logic_vector(7 downto 0);
    HEX2: out std_logic_vector(7 downto 0);
    HEX3: out std_logic_vector(7 downto 0);
    HEX4: out std_logic_vector(7 downto 0);
    HEX5: out std_logic_vector(7 downto 0);
    -- key for change axi
    KEY: in std_logic_vector(0 downto 0);
	 -- led for reset
    LEDR: out std_logic_vector(9 downto 0);
	 -- sw for reset
    SW:    in std_logic_vector(9 downto 0)
   );
end de10_lite;

architecture rtl of de10_lite is

  -- chip select
  constant MY_CHIPSELECT   : std_logic_vector(1 downto 0) :=  "10";
  constant MY_WORD_ADDRESS : std_logic_vector(7 downto 0) := x"10";

  -- basic required
  signal clk : std_logic;
  signal rst : std_logic;

  -- instruction bus signals
  signal idata     : std_logic_vector(31 downto 0);
  signal iaddress  : integer range 0 to IMEMORY_WORDS-1 := 0;
  signal address   : std_logic_vector (9 downto 0);

  -- data bus signals
  signal daddress : integer range 0 to DMEMORY_WORDS-1;
  signal ddata_r	: std_logic_vector(31 downto 0);
  signal ddata_w  :	std_logic_vector(31 downto 0);
  signal dmask    : std_logic_vector(3 downto 0);
  signal dcsel    : std_logic_vector(1 downto 0);
  signal d_we     : std_logic := '0';

  signal ddata_r_mem : std_logic_vector(31 downto 0);
  signal d_rd : std_logic;

  -- I/O signals
  signal input_in	: std_logic_vector(31 downto 0);

  -- SDRAM signals
  signal ddata_r_sdram : std_logic_vector(31 downto 0);

  -- PLL signals
  signal locked_sig : std_logic;

  -- CPU state signals
  -- type cpu_state_t is (halted, error);
  signal state : cpu_state_t;
  signal d_sig : std_logic;

  -- I/O signals
  	signal gpio_input      : std_logic_vector(31 downto 0);
	signal gpio_output     : std_logic_vector(31 downto 0);


  -- peripheral data signals
  signal ddata_r_gpio : std_logic_vector(31 downto 0);
  signal ddata_r_periph : std_logic_vector(31 downto 0);
  signal ddata_r_accelerometer : std_logic_vector(31 downto 0);
  
  -- interrupt Signals
	signal interrupts      : std_logic_vector(31 downto 0);
	signal gpio_interrupts : std_logic_vector(6 downto 0);
	
	-- accelerometer 
	signal axi_x : std_logic_vector(15 DOWNTO 0);
	signal axi_y : std_logic_vector(15 DOWNTO 0);
	signal axi_z : std_logic_vector(15 DOWNTO 0);
	signal axi_disp : std_logic_vector(15 DOWNTO 0);

	-- for conv bin to bcd to 7seg
	signal data_bcd_x : unsigned(15 downto 0);
	signal data_bcd_y : unsigned(15 downto 0);

  -- switch between data sent or not by the core bus
	signal sw_debug : std_logic;

begin
  
  -- instatiation: pll
  e_pll: entity work.pll
    port map(
      areset => '0',
      inclk0 => MAX10_CLK1_50,
      c0     => clk,
      locked => locked_sig
    );
  
  -- instatiation: instruction MUX
  e_mux: entity work.instructionbusmux
    generic map(
      IMEMORY_WORDS => IMEMORY_WORDS,
      DMEMORY_WORDS => DMEMORY_WORDS
    )
    port map(
      d_rd     => d_rd,
      dcsel    => dcsel,
      daddress => daddress,
      iaddress => iaddress,
      address  => address
    );

  -- instatiation: quartus RAM
  e_quartus_ram: entity work.iram_quartus
      port map(
        address => address,
        byteena => "1111",
        clock   => clk,
        data    => (others => '0'),
        wren    => '0',
        q       => idata
      );

  -- instatiation: memory RAM
  e_memory_ram: entity work.dmemory
    generic map(
      MEMORY_WORDS => DMEMORY_WORDS
    )
    port map(
      rst        => rst,
      clk        => clk,
      data       => ddata_w,
      address    => daddress,
      we         => d_we,
      csel       => dcsel(0),
      dmask      => dmask,
      signal_ext => d_sig,
      q          => ddata_r_mem
    );

  -- instatiation: data bus MUX
  e_datamux: entity work.databusmux
    port map(
      dcsel          => dcsel,
      idata          => idata,
      ddata_r_mem    => ddata_r_mem,
      ddata_r_periph => ddata_r_periph,
      ddata_r_sdram  => ddata_r_sdram,
      ddata_r        => ddata_r
    );

  -- #define IONBUS_BASE_ADDRESS        (*(_IO32 *) (PERIPH_BASE))
  -- #define ACCELEROMETER_BASE_ADDRESS (*(_IO32 *) (PERIPH_BASE + 8*16*4))
  with to_unsigned(daddress,16)(15 downto 4) select 
      ddata_r_periph <= ddata_r_gpio when x"000",
							 ddata_r_accelerometer when x"008",	
                     (others => '0') when others;

  -- instatiation: softcore
  e_softcore: entity work.core
    generic map(
      IMEMORY_WORDS => IMEMORY_WORDS,
      DMEMORY_WORDS => DMEMORY_WORDS
    )
    port map(
      clk        => clk,
      rst        => rst,
      iaddress   => iaddress,
      idata      => idata,
      daddress   => daddress,
      ddata_r    => ddata_r,
      ddata_w    => ddata_w,
      d_we       => d_we,
      d_rd       => d_rd,
      dcsel      => dcsel,
      dmask      => dmask,
      interrupts => interrupts,
      state      => state
    );

	-- instatiation: GPIO 
	e_gpio: entity work.gpio
		generic map(
			MY_CHIPSELECT   => MY_CHIPSELECT,
			MY_WORD_ADDRESS => MY_WORD_ADDRESS
		)
		port map(
			clk      => clk,
			rst      => rst,
			daddress => daddress,
			ddata_w  => ddata_w,
			ddata_r  => ddata_r_gpio,
			d_we     => d_we,
			d_rd     => d_rd,
			dcsel    => dcsel,
			dmask    => dmask,
			input    => gpio_input,
			output   => gpio_output,
			gpio_interrupts => gpio_interrupts
		);	 
	 
  -- instatiation: accelerometer
  e_accelerometer: entity work.accel_bus
    generic map(
      MY_CHIPSELECT   => MY_CHIPSELECT,
      MY_WORD_ADDRESS => MY_WORD_ADDRESS
    )
    port map(
      -- core data bus
      daddress => daddress, 
      ddata_w  => ddata_w, 
      ddata_r  => ddata_r_accelerometer, 
      d_we     => d_we, 
      d_rd     => d_rd, 
      dcsel    => dcsel, 
      dmask    => dmask,
      -- accelerometer spi
      clk      => clk,
      rst      => rst,
      miso     => GSENSOR_SDO,
      sclk     => GSENSOR_SCLK,
      ss_n(0)  => GSENSOR_CS_N,
      mosi     => GSENSOR_SDI,
      -- accelerometer axis
      axi_x    => axi_x, 
      axi_y    => axi_y, 
      axi_z    => axi_z
    );

  -- turn off LEDR not used
  LEDR(8 downto 1) <= (others => '0');
  
  -- LED,SW for RESET
  LEDR(9)  <= SW(9);
  rst      <= SW(9);

  -- LED,SW for switch for debug: put data the core bus or no.
  LEDR(0)  <= SW(0);
  sw_debug <= SW(0);

	-- select if data input pass or no for OUTBUS
	process (sw_debug)
		begin
		if sw_debug = '0' then
      -- debug, so axi x
			axi_disp <= axi_x;
		else
			-- with core, put each axi in interval of delay the code.c
			axi_disp <= gpio_output(15 downto 0);
		end if;
	end process;

	-- display values of axis by accelerometer in HEX
	disp_data : entity work.disp_data
	port map( data_in => axi_disp, HEX_0 => HEX0 , HEX_1 => HEX1, HEX_2 => HEX2);
	
end architecture rtl;
