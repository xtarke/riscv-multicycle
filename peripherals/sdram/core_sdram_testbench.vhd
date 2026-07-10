library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.decoder_types.all;
use work.sdram_pkg.all;

entity core_sdram_testbench is
    generic(
        --! Num of 32-bits memory words
        IMEMORY_WORDS : integer := 1024;    --!= 4K (1024 * 4) bytes
        DMEMORY_WORDS : integer := 1024     --!= 2k (512 * 2) bytes
    );

    port(
        ----------- SEG7 ------------
        HEX0 : out std_logic_vector(7 downto 0);
        HEX1 : out std_logic_vector(7 downto 0);
        HEX2 : out std_logic_vector(7 downto 0);
        HEX3 : out std_logic_vector(7 downto 0);
        HEX4 : out std_logic_vector(7 downto 0);
        HEX5 : out std_logic_vector(7 downto 0);
        ----------- SW ------------

        SW: in std_logic_vector(9 downto 0);
        LEDR: out std_logic_vector(9 downto 0);

        ---------- ARDUINO IO -----
        ARDUINO_IO: inout std_logic_vector(15 downto 0)
    );


end entity core_sdram_testbench;

architecture RTL of core_sdram_testbench is
    -- Clocks and reset
    signal clk       : std_logic;
    signal clk_32x   : std_logic;
    signal rst       : std_logic;

    -- Instruction bus and instruction memory
    signal address     : std_logic_vector(9 downto 0);
    signal iaddress : unsigned(15 downto 0);
    signal idata : std_logic_vector(31 downto 0);

    -- Data bus
    signal daddress : unsigned(31 downto 0);
    signal ddata_r  : std_logic_vector(31 downto 0);
    signal ddata_w  : std_logic_vector(31 downto 0);
    signal dmask    : std_logic_vector(3 downto 0);
    signal dcsel    : std_logic_vector(1 downto 0);
    signal d_we     : std_logic := '0';
    signal ddata_r_mem : std_logic_vector(31 downto 0);
    signal d_rd : std_logic;
    signal d_sig : std_logic;

    -- Modelsim debug signals
    signal cpu_state    : cpu_state_t;
    signal debugString  : string(1 to 40) := (others => '0');

    -- I/O signals
    signal interrupts : std_logic_vector(31 downto 0);
    signal ddata_r_gpio : std_logic_vector(31 downto 0);
    signal gpio_input : std_logic_vector(31 downto 0);
    signal gpio_output : std_logic_vector(31 downto 0);

    signal ddata_r_timer : std_logic_vector(31 downto 0);
    signal timer_interrupt : std_logic_vector(5 downto 0);
    signal ddata_r_periph : std_logic_vector(31 downto 0);
    signal ddata_r_sdram : std_logic_vector(31 downto 0);

    signal gpio_interrupts : std_logic_vector(6 downto 0);
    signal ddata_r_segments : std_logic_vector(31 downto 0);
    signal ddata_r_uart : std_logic_vector(31 downto 0);
    signal ddata_r_adc : std_logic_vector(31 downto 0);
    signal ddata_r_i2c : std_logic_vector(31 downto 0);

    -- SDRAM signals
    signal daddress_to_sdram : std_logic_vector(31 downto 0);
    signal chipselect_sdram  : std_logic;
    signal sdram_write_data  : io_buffer_t;
    signal sdram_read_data   : io_buffer_t;
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

