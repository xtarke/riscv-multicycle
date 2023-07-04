-------------------------------------------------------------------
-- Name        : de0_lite.vhd
-- Author      :
-- Version     : 0.1
-- Copyright   : Departamento de Eletrônica, Florianópolis, IFSC
-- Description : Projeto base DE10-Lite
-------------------------------------------------------------------
LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.decoder_types.all;

entity de0_lite is
	generic (
		--! Num of 32-bits memory words
		IMEMORY_WORDS : integer := 1024;	--!= 4K (1024 * 4) bytes
		DMEMORY_WORDS : integer := 1024  	--!= 2k (512 * 2) bytes
	);
	port (
		---------- CLOCK ----------
		ADC_CLK_10:	in std_logic;
		MAX10_CLK1_50: in std_logic;
		MAX10_CLK2_50: in std_logic;

		----------- SDRAM ------------
		DRAM_ADDR: out std_logic_vector (12 downto 0);
		DRAM_BA: out std_logic_vector (1 downto 0);
		DRAM_CAS_N: out std_logic;
		DRAM_CKE: out std_logic;
		DRAM_CLK: out std_logic;
		DRAM_CS_N: out std_logic;
		DRAM_DQ: inout std_logic_vector(15 downto 0);
		DRAM_LDQM: out std_logic;
		DRAM_RAS_N: out std_logic;
		DRAM_UDQM: out std_logic;
		DRAM_WE_N: out std_logic;

		----------- SEG7 ------------
		HEX0: out std_logic_vector(7 downto 0);
		HEX1: out std_logic_vector(7 downto 0);
		HEX2: out std_logic_vector(7 downto 0);
		HEX3: out std_logic_vector(7 downto 0);
		HEX4: out std_logic_vector(7 downto 0);
		HEX5: out std_logic_vector(7 downto 0);

		----------- KEY ------------
		KEY: in std_logic_vector(1 downto 0);

		----------- LED ------------
		LEDR: out std_logic_vector(9 downto 0);

		----------- SW ------------
		SW: in std_logic_vector(9 downto 0);

		----------- VGA ------------
		VGA_B: out std_logic_vector(3 downto 0);
		VGA_G: out std_logic_vector(3 downto 0);
		VGA_HS: out std_logic;
		VGA_R: out std_logic_vector(3 downto 0);
		VGA_VS: out std_logic;

		----------- Accelerometer ------------
		GSENSOR_CS_N: out std_logic;
		GSENSOR_INT: in std_logic_vector(2 downto 1);
		GSENSOR_SCLK: out std_logic;
		GSENSOR_SDI: inout std_logic;
		GSENSOR_SDO: inout std_logic;

		----------- Arduino ------------
		ARDUINO_IO: inout std_logic_vector(15 downto 0);
		ARDUINO_RESET_N: inout std_logic
	);
end entity;



architecture rtl of de0_lite is
    -- Clocks and reset
    signal clk : std_logic;
    signal rst : std_logic;
    signal clk_50MHz : std_logic;
    -- PLL signals
    signal locked_sig : std_logic;

    -- Instruction bus signals
    signal idata     : std_logic_vector(31 downto 0);
    signal iaddress : unsigned(15 downto 0);
    signal address   : std_logic_vector (9 downto 0);

    -- Data bus signals
    signal daddress : unsigned(31 downto 0);
    signal ddata_r	:  	std_logic_vector(31 downto 0);
    signal ddata_w  :	std_logic_vector(31 downto 0);
    signal ddata_r_mem : std_logic_vector(31 downto 0);
    signal dmask    : std_logic_vector(3 downto 0);
    signal dcsel    : std_logic_vector(1 downto 0);
    signal d_we     : std_logic;
    signal d_rd     : std_logic;
    signal d_sig    : std_logic;

    -- SDRAM signals
    signal ddata_r_sdram : std_logic_vector(31 downto 0);

    -- CPU state signals
    signal state : cpu_state_t;
    signal div_result : std_logic_vector(31 downto 0);

    -- I/O signals
    signal gpio_input : std_logic_vector(31 downto 0);
    signal gpio_output : std_logic_vector(31 downto 0);

    -- Peripheral data signals
    signal ddata_r_gpio : std_logic_vector(31 downto 0);
    signal ddata_r_timer : std_logic_vector(31 downto 0);
    signal ddata_r_periph : std_logic_vector(31 downto 0);
    signal ddata_r_segments : std_logic_vector(31 downto 0);
    signal ddata_r_uart : std_logic_vector(31 downto 0);
    signal ddata_r_adc : std_logic_vector(31 downto 0);
    signal ddata_r_i2c : std_logic_vector(31 downto 0);
    signal ddata_r_dig_fil : std_logic_vector(31 downto 0);
    signal ddata_r_stepmot : std_logic_vector(31 downto 0);
    signal ddata_r_lcd : std_logic_vector(31 downto 0);
		signal ddata_r_nn_accelerator : std_logic_vector(31 downto 0);
		signal ddata_r_fir_fil : std_logic_vector(31 downto 0);

    -- Interrupt Signals
    signal interrupts : std_logic_vector(31 downto 0);
    signal gpio_interrupts : std_logic_vector(6 downto 0);
    signal timer_interrupt : std_logic_vector(5 downto 0);

    -- I/O signals
    signal input_in : std_logic_vector(31 downto 0);

