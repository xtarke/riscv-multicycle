-------------------------------------------------------
--! @file de0_lite.vhd
--! @brief Description
-------------------------------------------------------

--! Use standard library
library ieee;
--! Use standard logic elements
use ieee.std_logic_1164.all;
--! Use conversion functions
use ieee.numeric_std.all;
--! Use RiscV decoder types
use work.decoder_types.all;

entity de0_lite is
    generic(
        --! Num of 32-bits memory words 
        IADDRESS_BUS_SIZE : integer := 16;
        DADDRESS_BUS_SIZE : integer := 32;
        IMEMORY_WORDS     : integer := 1024; --!= 4K (1024 * 4) bytes
        DMEMORY_WORDS     : integer := 1024 --!= 2k (512 * 2) bytes
    );
    port(
        ---------- CLOCK ----------
        ADC_CLK_10      : in    std_logic;
        MAX10_CLK1_50   : in    std_logic;
        MAX10_CLK2_50   : in    std_logic;
        ----------- SDRAM ------------
        DRAM_ADDR       : out   std_logic_vector(12 downto 0);
        DRAM_BA         : out   std_logic_vector(1 downto 0);
        DRAM_CAS_N      : out   std_logic;
        DRAM_CKE        : out   std_logic;
        DRAM_CLK        : out   std_logic;
        DRAM_CS_N       : out   std_logic;
        DRAM_DQ         : inout std_logic_vector(15 downto 0);
        DRAM_LDQM       : out   std_logic;
        DRAM_RAS_N      : out   std_logic;
        DRAM_UDQM       : out   std_logic;
        DRAM_WE_N       : out   std_logic;
        ----------- SEG7 ------------
        HEX0            : out   std_logic_vector(7 downto 0);
        HEX1            : out   std_logic_vector(7 downto 0);
        HEX2            : out   std_logic_vector(7 downto 0);
        HEX3            : out   std_logic_vector(7 downto 0);
        HEX4            : out   std_logic_vector(7 downto 0);
        HEX5            : out   std_logic_vector(7 downto 0);
        ----------- KEY ------------
        KEY             : in    std_logic_vector(1 downto 0);
        ----------- LED ------------
        LEDR            : out   std_logic_vector(9 downto 0);
        ----------- SW ------------
        SW              : in    std_logic_vector(9 downto 0);
        ----------- VGA ------------
        VGA_B           : out   std_logic_vector(3 downto 0);
        VGA_G           : out   std_logic_vector(3 downto 0);
        VGA_HS          : out   std_logic;
        VGA_R           : out   std_logic_vector(3 downto 0);
        VGA_VS          : out   std_logic;
        ----------- Accelerometer ------------
        GSENSOR_CS_N    : out   std_logic;
        GSENSOR_INT     : in    std_logic_vector(2 downto 1);
        GSENSOR_SCLK    : out   std_logic;
        GSENSOR_SDI     : inout std_logic;
        GSENSOR_SDO     : inout std_logic;
        ----------- Arduino ------------
        ARDUINO_IO      : inout std_logic_vector(15 downto 0);
        ARDUINO_RESET_N : inout std_logic
    );
end entity;

architecture rtl of de0_lite is

    signal clk   : std_logic;
    signal rst   : std_logic;
    signal n_rst : std_logic;

    -- Instruction bus signals
    signal idata    : std_logic_vector(31 downto 0);
    signal iaddress : unsigned(IADDRESS_BUS_SIZE - 1 downto 0); --! Instruction address
    signal address  : std_logic_vector(9 downto 0);

    -- Data bus signals
    signal daddress : unsigned(DADDRESS_BUS_SIZE - 1 downto 0); --! Data address
    signal ddata_r  : std_logic_vector(31 downto 0);
    signal ddata_w  : std_logic_vector(31 downto 0);
    signal dmask    : std_logic_vector(3 downto 0);
    signal dcsel    : std_logic_vector(1 downto 0);
    signal d_we     : std_logic := '0';

    signal ddata_r_mem : std_logic_vector(31 downto 0);
    signal d_rd        : std_logic;

    -- I/O signals
    signal ddata_r_gpio  : std_logic_vector(31 downto 0);
    signal ddata_r_sdram : std_logic_vector(31 downto 0);
    signal interrupts    : std_logic_vector(31 downto 0);

    -- PLL signals
    signal locked_sig : std_logic;

    -- CPU state signals
    signal state : cpu_state_t;
    signal d_sig : std_logic;

    -- Peripheral data signals
    signal ddata_r_segments : std_logic_vector(31 downto 0);
    signal ddata_r_uart     : std_logic_vector(31 downto 0);
    signal ddata_r_adc      : std_logic_vector(31 downto 0);
    signal ddata_r_i2c      : std_logic_vector(31 downto 0);
    signal ddata_r_timer    : std_logic_vector(31 downto 0);
    signal ddata_r_periph   : std_logic_vector(31 downto 0);
    signal ddata_r_dif_fil  : std_logic_vector(31 downto 0);
    signal ddata_r_stepmot  : std_logic_vector(31 downto 0);
    signal ddata_r_lcd      : std_logic_vector(31 downto 0);

