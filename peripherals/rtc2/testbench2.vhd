library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.decoder_types.all;

entity coretestbench is
end entity;

architecture RTL of coretestbench is

    constant IMEMORY_WORDS : integer := 1024;
    constant DMEMORY_WORDS : integer := 1024;

    signal clk     : std_logic := '0';
    signal clk_32x : std_logic := '0';
    signal rst     : std_logic := '1';

    signal address  : std_logic_vector(9 downto 0);
    signal iaddress : unsigned(15 downto 0);
    signal idata    : std_logic_vector(31 downto 0);

    signal daddress    : unsigned(31 downto 0);
    signal ddata_r     : std_logic_vector(31 downto 0);
    signal ddata_w     : std_logic_vector(31 downto 0);
    signal ddata_r_mem : std_logic_vector(31 downto 0);
    signal dmask       : std_logic_vector(3 downto 0);
    signal dcsel       : std_logic_vector(1 downto 0);
    signal d_we        : std_logic;
    signal d_rd        : std_logic;
    signal d_sig       : std_logic;

    signal cpu_state   : cpu_state_t;
    signal debugString : string(1 to 40) := (others => '0');

    signal interrupts      : std_logic_vector(31 downto 0);
    signal gpio_interrupts : std_logic_vector(6 downto 0);
    signal timer_interrupt : std_logic_vector(5 downto 0);

    signal ddata_r_periph : std_logic_vector(31 downto 0);
    signal ddata_r_sdram  : std_logic_vector(31 downto 0) := (others => '0');

    signal ddata_r_gpio     : std_logic_vector(31 downto 0);
    signal ddata_r_segments : std_logic_vector(31 downto 0);
    signal ddata_r_rtc      : std_logic_vector(31 downto 0);

    signal gpio_input  : std_logic_vector(31 downto 0) := (others => '0');
    signal gpio_output : std_logic_vector(31 downto 0);

    signal HEX0 : std_logic_vector(7 downto 0);
    signal HEX1 : std_logic_vector(7 downto 0);
    signal HEX2 : std_logic_vector(7 downto 0);
    signal HEX3 : std_logic_vector(7 downto 0);
    signal HEX4 : std_logic_vector(7 downto 0);
    signal HEX5 : std_logic_vector(7 downto 0);
    signal HEX6 : std_logic_vector(7 downto 0);
    signal HEX7 : std_logic_vector(7 downto 0);

    signal LEDR : std_logic_vector(9 downto 0);

    signal rtc_sec  : std_logic_vector(5 downto 0);
    signal rtc_min  : std_logic_vector(5 downto 0);
    signal rtc_hour : std_logic_vector(4 downto 0);

begin

    clk <= not clk after 500 ns;
    clk_32x <= not clk_32x after 10 ns;

    process
    begin
        rst <= '1';
        wait for 2 us;
        rst <= '0';
        wait;
    end process;

    LEDR <= gpio_output(9 downto 0);

    instr_mux : entity work.instructionbusmux
        port map(
            d_rd     => d_rd,
            dcsel    => dcsel,
            daddress => daddress,
            iaddress => iaddress,
            address  => address
        );

    iram_quartus_inst : entity work.iram_quartus
        port map(
            address => address,
            byteena => "1111",
            clock   => clk,
            data    => (others => '0'),
            wren    => '0',
            q       => idata
        );

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

    data_bus_mux : entity work.databusmux
        port map(
            dcsel          => dcsel,
            idata          => idata,
            ddata_r_mem    => ddata_r_mem,
            ddata_r_periph => ddata_r_periph,
            ddata_r_sdram  => ddata_r_sdram,
            ddata_r        => ddata_r
        );

    io_data_bus_mux : entity work.iodatabusmux
        port map(
            daddress               => daddress,
            ddata_r_gpio           => ddata_r_gpio,
            ddata_r_segments       => ddata_r_segments,
            ddata_r_uart           => (others => '0'),
            ddata_r_adc            => (others => '0'),
            ddata_r_i2c            => (others => '0'),
            ddata_r_timer          => (others => '0'),
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
            ddata_r_rgb            => (others => '0'),
            ddata_r_rtc            => ddata_r_rtc,
            ddata_r_periph         => ddata_r_periph
        );

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
            state      => cpu_state
        );

    process(gpio_interrupts, timer_interrupt)
    begin
        interrupts <= (others => '0');
        interrupts(24 downto 18) <= gpio_interrupts;
        interrupts(30 downto 25) <= timer_interrupt;
    end process;

    generic_gpio : entity work.gpio
        generic map(
            MY_CHIPSELECT   => "10",
            MY_WORD_ADDRESS => x"0000"
        )
        port map(
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

    generic_displays : entity work.led_displays
        generic map(
            MY_CHIPSELECT   => "10",
            MY_WORD_ADDRESS => x"0010"
        )
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
            hex6     => HEX6,
            hex7     => HEX7
        );

    rtc_inst : entity work.rtc2
        generic map(
            MY_CHIPSELECT   => "10",
            MY_WORD_ADDRESS => x"0190",
            CLOCK_HZ        => 1000
        )
        port map(
            clk      => clk,
            rst      => rst,
            daddress => daddress,
            ddata_w  => ddata_w,
            ddata_r  => ddata_r_rtc,
            d_we     => d_we,
            d_rd     => d_rd,
            dcsel    => dcsel,
            dmask    => dmask,
            sec_o    => rtc_sec,
            min_o    => rtc_min,
            hour_o   => rtc_hour
        );

    debug : entity work.trace_debug
        generic map(
            MEMORY_WORDS => IMEMORY_WORDS
        )
        port map(
            pc   => iaddress,
            data => idata,
            inst => debugString
        );

end architecture;