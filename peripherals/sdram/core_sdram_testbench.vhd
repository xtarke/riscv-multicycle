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

    -- SDRAM via cache: each 32-bit CPU word is stored as two 16-bit cache
    -- words (low half at 2*A, high half at 2*A+1).
    signal chipselect_sdram : std_logic;

    -- CPU write bridge -> cache user port
    signal cache_write_commit  : std_logic;
    signal cache_write_address : std_logic_vector(31 downto 0);
    signal cache_write_data    : std_logic_vector(15 downto 0);
    signal cache_write_busy    : std_logic;
    signal cpu_wr              : std_logic;
    signal cpu_wr_d            : std_logic;
    signal wr_high             : std_logic;
    signal sdram_base          : unsigned(31 downto 0);

    -- cache <-> controller
    signal c_addr       : std_logic_vector(31 downto 0);
    signal c_read       : std_logic;
    signal c_write      : std_logic;
    signal c_cs         : std_logic;
    signal c_write_data : io_buffer_t;
    signal c_read_data  : io_buffer_t;
    signal c_valid_cnt  : integer range 0 to 8;
    signal c_wait       : std_logic;

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
            ddata_r_periph   => ddata_r_periph,
            -- Peripherals not present in this testbench: tie their read data low.
            ddata_r_dif_fil        => (others => '0'),
            ddata_r_stepmot        => (others => '0'),
            ddata_r_lcd            => (others => '0'),
            ddata_r_nn_accelerator => (others => '0'),
            ddata_r_fir_fil        => (others => '0'),
            ddata_r_spwm           => (others => '0'),
            ddata_r_crc            => (others => '0'),
            ddata_r_key            => (others => '0'),
            ddata_r_accelerometer  => (others => '0'),
            ddata_r_cordic         => (others => '0'),
            ddata_r_RS485          => (others => '0'),
            ddata_r_rgb            => (others => '0')
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

    -- SDRAM through the cache. A 32-bit CPU store becomes two 16-bit cache
    -- commits: low half at word 2*A, high half at word 2*A+1.
    chipselect_sdram <= dcsel(1) and dcsel(0);
    cpu_wr           <= chipselect_sdram and d_we;
    sdram_base       <= shift_left(daddress, 1);   -- 2 * CPU word address

    -- Write bridge: one CPU write -> two cache commits (low then high).
    sdram_write_bridge : process(clk_32x, rst)
    begin
        if rst = '1' then
            wr_high            <= '0';
            cpu_wr_d           <= '0';
            cache_write_commit <= '0';
        elsif rising_edge(clk_32x) then
            cache_write_commit <= '0';
            cpu_wr_d           <= cpu_wr;
            if wr_high = '1' then
                -- second half
                cache_write_address <= std_logic_vector(sdram_base + 1);
                cache_write_data    <= ddata_w(31 downto 16);
                cache_write_commit  <= '1';
                wr_high             <= '0';
            elsif cpu_wr = '1' and cpu_wr_d = '0' then
                -- first half (on the CPU write edge)
                cache_write_address <= std_logic_vector(sdram_base);
                cache_write_data    <= ddata_w(15 downto 0);
                cache_write_commit  <= '1';
                wr_high             <= '1';
            end if;
        end if;
    end process;

    -- The streaming cache can't serve CPU random reads without a waitrequest,
    -- so (like the VGA framebuffer) the CPU does not read SDRAM back here.
    ddata_r_sdram <= (others => '0');

    -- Cache: prefetches to fill its read fifo (which un-gates the write drain)
    -- and pushes the queued CPU writes out to the SDRAM controller.
    cache : entity work.sdram_cache
        port map(
            clk          => clk_32x,
            reset        => rst,
            read_enable  => '0',
            read_address => (others => '0'),
            read_data    => open,
            read_lock    => open,
            read_flush   => '0',
            write_commit           => cache_write_commit,
            write_address          => cache_write_address,
            write_data             => cache_write_data,
            write_fifo_full        => open,
            write_fifo_almost_full => cache_write_busy,
            read_used              => open,
            sdram_read_buffer      => c_read_data,
            sdram_read_valid_count => c_valid_cnt,
            sdram_wait_request     => c_wait,
            sdram_addr             => c_addr,
            sdram_read             => c_read,
            sdram_write            => c_write,
            sdram_write_data       => c_write_data,
            sdram_chip_select      => c_cs
        );

    -- SDRAM controller. DATA_AVAL = 1 matches the Micron sim model (the real
    -- ISSI part uses the default 2).
    sdram_controller : entity work.sdram_controller
        generic map(
            DATA_AVAL => 1
        )
        port map(
            address          => c_addr,
            byteenable       => "11",
            chipselect       => c_cs,
            clk              => clk_32x,
            clken            => '1',
            reset            => rst,
            reset_req        => rst,
            write            => c_write,
            read             => c_read,
            write_data       => c_write_data,
            -- outputs:
            read_data        => c_read_data,
            read_valid_count => c_valid_cnt,
            waitrequest      => c_wait,
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
