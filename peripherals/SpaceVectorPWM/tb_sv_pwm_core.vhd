-------------------------------------------------------
--! @file tb_sv_pwm_core.vhd
--! @brief Testbench do RISC-V Multicycle integrado ao
--         periférico sv_pwm rodando main_sv_pwm.c.
--
-- Pré-requisito:
--   1. Compile o software:
--        cd software/sv_pwm && make quartus_main_sv_pwm.hex
--   2. Aponte iram_quartus.vhd para o hex gerado:
--        init_file => "./software/sv_pwm/quartus_main_sv_pwm.hex"
--
-- Estímulos GPIO (simulam SW da placa):
--   0–2 ms   : SW0=0, SW1=0  ->  u_cmd =   0
--   2–4 ms   : SW0=1          ->  u_cmd = +60
--   4–6 ms   : SW1=1          ->  u_cmd = -60
--   6–8 ms   : SW0=0, SW1=0  ->  u_cmd =   0
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.decoder_types.all;

entity coretestbench is
    generic (
        IMEMORY_WORDS : integer := 1024;
        DMEMORY_WORDS : integer := 1024
    );
    port (
        HEX0 : out std_logic_vector(7 downto 0);
        HEX1 : out std_logic_vector(7 downto 0);
        HEX2 : out std_logic_vector(7 downto 0);
        HEX3 : out std_logic_vector(7 downto 0);
        HEX4 : out std_logic_vector(7 downto 0);
        HEX5 : out std_logic_vector(7 downto 0);
        SW   : in  std_logic_vector(9 downto 0);
        LEDR : out std_logic_vector(9 downto 0);
        ARDUINO_IO : inout std_logic_vector(15 downto 0)
    );
end entity coretestbench;

architecture RTL of coretestbench is

    -- Clocks e reset
    signal clk     : std_logic;
    signal clk_32x : std_logic;
    signal rst     : std_logic;

    -- Barramento de instruções
    signal address  : std_logic_vector(9 downto 0);
    signal iaddress : unsigned(15 downto 0);
    signal idata    : std_logic_vector(31 downto 0);

    -- Barramento de dados
    signal daddress    : unsigned(31 downto 0);
    signal ddata_r     : std_logic_vector(31 downto 0);
    signal ddata_w     : std_logic_vector(31 downto 0);
    signal dmask       : std_logic_vector(3 downto 0);
    signal dcsel       : std_logic_vector(1 downto 0);
    signal d_we        : std_logic := '0';
    signal d_rd        : std_logic;
    signal d_sig       : std_logic;
    signal ddata_r_mem : std_logic_vector(31 downto 0);

    -- Debug
    signal cpu_state  : cpu_state_t;
    signal debugString : string(1 to 40) := (others => '0');

    -- Interrupções
    signal interrupts      : std_logic_vector(31 downto 0);
    signal gpio_interrupts : std_logic_vector(6 downto 0);
    signal timer_interrupt : std_logic_vector(5 downto 0);

    -- GPIO
    signal gpio_input  : std_logic_vector(31 downto 0);
    signal gpio_output : std_logic_vector(31 downto 0);

    -- Sinais ddata_r de cada periférico
    signal ddata_r_gpio           : std_logic_vector(31 downto 0);
    signal ddata_r_segments       : std_logic_vector(31 downto 0);
    signal ddata_r_uart           : std_logic_vector(31 downto 0);
    signal ddata_r_adc            : std_logic_vector(31 downto 0);
    signal ddata_r_i2c            : std_logic_vector(31 downto 0);
    signal ddata_r_timer          : std_logic_vector(31 downto 0);
    signal ddata_r_dif_fil        : std_logic_vector(31 downto 0);
    signal ddata_r_stepmot        : std_logic_vector(31 downto 0);
    signal ddata_r_lcd            : std_logic_vector(31 downto 0);
    signal ddata_r_nn_accelerator : std_logic_vector(31 downto 0);
    signal ddata_r_fir_fil        : std_logic_vector(31 downto 0);
    signal ddata_r_spwm           : std_logic_vector(31 downto 0);
    signal ddata_r_crc            : std_logic_vector(31 downto 0);
    signal ddata_r_key            : std_logic_vector(31 downto 0);
    signal ddata_r_accelerometer  : std_logic_vector(31 downto 0);
    signal ddata_r_cordic         : std_logic_vector(31 downto 0);
    signal ddata_r_RS485          : std_logic_vector(31 downto 0);
    signal ddata_r_rgb            : std_logic_vector(31 downto 0);
    signal ddata_r_sv_pwm         : std_logic_vector(31 downto 0);
    signal ddata_r_periph         : std_logic_vector(31 downto 0);
    signal ddata_r_sdram          : std_logic_vector(31 downto 0);

    -- Saídas do sv_pwm
    signal gate_s1 : std_logic;
    signal gate_s2 : std_logic;
    signal gate_s3 : std_logic;
    signal gate_s4 : std_logic;

    signal ifcap : std_logic;