begin

    clock_driver : process
        constant period : time := 1000 ns;
    begin
        clk <= '0';
        wait for period / 2;
        clk <= '1';
        wait for period / 2;
    end process clock_driver;

    --! Division unit clock
    clock_driver_32x : process
        constant period : time := 20 ns;
    begin
        clk_32x <= '0';
        wait for period / 2;
        clk_32x <= '1';
        wait for period / 2;
    end process clock_driver_32x;

    reset : process is
    begin
        rst <= '1';
        wait for 150 ns;
        rst <= '0';
        wait;
    end process reset;

    -- Connect gpio data to output hardware
    LEDR  <= gpio_output(9 downto 0);
    gpio_input <= (others => '0');

    -- IMem shoud be read from instruction and data buses
    -- Not enough RAM ports for instruction bus, data bus and in-circuit programming
    instr_mux: entity work.instructionbusmux
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
            address => address(9 downto 0),
            byteena => "1111",
            clock   => clk,
            data    => (others => '0'),
            wren    => '0',
            q       => idata
        );

    -- dmemory_address <= daddress;
    -- Data Memory RAM
    dmem : entity work.dmemory
        generic map(
            MEMORY_WORDS => DMEMORY_WORDS
        )
        port map(
            rst     => rst,
            clk     => clk,
            data    => ddata_w,
            address => daddress,
            we      => d_we,
            signal_ext => d_sig,
            csel    => dcsel(0),
            dmask   => dmask,
            q       => ddata_r_mem
        );

    -- Adress space mux ((check sections.ld) -> Data chip select:
    -- 0x00000    ->    Instruction memory
    -- 0x20000    ->    Data memory
    -- 0x40000    ->    Input/Output generic address space
    -- 0x60000    ->    SDRAM address space
    data_bus_mux: entity work.databusmux
        port map(
            dcsel          => dcsel,
            idata          => idata,
            ddata_r_mem    => ddata_r_mem,
            ddata_r_periph => ddata_r_periph,
            ddata_r_sdram  => ddata_r_sdram,
            ddata_r        => ddata_r
        );

    io_data_bus_mux: entity work.iodatabusmux
        port map(
            daddress         => daddress,
            ddata_r_gpio     => ddata_r_gpio,
            ddata_r_segments => ddata_r_segments,
            ddata_r_uart     => ddata_r_uart,
            ddata_r_adc      => ddata_r_adc,
            ddata_r_i2c      => ddata_r_i2c,
            ddata_r_timer    => ddata_r_timer,
            ddata_r_periph   => ddata_r_periph
        );

    -- Softcore instatiation
    myRiscv : entity work.core
        port map(
            clk      => clk,
            rst      => rst,
            clk_32x  => clk_32x,
            iaddress => iaddress,
            idata    => idata,
            daddress => daddress,
            ddata_r  => ddata_r,
            ddata_w  => ddata_w,
            d_we     => d_we,
            d_rd     => d_rd,
            d_sig    => d_sig,
            dcsel    => dcsel,
            dmask    => dmask,
            interrupts=>interrupts,
            state    => cpu_state
        );

    -- Group IRQ signals.
    irq_signals: process(timer_interrupt,gpio_interrupts)
    begin
       interrupts <= (others => '0');
       interrupts(24 downto 18) <= gpio_interrupts(6 downto 0);
       interrupts(30 downto 25) <= timer_interrupt;
    end process;

    -- Generic GPIO module instantiation
    generic_gpio: entity work.gpio
    generic map(
        MY_CHIPSELECT   => "10",
        MY_WORD_ADDRESS => x"0010"
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

    -- SDRAM: each 32-bit CPU word maps to two 16-bit SDRAM columns
    chipselect_sdram   <= dcsel(1) and dcsel(0);
    daddress_to_sdram  <= std_logic_vector(daddress(30 downto 0)) & '0';
    sdram_write_data(0) <= ddata_w(15 downto 0);
    sdram_write_data(1) <= ddata_w(31 downto 16);
    sdram_write_data(2 to 7) <= (others => (others => '0'));
    ddata_r_sdram <= sdram_read_data(1) & sdram_read_data(0);

    -- SDRAM controller instantiation
    sdram_controller : entity work.sdram_controller
        port map(
            address     => daddress_to_sdram,
            byteenable  => "11",
            chipselect  => chipselect_sdram,
            clk         => clk_32x,
            clken       => '1',
            reset       => rst,
            reset_req   => rst,
            write       => d_we,
            read        => d_rd,
            write_data  => sdram_write_data,
            -- outputs:
            read_data   => sdram_read_data,
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

    -- SDRAM model instantiation
    sdram : entity work.mt48lc8m16a2
        generic map(
            addr_bits => 13
        )
        port map(
            Dq    => DRAM_DQ,
            Addr  => DRAM_ADDR,
            Ba    => DRAM_BA,
            Clk   => clk_32x,
            Cke   => DRAM_CKE,
            Cs_n  => DRAM_CS_N,
            Ras_n => DRAM_RAS_N,
            Cas_n => DRAM_CAS_N,
            We_n  => DRAM_WE_N,
            Dqm   => DRAM_DQM
        );

    -- FileOutput DEBUG
    debug : entity work.trace_debug
    generic map(
        MEMORY_WORDS => IMEMORY_WORDS
    )
    port map(
        pc   => iaddress,
        data => idata,
        inst => debugString
    );

end architecture RTL;
