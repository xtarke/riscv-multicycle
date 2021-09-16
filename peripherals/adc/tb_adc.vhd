-------------------------------------------------------
--! @file
--! @brief RISCV Testbench
--         This testbench simulates a core with a 
--         generic IO hardware and a Timer     
--
-------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.decoder_types.all;

entity tb_adc is
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
end entity tb_adc;

architecture rtl of tb_adc is
    --architecture RTL of tb_adc is
    -- Clocks and reset
    signal clk       : std_logic;
    signal clk_32x   : std_logic;
    signal clk_adc   : std_logic;
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

    signal adc_interrupt : std_logic_vector(1 downto 0);
    
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
    
    clock_adc: process
        constant adc_period : time := 100000 ns;
    begin
        clk_adc <= '0';
        wait for adc_period/2; 
        clk_adc <= '1';
        wait for adc_period/2; 
    end process clock_adc;
 
    reset : process is
    begin
        rst <= '1';
        wait for 150 ns;
        rst <= '0';
        wait;
    end process reset;
    
    -- Connect gpio data to output hardware
    LEDR  <= gpio_output(9 downto 0);

    -- Connect input hardware to gpio data
    gpio_test: process
    begin
        gpio_input <= (others => '0');
        wait for 500 us;
                
        -- Generate a input pulse (External IRQ 0 or pooling)
        gpio_input(0) <= '1';
        wait for 1 us;
        gpio_input(0) <= '0';
        
        -- Generate a input pulse (External IRQ 1 or pooling)
        wait for 200 us;
        gpio_input(1) <= '1';
        wait for 1 us;
        gpio_input(1) <= '0';
        
        wait;
    end process;  
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
    irq_signals: process(timer_interrupt,gpio_interrupts, adc_interrupt)
    begin
       interrupts <= (others => '0');
       interrupts(24 downto 18) <= gpio_interrupts(6 downto 0);
       interrupts(30 downto 25) <= timer_interrupt;
       interrupts(17) <= adc_interrupt(0);
    end process;

    
    -- Timer instantiation
    timer : entity work.Timer
    generic map(
        prescaler_size => 16,
        compare_size   => 32
    )
    port map(
        clock       => clk,
        reset       => rst,
        daddress => daddress,
        ddata_w  => ddata_w,
        ddata_r  => ddata_r_timer,
        d_we     => d_we,
        d_rd     => d_rd,
        dcsel    => dcsel,
        dmask    => dmask,
        timer_interrupt => timer_interrupt
    );
    
    -- Generic GPIO module instantiation
    generic_gpio: entity work.gpio
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

    generic_displays : entity work.led_displays      
        port map(
            clk      => clk,
            rst      => rst,
            daddress => daddress,
            ddata_w  => ddata_w,
            ddata_r  => ddata_r_segments,
            d_we     => d_we,
            d_rd     => d_rd,
            dcsel    => dcsel,
            dmask    => dmask,
            hex0     => HEX0,
            hex1     => HEX1,
            hex2     => HEX2,
            hex3     => HEX3,
            hex4     => HEX4,
            hex5     => HEX5,
            hex6     => open,
            hex7     => open
        );
        
    adc_bus: entity work.adc_bus 
        port map(
            clk      => clk,
            rst      => rst,
            clk_adc  => clk_adc,
            daddress => daddress,
            ddata_w  => ddata_w,
            ddata_r  => ddata_r_adc,
            d_we     => d_we,
            d_rd     => d_rd,
            dcsel    => dcsel,
            dmask    => dmask,
            adc_interrupt => adc_interrupt
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
