-------------------------------------------------------------------
-- Name        : de10_lite.vhd
-- Author      :
-- Version     : 0.2
-- Copyright   : Departamento de Eletrônica, Florianópolis, IFSC
-- Description : Projeto base DE10-Lite com VGA
-------------------------------------------------------------------
LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.decoder_types.all;

entity de10_lite is
	generic (
		--! Num of 32-bits memory words
		IMEMORY_WORDS : integer := 1024;	--!= 4K (1024 * 4) bytes
		DMEMORY_WORDS : integer := 1024  	--!= 4K (1024 * 4) bytes
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


architecture rtl of de10_lite is

	signal clk : std_logic;
	signal rst : std_logic;

	-- Instruction bus signals
	signal idata     : std_logic_vector(31 downto 0);
	signal iaddress  : unsigned(15 downto 0);
	signal address   : std_logic_vector (9 downto 0);

	-- Data bus signals
	signal daddress  : unsigned(31 downto 0);
	signal ddata_r   : std_logic_vector(31 downto 0);
	signal ddata_w   : std_logic_vector(31 downto 0);
	signal dmask     : std_logic_vector(3 downto 0);
	signal dcsel     : std_logic_vector(1 downto 0);
	signal d_we      : std_logic := '0';
	signal d_rd      : std_logic;
	signal d_sig     : std_logic;

	signal ddata_r_mem : std_logic_vector(31 downto 0);

	-- I/O signals
	signal input_in : std_logic_vector(31 downto 0);

	-- PLL signals
	signal locked_sig : std_logic;

	-- CPU state signals
	signal state : cpu_state_t;

	-- Interrupt signals
	signal interrupts : std_logic_vector(31 downto 0);

	-- VGA Signals
	signal clk_sdram : std_logic;                       -- 125 MHz cache domain
	signal clk_vga   : std_logic;                       -- 25 MHz pixel clock (PLL c1)
	signal clk_vga_d : std_logic;
	signal pixel_en  : std_logic;                       -- pixel tick in the 125 MHz domain
	signal disp_ena  : std_logic;
	signal hsync_sig : std_logic;
	signal vsync_sig : std_logic;
	signal addr_vga  : std_logic_vector(12 downto 0);
	signal rgb_in    : std_logic_vector(15 downto 0);
	signal wren_dm   : std_logic;
	signal wren_vga  : std_logic;

	-- VGA read-back (dcsel = "11")
	signal ddata_r_sdram : std_logic_vector(31 downto 0);

begin

	rst <= SW(9);
	LEDR(9) <= SW(9);

	-- No interrupts used in this design
	interrupts <= (others => '0');

	ARDUINO_IO <= (others => 'Z');

	-- PLL: c0 = CPU clock, c1 = 25 MHz pixel clock, c2 = 125 MHz SDRAM/cache domain
	pll_inst: entity work.pll
		port map(
			areset => rst,
			inclk0 => MAX10_CLK1_50,
			c0     => clk,
			c1     => clk_vga,
			c2     => clk_sdram,
			locked => locked_sig
		);

	process(clk_sdram, rst)
	begin
		if rst = '1' then
			clk_vga_d <= '0';
			pixel_en <= '0';
		elsif rising_edge(clk_sdram) then
			clk_vga_d <= clk_vga;
			pixel_en <= clk_vga and (not clk_vga_d);
		end if;
	end process;

	-- Instruction bus mux
	instr_mux: entity work.instructionbusmux
		port map(
			d_rd     => d_rd,
			dcsel    => dcsel,
			daddress => daddress,
			iaddress => iaddress,
			address  => address
		);

	-- 32-bits x 1024 words quartus RAM
	iram_quartus_inst: entity work.iram_quartus
		port map(
			address => address,
			byteena => "1111",
			clock   => clk,
			data    => (others => '0'),
			wren    => '0',
			q       => idata
		);

	-- VGA write enable: dcsel = "11" selects VGA memory
	process(dcsel, d_we)
	begin
		if dcsel = "11" then
			wren_vga <= d_we;
			wren_dm  <= '0';
		else
			wren_vga <= '0';
			wren_dm  <= d_we;
		end if;
	end process;

	-- Data Memory RAM
	dmem: entity work.dmemory
		generic map(
			MEMORY_WORDS => DMEMORY_WORDS
		)
		port map(
			rst        => rst,
			clk        => clk,
			data       => ddata_w,
			address    => daddress,
			we         => wren_dm,
			csel       => dcsel(0),
			dmask      => dmask,
			signal_ext => d_sig,
			q          => ddata_r_mem
		);

	-- VGA write address from CPU data address (limited to 13 bits = 8192 words)
	vgaaddrwr <= std_logic_vector(daddress(12 downto 0));

	-- VGA dual-port RAM
	vgamem: entity work.ram_vga
		port map(
			data      => ddata_w(15 downto 0),
			rdaddress => addr_vga,
			rdclock   => clk_vga,
			wraddress => vgaaddrwr,
			wrclock   => clk,
			wren      => wren_vga,
			q         => rgb_in
		);

	-- VGA controller (640x480 @ 60Hz, 25MHz pixel clock)
	vgactrl: entity work.vga_controller
		generic map(
			h_pulse  => 96,
			h_bp     => 48,
			h_pixels => 640,
			h_fp     => 16,
			h_pol    => '0',
			v_pulse  => 2,
			v_bp     => 33,
			v_pixels => 480,
			v_fp     => 10,
			v_pol    => '0'
		)
		port map(
			pixel_clk => clk_vga,
			reset     => rst,
			h_sync    => hsync_sig,
			v_sync    => vsync_sig,
			disp_ena  => disp_ena,
			column    => open,
			row       => open,
			addr      => addr_vga,
			n_blank   => open,
			n_sync    => open
		);

	VGA_HS <= hsync_sig;
	VGA_VS <= vsync_sig;

	-- Framebuffer status on spare LEDs --

	-- VGA image generator (extracts RGB from RAM data)
	vgaimg: entity work.hw_image_generator
		port map(
			disp_ena => disp_ena,
			rgb_in   => rgb_in,
			red      => VGA_R,
			green    => VGA_G,
			blue     => VGA_B
		);

	-- No read-back from VGA memory for now
	ddata_r_sdram <= (others => '0');

	-- Data bus mux
	datamux: entity work.databusmux
		port map(
			dcsel          => dcsel,
			idata          => idata,
			ddata_r_mem    => ddata_r_mem,
			ddata_r_periph => input_in,
			ddata_r_sdram  => ddata_r_sdram,
			ddata_r        => ddata_r
		);

	-- Softcore instantiation
	myRiscv: entity work.core
		port map(
			clk      => clk,
			rst      => rst,
			clk_32x  => MAX10_CLK1_50,
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
			interrupts => interrupts,
			state    => state
		);

	-- Output register (LED and HEX display via I/O space dcsel = "10")
	process(clk, rst)
	begin
		if rst = '1' then
			LEDR(3 downto 0) <= (others => '0');
			HEX0 <= (others => '1');
			HEX1 <= (others => '1');
			HEX2 <= (others => '1');
			HEX3 <= (others => '1');
			HEX4 <= (others => '1');
			HEX5 <= (others => '1');
		else
			if rising_edge(clk) then
				if (d_we = '1') and (dcsel = "10") then
					if daddress(8 downto 0) = "000000001" then
						LEDR(4 downto 0) <= ddata_w(4 downto 0);
					elsif daddress(8 downto 0) = "000000010" then
					 	HEX0 <= ddata_w(7 downto 0);
						HEX1 <= ddata_w(15 downto 8);
						HEX2 <= ddata_w(23 downto 16);
						HEX3 <= ddata_w(31 downto 24);
					end if;
				end if;
			end if;
		end if;
	end process;

	-- Input register
	process(clk, rst)
	begin
		if rst = '1' then
			input_in <= (others => '0');
		else
			if rising_edge(clk) then
				if (d_rd = '1') and (dcsel = "10") then
					input_in(4 downto 0) <= SW(4 downto 0);
				end if;
			end if;
		end if;
	end process;

end;
