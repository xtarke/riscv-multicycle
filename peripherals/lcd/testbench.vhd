-------------------------------------------------------
--! @file testbench.vhd
--! @brief Nokia 5110 (PCD8544) LCD display controller testbench
-------------------------------------------------------

--! Use standard library
library ieee;
--! Use standard logic elements
use ieee.std_logic_1164.all;
--! Use conversion functions
use ieee.numeric_std.all;
--! Use RiscV instruction decoding
use work.decoder_types.all;

entity lcd_coretestbench is
    generic(
        --! Num of 32-bits memory words 
        IADDRESS_BUS_SIZE : integer := 16;
        DADDRESS_BUS_SIZE : integer := 32;
        IMEMORY_WORDS     : integer := 1024; --!= 4K (1024 * 4) bytes
        DMEMORY_WORDS     : integer := 1024 --!= 2k (512 * 2) bytes
    );
    port(
        ---------- ARDUINO IO -----
        ARDUINO_IO : inout std_logic_vector(15 downto 0)
    );
end entity lcd_coretestbench;

architecture RTL of lcd_coretestbench is
    signal clk     : std_logic;
    signal clk_32x : std_logic;
    signal rst     : std_logic;
    signal n_rst   : std_logic;

    -- Instruction bus and instruction memory
    signal address  : std_logic_vector(9 downto 0);
    signal iaddress : unsigned(15 downto 0);
    signal idata    : std_logic_vector(31 downto 0);

    -- Data bus
    signal daddress    : unsigned(31 downto 0);
    signal ddata_r     : std_logic_vector(31 downto 0);
    signal ddata_w     : std_logic_vector(31 downto 0);
    signal dmask       : std_logic_vector(3 downto 0);
    signal dcsel       : std_logic_vector(1 downto 0);
    signal d_we        : std_logic := '0';
    signal ddata_r_mem : std_logic_vector(31 downto 0);
    signal d_rd        : std_logic;
    signal d_sig       : std_logic;

    -- I/O signals
    signal ddata_r_gpio  : std_logic_vector(31 downto 0);
    signal ddata_r_sdram : std_logic_vector(31 downto 0);
    signal interrupts    : std_logic_vector(31 downto 0);

    -- PLL signals
    signal locked_sig : std_logic;

    -- CPU state signals
    signal state : cpu_state_t;

    -- Peripheral data signals
    signal ddata_r_periph   : std_logic_vector(31 downto 0);
    signal ddata_r_segments : std_logic_vector(31 downto 0);
    signal ddata_r_uart     : std_logic_vector(31 downto 0);
    signal ddata_r_adc      : std_logic_vector(31 downto 0);
    signal ddata_r_i2c      : std_logic_vector(31 downto 0);
    signal ddata_r_timer    : std_logic_vector(31 downto 0);
    signal ddata_r_dif_fil  : std_logic_vector(31 downto 0);
    signal ddata_r_stepmot  : std_logic_vector(31 downto 0);
    signal ddata_r_lcd      : std_logic_vector(31 downto 0);

    -- Debug signals
    signal debugString : string(1 to 40) := (others => '0');
begin

    n_rst <= NOT rst;

    Reset : process is
    begin
        rst <= '1';
        wait for 150 ns;
        rst <= '0';
        wait;
    end process;

    Clock_driver : process
        constant period : time := 1000 ns;
    begin
        clk <= '0';
        wait for period / 2;
        clk <= '1';
        wait for period / 2;
    end process Clock_driver;

    --! Division unit clock
    Clock_driver_32x : process
        constant period : time := 20 ns;
    begin
        clk_32x <= '0';
        wait for period / 2;
        clk_32x <= '1';
        wait for period / 2;
    end process Clock_driver_32x;

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

    -- Data Memory RAM
    dmem : entity work.dmemory
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

    -- Adress space mux ((check sections.ld) -> Data chip select:
    -- 0x00000    ->    Instruction memory
    -- 0x20000    ->    Data memory
    -- 0x40000    ->    Input/Output generic address space
    -- 0x60000    ->    SDRAM address space
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
    myRiscv : entity work.core
        port map(
            clk        => clk,
            rst        => rst,
            clk_32x    => clk_32x,
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
            ddata_r_dif_fil  => ddata_r_dif_fil,
            ddata_r_stepmot  => ddata_r_stepmot,
            ddata_r_lcd      => ddata_r_lcd,
            ddata_r_periph   => ddata_r_periph
        );

    lcd : entity work.lcd
        generic map(
            MY_CHIPSELECT     => "10",
            MY_WORD_ADDRESS   => x"00A0",
            DADDRESS_BUS_SIZE => DADDRESS_BUS_SIZE
        )
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

        --    -- FileOutput DEBUG	
        --    debug : entity work.trace_debug
        --        generic map(
        --            MEMORY_WORDS      => IMEMORY_WORDS,
        --            IADDRESS_BUS_SIZE => IADDRESS_BUS_SIZE
        --        )
        --        port map(
        --            pc   => iaddress,
        --            data => idata,
        --            inst => debugString
        --        );
end architecture RTL;