begin

    -- Reset
    rst <= SW(9);
    LEDR(9) <= SW(9);

    -- Clocks
	pll_inst : entity work.pll
		port map(
			areset	=> '0',
			inclk0 	=> MAX10_CLK1_50,
			c0		 	=> clk,
			c1	 		=> clk_50MHz,
			locked	=> locked_sig
		);

	-- 32-bits x 1024 words quartus RAM (dual port: portA -> riscV, portB -> In-System Mem Editor
	iram_quartus_inst: entity work.iram_quartus
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
    instr_mux: entity work.instructionbusmux
        port map(
            d_rd     => d_rd,
            dcsel    => dcsel,
            daddress => daddress,
            iaddress => iaddress,
            address  => address
        );

	-- Data Memory RAM
	dmem: entity work.dmemory
		generic map(
			MEMORY_WORDS => DMEMORY_WORDS
		)
		port map(
			rst => rst,
			clk => clk,
			data => ddata_w,
			address => daddress,
			we => d_we,
			csel => dcsel(0),
			dmask => dmask,
			signal_ext => d_sig,
			q => ddata_r_mem
		);

	-- Adress space mux ((check sections.ld) -> Data chip select:
	-- 0x00000    ->    Instruction memory
	-- 0x20000    ->    Data memory
	-- 0x40000    ->    Input/Output generic address space
	-- ( ... )    ->    ( ... )
	datamux: entity work.databusmux
		port map(
			dcsel        => dcsel,
			idata        => idata,
			ddata_r_mem  => ddata_r_mem,
			ddata_r_periph => ddata_r_periph,
			ddata_r_sdram =>ddata_r_sdram,
			ddata_r      => ddata_r
		);

	-- Softcore instatiation
	myRiscv : entity work.core
		port map(
			clk      => clk,
			rst      => rst,
			clk_32x  => clk_50MHz,
			iaddress => iaddress,
			idata    => idata,
			daddress => daddress,
			ddata_r  => ddata_r,
			ddata_w  => ddata_w,
			d_we     => d_we,
			d_rd     => d_rd,
			d_sig	 => d_sig,
			dcsel    => dcsel,
			dmask    => dmask,
			interrupts=>interrupts,
			state    => state
		);

		-- IRQ lines
		interrupts(24 downto 18) <= gpio_interrupts(6 downto 0);
		interrupts(30 downto 25) <= timer_interrupt;

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
            ddata_r_dif_fil  => ddata_r_dig_fil,
						ddata_r_stepmot  => ddata_r_stepmot,
						ddata_r_lcd      => ddata_r_lcd,
						ddata_r_fir_fil  => ddata_r_fir_fil,
						ddata_r_nn_accelerator => ddata_r_nn_accelerator
        );

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

			-- Connect input hardware to gpio data
			gpio_input(3 downto 0) <= SW(3 downto 0);
			LEDR(7 downto 0) <= gpio_output(7 downto 0);

end;

