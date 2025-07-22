--! Testbench do softcore com periférico WS2812 integrado

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.decoder_types.all;

entity core_main_testbench is
	generic(
		IMEMORY_WORDS : integer := 1024;
		DMEMORY_WORDS : integer := 1024
	);
	port(
		HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : out std_logic_vector(7 downto 0);
		SW: in std_logic_vector(9 downto 0);
		LEDR: out std_logic_vector(9 downto 0);
		ARDUINO_IO: inout std_logic_vector(15 downto 0)
	);
end entity;

architecture RTL of core_main_testbench is
	signal clk, clk_32x, rst : std_logic;
	signal address : std_logic_vector(9 downto 0);
	signal iaddress : unsigned(15 downto 0);
	signal idata : std_logic_vector(31 downto 0);

	signal daddress : unsigned(31 downto 0);
	signal ddata_r, ddata_w : std_logic_vector(31 downto 0);
	signal dmask : std_logic_vector(3 downto 0);
	signal dcsel : std_logic_vector(1 downto 0);
	signal d_we, d_rd, d_sig : std_logic;
	signal ddata_r_mem, ddata_r_periph : std_logic_vector(31 downto 0);
	signal ddata_r_gpio, gpio_input, gpio_output : std_logic_vector(31 downto 0);
	signal ddata_r_timer : std_logic_vector(31 downto 0);
	signal timer_interrupt : std_logic_vector(5 downto 0);
	signal gpio_interrupts : std_logic_vector(6 downto 0);
	signal ddata_r_segments : std_logic_vector(31 downto 0);
	signal interrupts : std_logic_vector(31 downto 0);
	signal cpu_state : cpu_state_t;
	signal debugString : string(1 to 40) := (others => '0');
	signal ifcap : std_logic;

begin
	clock_driver : process
		constant period : time := 1000 ns;
	begin
		clk <= '0'; wait for period / 2;
		clk <= '1'; wait for period / 2;
	end process;

	clock_driver_32x : process
		constant period : time := 20 ns;
	begin
		clk_32x <= '0'; wait for period / 2;
		clk_32x <= '1'; wait for period / 2;
	end process;

	reset : process
	begin
		rst <= '1'; wait for 150 ns;
		rst <= '0'; wait;
	end process;

	LEDR <= gpio_output(9 downto 0);

	gpio_test: process
	begin
		gpio_input <= (others => '0');
		wait for 6 ms;
		gpio_input(0) <= '1'; wait for 1 us;
		gpio_input(0) <= '0';
		wait for 200 us;
		gpio_input(1) <= '1'; wait for 1 us;
		gpio_input(1) <= '0';
		wait;
	end process;

	instr_mux: entity work.instructionbusmux
		port map(
			d_rd => d_rd,
			dcsel => dcsel,
			daddress => daddress,
			iaddress => iaddress,
			address => address
		);

	iram_quartus_inst : entity work.iram_quartus
		port map(
			address => address(9 downto 0),
			byteena => "1111",
			clock => clk,
			data => (others => '0'),
			wren => '0',
			q => idata
		);
	dmem : entity work.dmemory
		generic map(MEMORY_WORDS => DMEMORY_WORDS)
		port map(
			rst => rst,
			clk => clk,
			data => ddata_w,
			address => daddress,
			we => d_we,
			signal_ext => d_sig,
			csel => dcsel(0),
			dmask => dmask,
			q => ddata_r_mem
		);

data_bus_mux: entity work.databusmux
	port map(
		dcsel => dcsel,
		idata => idata,
		ddata_r_mem => ddata_r_mem,
		ddata_r_periph => ddata_r_periph,
		ddata_r_sdram => (others => '0'),
		ddata_r => ddata_r
	);

io_data_bus_mux: entity work.iodatabusmux
	port map(
		daddress => daddress,
		ddata_r_gpio => ddata_r_gpio,
		ddata_r_segments => ddata_r_segments,
		ddata_r_uart => (others => '0'),
		ddata_r_adc => (others => '0'),
		ddata_r_i2c => (others => '0'),
		ddata_r_timer => ddata_r_timer,
		ddata_r_dif_fil => (others => '0'),
		ddata_r_stepmot => (others => '0'),
		ddata_r_lcd => (others => '0'),
		ddata_r_nn_accelerator => (others => '0'),
		ddata_r_fir_fil => (others => '0'),
		ddata_r_spwm => (others => '0'),
		ddata_r_crc => (others => '0'),
		ddata_r_key => (others => '0'),
		ddata_r_accelerometer => (others => '0'),
		ddata_r_cordic => (others => '0'),
		ddata_r_RS485 => (others => '0'),
        --ddata_r_rgb => (others => '0'),
		ddata_r_periph => ddata_r_periph
	);

	myRiscv : entity work.core
		port map(
			clk => clk,
			rst => rst,
			clk_32x => clk_32x,
			iaddress => iaddress,
			idata => idata,
			daddress => daddress,
			ddata_r => ddata_r,
			ddata_w => ddata_w,
			d_we => d_we,
			d_rd => d_rd,
			d_sig => d_sig,
			dcsel => dcsel,
			dmask => dmask,
			interrupts => interrupts,
			state => cpu_state
		);

	irq_signals: process(timer_interrupt, gpio_interrupts)
	begin
		interrupts <= (others => '0');
		interrupts(24 downto 18) <= gpio_interrupts;
		interrupts(30 downto 25) <= timer_interrupt;
	end process;

	timer : entity work.Timer
		generic map(prescaler_size => 16, compare_size => 32)
		port map(
			clock => clk,
			reset => rst,
			daddress => daddress,
			ddata_w => ddata_w,
			ddata_r => ddata_r_timer,
			d_we => d_we,
			d_rd => d_rd,
			dcsel => dcsel,
			dmask => dmask,
			timer_interrupt => timer_interrupt,
			ifcap => ifcap
		);

	generic_gpio : entity work.gpio
		port map(
			clk => clk,
			rst => rst,
			daddress => daddress,
			ddata_w => ddata_w,
			ddata_r => ddata_r_gpio,
			d_we => d_we,
			d_rd => d_rd,
			dcsel => dcsel,
			dmask => dmask,
			input => gpio_input,
			output => gpio_output,
			gpio_interrupts => gpio_interrupts
		);

	generic_displays : entity work.led_displays
		port map(
			clk => clk,
			rst => rst,
			daddress => daddress,
			ddata_w => ddata_w,
			ddata_r => ddata_r_segments,
			d_we => d_we,
			d_rd => d_rd,
			dcsel => dcsel,
			dmask => dmask,
			hex0 => HEX0,
			hex1 => HEX1,
			hex2 => HEX2,
			hex3 => HEX3,
			hex4 => HEX4,
			hex5 => HEX5,
			hex6 => open,
			hex7 => open
		);

	led_controller_inst : entity work.led_controller_wrapper
		generic map(
			MY_CHIPSELECT => "10",
			DADDRESS_BUS_SIZE => 32
		)
		port map(
			clk => clk,
			rst => rst,
			daddress => daddress,
			ddata_w => ddata_w,
			d_we => d_we,
			dcsel => dcsel,
			dmask => dmask,
			dout => ARDUINO_IO(8)
		);
	ddata_r_periph <= (others => '0');

	debug : entity work.trace_debug
		generic map(MEMORY_WORDS => IMEMORY_WORDS)
		port map(pc => iaddress, data => idata, inst => debugString);

end architecture;
