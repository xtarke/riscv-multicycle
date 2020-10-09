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

entity de10_lite is
	generic(
		--! Num of 32-bits memory words 
		IMEMORY_WORDS : integer := 1024; --!= 4K (1024 * 4) bytes
		DMEMORY_WORDS : integer := 1024 --!= 2k (512 * 2) bytes
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

architecture rtl of de10_lite is

	signal clk       : std_logic;
	signal clk_sdram_ctrl       : std_logic;


	signal rst   : std_logic;

	-- Instruction bus signals
	signal idata    : std_logic_vector(31 downto 0);
	signal iaddress : integer range 0 to IMEMORY_WORDS - 1 := 0;
	signal address  : std_logic_vector(9 downto 0);

	-- Data bus signals
	signal daddress : natural;
	signal ddata_r  : std_logic_vector(31 downto 0);
	signal ddata_w  : std_logic_vector(31 downto 0);
	signal dmask    : std_logic_vector(3 downto 0);
	signal dcsel    : std_logic_vector(1 downto 0);
	signal d_we     : std_logic := '0';

	signal ddata_r_mem : std_logic_vector(31 downto 0);
	signal d_rd        : std_logic;

	signal dmemory_address : natural;

	-- I/O signals
	signal input_in : std_logic_vector(31 downto 0);
	signal ddata_r_gpio : std_logic_vector(31 downto 0);

	-- PLL signals
	signal locked_sig : std_logic;

	-- CPU state signals
	signal state : cpu_state_t;

	-- SDRAM signals
	signal daddress_to_sdram : std_logic_vector(31 downto 0);
	signal sdram_addr        : std_logic_vector(31 downto 0);
	signal chipselect_sdram  : std_logic;
	signal sdram_d_rd        : std_logic;
	signal sdram_read        : std_logic_vector(15 DOWNTO 0);
	signal sdram_read_32     : std_logic_vector(31 downto 0);
	signal waitrequest       : std_logic;
	signal DRAM_DQM          : std_logic_vector(1 downto 0);
	signal burst             : std_logic;
	signal byteenable		 : std_logic_vector(1 downto 0);

	signal gpio_input : std_logic_vector(31 downto 0);
	signal gpio_output : std_logic_vector(31 downto 0);

begin

	pll_inst : entity work.pll
		port map(
			areset => '0',
			inclk0 => MAX10_CLK1_50,
			c0     => clk,
			c1     => clk_sdram_ctrl,
			c2     => open,
			c3 	 => open,
			locked => locked_sig
		);

	rst   <= SW(9);

	-- Dummy out signals
	ARDUINO_IO <= ddata_r(31 downto 16);
	LEDR(9)    <= SW(9);

	-- IMem shoud be read from instruction and data buses
	-- Not enough RAM ports for instruction bus, data bus and in-circuit programming
	process(d_rd, dcsel, daddress, iaddress)
	begin
		if (d_rd = '1') and (dcsel = "00") then
			address <= std_logic_vector(to_unsigned(daddress, 10));
		else
			address <= std_logic_vector(to_unsigned(iaddress, 10));
		end if;
	end process;

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

	dmemory_address <= to_integer(to_unsigned(daddress, 10));
	-- Data Memory RAM
	dmem : entity work.dmemory
		generic map(
			MEMORY_WORDS => DMEMORY_WORDS
		)
		port map(
			rst     => rst,
			clk     => clk,
			data    => ddata_w,
			address => dmemory_address,
			we      => d_we,
			csel    => dcsel(0),
			dmask   => dmask,
			signal_ext => '0',
			q       => ddata_r_mem
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
			ddata_r_gpio => ddata_r_gpio,
			ddata_r_sdram=> sdram_read_32,
			ddata_r      => ddata_r
		);
	

	-- sdram output is 16 bits while data bus is 32 bits
	sdram_read_32 <= x"0000" & sdram_read;

	-- Softcore instatiation
	myRisc : entity work.core
		generic map(
			IMEMORY_WORDS => IMEMORY_WORDS,
			DMEMORY_WORDS => DMEMORY_WORDS
		)
		port map(
			clk      => clk,
			rst      => rst,
			iaddress => iaddress,
			idata    => idata,
			daddress => daddress,
			ddata_r  => ddata_r,
			ddata_w  => ddata_w,
			d_we     => d_we,
			d_rd     => d_rd,
			dcsel    => dcsel,
			dmask    => dmask,
			state    => state
		);



	sdram_addr <= daddress_to_sdram;
	sdram_d_rd <= d_rd;
	burst <='0'; 								-- Todo Adicionar suporte a 32bits

	-- SDRAM instatiation
	sdram_controller : entity work.sdram_controller
		port map(
			address     => sdram_addr,
			byteenable  => dmask(1 downto 0),
			chipselect  => chipselect_sdram,
			clk         => clk_sdram_ctrl,
			clken       => dmask(0),
			reset       => rst,
			reset_req   => rst,
			write       => d_we,
			read        => sdram_d_rd,
			writedata   => ddata_w,
			burst       => burst,
			-- outputs:
			readdata    => sdram_read,
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

	-- SDRAM Signals
	daddress_to_sdram <= std_logic_vector(to_unsigned(daddress, 32));
	DRAM_UDQM         <= DRAM_DQM(1);
	DRAM_LDQM         <= DRAM_DQM(0);
	chipselect_sdram  <= dcsel(0) and dcsel(1);
	byteenable <= "11";

	generic_gpio: entity work.gpio
		generic map(
			MY_CHIPSELECT   => "10",
			MY_WORD_ADDRESS => x"10"
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
			output   => gpio_output
		);
	
	-- Connect gpio data to output hardware
	LEDR(7 downto 0) <= gpio_output(7 downto 0);
	gpio_input(7 downto 0) <= SW(7 downto 0);
	--LEDR(7 downto 0) <= sdram_read(7 downto 0);
	
	-- Turn off all HEX displays
	HEX0 <= (others => '1');
	HEX1 <= (others => '1');	
	HEX2 <= (others => '1');
	HEX3 <= (others => '1');
	HEX4 <= (others => '1');
	HEX5 <= (others => '1');

end;

 