begin
    -- Reset 
    rst     <= SW(9);
    n_rst   <= not rst;
    LEDR(9) <= SW(9);

    pll_inst : entity work.pll
        port map(
            inclk0 => ADC_CLK_10,
            c0     => clk
        );

    -- 32-bits x 1024 words quartus RAM (dual port: portA -> riscV, portB -> In-System Mem Editor
    iram_quartus_inst : entity work.iram_quartus
        port map(
            address => address,
            byteena => "1111",
            clock   => clk,
            data    => (others => '0'),
            wren    => '0',
            q       => idata
        );

    -- IMem shoud be read from instruction and data buses
    -- Not enough RAM ports for instruction bus, data bus and in-circuit programming
    instr_mux : entity work.instructionbusmux
        generic map(
            IADDRESS_BUS_SIZE => IADDRESS_BUS_SIZE,
            DADDRESS_BUS_SIZE => DADDRESS_BUS_SIZE
        )
        port map(
            d_rd     => d_rd,
            dcsel    => dcsel,
            daddress => daddress,
            iaddress => iaddress,
            address  => address
        );

    -- Data Memory RAM
    dmem : entity work.dmemory
        generic map(
            MEMORY_WORDS      => DMEMORY_WORDS,
            DADDRESS_BUS_SIZE => DADDRESS_BUS_SIZE
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

    -- Adress space mux ((check sections.ld) -> Data chip select:
    -- 0x00000    ->    Instruction memory
    -- 0x20000    ->    Data memory
    -- 0x40000    ->    Input/Output generic address space
    -- ( ... )    ->    ( ... )
    datamux : entity work.databusmux
        port map(
            dcsel          => dcsel,
            idata          => idata,
            ddata_r_mem    => ddata_r_mem,
            ddata_r_periph => ddata_r_gpio,
            ddata_r_sdram  => ddata_r_sdram,
            ddata_r        => ddata_r
        );

    -- Softcore instatiation
    myRisc : entity work.core
        generic map(
            IADDRESS_BUS_SIZE => IADDRESS_BUS_SIZE,
            DADDRESS_BUS_SIZE => DADDRESS_BUS_SIZE
        )
        port map(
            clk        => clk,
            rst        => rst,
            clk_32x    => clk,
            iaddress   => iaddress,
            idata      => idata,
            daddress   => daddress,
            ddata_r    => ddata_r,
            ddata_w    => ddata_w,
            d_we       => d_we,
            d_rd       => d_rd,
            d_sig      => d_sig,
            dcsel      => dcsel,
            dmask      => dmask,
            interrupts => interrupts,
            state      => state
        );

    io_data_bus_mux : entity work.iodatabusmux
        port map(
            daddress         => daddress,
            ddata_r_gpio     => ddata_r_gpio,
            ddata_r_segments => ddata_r_segments,
            ddata_r_uart     => ddata_r_uart,
            ddata_r_adc      => ddata_r_adc,
            ddata_r_i2c      => ddata_r_i2c,
            ddata_r_timer    => ddata_r_timer,
            ddata_r_periph   => ddata_r_periph,
            ddata_r_dif_fil  => ddata_r_dif_fil,
            ddata_r_stepmot  => ddata_r_stepmot,
            ddata_r_lcd      => ddata_r_lcd
        );

    lcd : entity work.lcd
        port map(
            clk        => clk,
            reset      => n_rst,
            daddress   => daddress,
            ddata_w    => ddata_w,
            ddata_r    => ddata_r_lcd,
            d_we       => d_we,
            d_rd       => d_rd,
            dcsel      => dcsel,
            rst        => ARDUINO_IO(0),
            ce         => ARDUINO_IO(1),
            dc         => ARDUINO_IO(2),
            din        => ARDUINO_IO(3),
            serial_clk => ARDUINO_IO(4),
            light      => ARDUINO_IO(5)
        );

end;