begin

    -- ----------------------------------------------------------------
    -- Geradores de clock
    -- CPU: 1 MHz  |  Periféricos/M-ext: 50 MHz
    -- ----------------------------------------------------------------
    clock_driver : process
        constant period : time := 1000 ns; -- 1 MHz
    begin
        clk <= '0'; wait for period / 2;
        clk <= '1'; wait for period / 2;
    end process;

    clock_driver_32x : process
        constant period : time := 20 ns;   -- 50 MHz
    begin
        clk_32x <= '0'; wait for period / 2;
        clk_32x <= '1'; wait for period / 2;
    end process;

    reset : process is
    begin
        rst <= '1';
        wait for 150 ns;
        rst <= '0';
        wait;
    end process;

    -- ----------------------------------------------------------------
    -- Estímulos GPIO: simulam SW0 e SW1 da placa
    -- ----------------------------------------------------------------
    gpio_test : process
    begin
        gpio_input <= (others => '0');  -- SW0=0, SW1=0 -> u_cmd = 0
        wait for 2 ms;

        gpio_input(0) <= '1';           -- SW0=1 -> u_cmd = +60
        wait for 2 ms;

        gpio_input(0) <= '0';
        gpio_input(1) <= '1';           -- SW1=1 -> u_cmd = -60
        wait for 2 ms;

        gpio_input(1) <= '0';           -- SW0=0, SW1=0 -> u_cmd = 0
        wait;
    end process;

    -- ----------------------------------------------------------------
    -- Saídas para a placa
    -- ----------------------------------------------------------------
    LEDR <= gpio_output(9 downto 0);

    -- ----------------------------------------------------------------
    -- Space Vector PWM (periférico sob teste)
    -- ----------------------------------------------------------------
    sv_pwm_inst : entity work.sv_pwm
        generic map (
            MY_CHIPSELECT     => "10",
            MY_WORD_ADDRESS   => x"0190",
            DADDRESS_BUS_SIZE => 32,
            INPUT_CLK_FREQ    => 50000000,
            DEADTIME_CYCLES   => 50
        )
        port map (
            clk      => clk_32x,
            rst      => rst,
            daddress => daddress,
            ddata_w  => ddata_w,
            ddata_r  => ddata_r_sv_pwm,
            d_we     => d_we,
            d_rd     => d_rd,
            dcsel    => dcsel,
            dmask    => dmask,
            gate_s1  => gate_s1,
            gate_s2  => gate_s2,
            gate_s3  => gate_s3,
            gate_s4  => gate_s4
        );

    -- ----------------------------------------------------------------
    -- Multiplexador de instrução (acesso duplo à iram)
    -- ----------------------------------------------------------------
    instr_mux : entity work.instructionbusmux
        port map (
            d_rd     => d_rd,
            dcsel    => dcsel,
            daddress => daddress,
            iaddress => iaddress,
            address  => address
        );

    -- ----------------------------------------------------------------
    -- Memória de instruções (hex definido em iram_quartus.vhd)
    -- ----------------------------------------------------------------
    iram_quartus_inst : entity work.iram_quartus
        port map (
            address => address(9 downto 0),
            byteena => "1111",
            clock   => clk,
            data    => (others => '0'),
            wren    => '0',
            q       => idata
        );

    -- ----------------------------------------------------------------
    -- Memória de dados
    -- ----------------------------------------------------------------
    dmem : entity work.dmemory
        generic map (MEMORY_WORDS => DMEMORY_WORDS)
        port map (
            rst        => rst,
            clk        => clk,
            data       => ddata_w,
            address    => daddress,
            we         => d_we,
            signal_ext => d_sig,
            csel       => dcsel(0),
            dmask      => dmask,
            q          => ddata_r_mem
        );

    -- ----------------------------------------------------------------
    -- Multiplexadores do barramento
    -- ----------------------------------------------------------------
    data_bus_mux : entity work.databusmux
        port map (
            dcsel          => dcsel,
            idata          => idata,
            ddata_r_mem    => ddata_r_mem,
            ddata_r_periph => ddata_r_periph,
            ddata_r_sdram  => ddata_r_sdram,
            ddata_r        => ddata_r
        );

    io_data_bus_mux : entity work.iodatabusmux
        port map (
            daddress               => daddress,
            ddata_r_gpio           => ddata_r_gpio,
            ddata_r_segments       => ddata_r_segments,
            ddata_r_uart           => ddata_r_uart,
            ddata_r_adc            => ddata_r_adc,
            ddata_r_i2c            => ddata_r_i2c,
            ddata_r_timer          => ddata_r_timer,
            ddata_r_dif_fil        => ddata_r_dif_fil,
            ddata_r_stepmot        => ddata_r_stepmot,
            ddata_r_lcd            => ddata_r_lcd,
            ddata_r_nn_accelerator => ddata_r_nn_accelerator,
            ddata_r_fir_fil        => ddata_r_fir_fil,
            ddata_r_spwm           => ddata_r_spwm,
            ddata_r_crc            => ddata_r_crc,
            ddata_r_key            => ddata_r_key,
            ddata_r_accelerometer  => ddata_r_accelerometer,
            ddata_r_cordic         => ddata_r_cordic,
            ddata_r_RS485          => ddata_r_RS485,
            ddata_r_rgb            => ddata_r_rgb,
            ddata_r_sv_pwm         => ddata_r_sv_pwm,
            ddata_r_periph         => ddata_r_periph
        );

    -- ----------------------------------------------------------------
    -- Núcleo RISC-V
    -- ----------------------------------------------------------------
    myRiscv : entity work.core
        port map (
            clk       => clk,
            rst       => rst,
            clk_32x   => clk_32x,
            iaddress  => iaddress,
            idata     => idata,
            daddress  => daddress,
            ddata_r   => ddata_r,
            ddata_w   => ddata_w,
            d_we      => d_we,
            d_rd      => d_rd,
            d_sig     => d_sig,
            dcsel     => dcsel,
            dmask     => dmask,
            interrupts => interrupts,
            state     => cpu_state
        );

    -- ----------------------------------------------------------------
    -- Agrupamento de IRQs
    -- ----------------------------------------------------------------
    irq_signals : process(timer_interrupt, gpio_interrupts)
    begin
        interrupts <= (others => '0');
        interrupts(24 downto 18) <= gpio_interrupts(6 downto 0);
        interrupts(30 downto 25) <= timer_interrupt;
    end process;

    -- ----------------------------------------------------------------
    -- Timer
    -- ----------------------------------------------------------------
    timer : entity work.Timer
        generic map (
            prescaler_size => 16,
            compare_size   => 32
        )
        port map (
            clock           => clk,
            reset           => rst,
            daddress        => daddress,
            ddata_w         => ddata_w,
            ddata_r         => ddata_r_timer,
            d_we            => d_we,
            d_rd            => d_rd,
            dcsel           => dcsel,
            dmask           => dmask,
            timer_interrupt => timer_interrupt,
            ifcap           => ifcap
        );

    -- ----------------------------------------------------------------
    -- GPIO
    -- ----------------------------------------------------------------
    generic_gpio : entity work.gpio
        port map (
            clk             => clk,
            rst             => rst,
            daddress        => daddress,
            ddata_w         => ddata_w,
            ddata_r         => ddata_r_gpio,
            d_we            => d_we,
            d_rd            => d_rd,
            dcsel           => dcsel,
            dmask           => dmask,
            input           => gpio_input,
            output          => gpio_output,
            gpio_interrupts => gpio_interrupts
        );

    -- ----------------------------------------------------------------
    -- Displays de 7 segmentos (exibem u_cmd)
    -- ----------------------------------------------------------------
    generic_displays : entity work.led_displays
        port map (
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

    -- ----------------------------------------------------------------
    -- Trace debug
    -- ----------------------------------------------------------------
    debug : entity work.trace_debug
        generic map (MEMORY_WORDS => IMEMORY_WORDS)
        port map (
            pc   => iaddress,
            data => idata,
            inst => debugString
        );

end architecture RTL;
