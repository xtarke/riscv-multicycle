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
	generic (
		--! Num of 32-bits memory words 
		IMEMORY_WORDS : integer := 1024;	--!= 4K (1024 * 4) bytes
		DMEMORY_WORDS : integer := 4096  	--!= 8k (512 * 2) bytes
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
	signal iaddress  : integer range 0 to IMEMORY_WORDS-1 := 0;
	signal address   : std_logic_vector (9 downto 0);
	
	-- Data bus signals
	signal daddress :  integer range 0 to DMEMORY_WORDS-1;
	signal ddata_r	:  	std_logic_vector(31 downto 0);
	signal ddata_w  :	std_logic_vector(31 downto 0);
	signal dmask    : std_logic_vector(3 downto 0);
	signal dcsel    : std_logic_vector(1 downto 0);
	signal d_we     : std_logic := '0';
	
	signal ddata_r_mem : std_logic_vector(31 downto 0);
	signal d_rd : std_logic;			
	
	-- I/O signals
	signal input_in : std_logic_vector(31 downto 0);
	
	-- PLL signals
	signal locked_sig : std_logic;
	
	-- CPU state signals
	signal state : cpu_state_t;
	
	-- VGA Signals
	signal clk_vga : STD_LOGIC;
	signal disp_ena : STD_LOGIC;
	signal addr_vga : std_logic_vector(12 downto 0);
	signal rgb_in : std_logic_vector(15 downto 0);
	signal wren_dm : std_logic;
	signal wren_vga : std_logic;
	signal vgaaddrwr : std_logic_vector(12 downto 0);
	
begin
	
	pll_inst: entity work.pll
		port map(
			areset => rst,
			inclk0 => MAX10_CLK1_50,
			c0     => clk,
			c1     => clk_vga,
			locked => locked_sig
		);
	
	rst <= SW(9);
	
	-- Dummy out signals
	DRAM_DQ <= ddata_r(15 downto 0);
	ARDUINO_IO <= ddata_r(31 downto 16);
	LEDR(9) <= SW(9);
	DRAM_ADDR(9 downto 0) <= address;
		
	-- IMem shoud be read from instruction and data buses
	-- Not enough RAM ports for instruction bus, data bus and in-circuit programming
	process(d_rd, dcsel, daddress, iaddress)
	begin
		if (d_rd = '1') and (dcsel = "00") then
			address <= std_logic_vector(to_unsigned(daddress,10));
		else
			address <= std_logic_vector(to_unsigned(iaddress,10));
		end if;		
	end process;

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
		
	process(dcsel, d_we)
	begin
		if dcsel = "11" then
			wren_vga <= d_we; -- write to vga
			wren_dm  <= '0';
		else
			wren_vga <= '0';
			wren_dm  <= d_we; -- write do data memory
		end if;
	end process;
	
	-- Data Memory RAM
	dmem: entity work.dmemory
		generic map(
			MEMORY_WORDS => DMEMORY_WORDS
		)
		port map(
			rst     => rst,
			clk     => clk,
			data    => ddata_w,
			address => daddress,
			we      => wren_dm,
			csel    => dcsel(0),
			dmask   => dmask,
			q       => ddata_r_mem
		);
	
	vgaaddrwr <= Std_logic_vector(To_unsigned(daddress,13));
	
	vgamem : entity work.ram_vga
		port map(
			data      => ddata_w(15 downto 0),
			rdaddress => addr_vga,
			rdclock   => clk_vga,
			wraddress => vgaaddrwr,
			wrclock   => clk,
			wren      => wren_vga,
			q         => rgb_in
		);
	
	vgactrl: entity work.vga_controller
		port map(
			pixel_clk => clk_vga,
			reset     => rst,
			h_sync    => VGA_HS,
			v_sync    => VGA_VS,
			disp_ena  => disp_ena,
			column    => open,
			row       => open,
			addr      => addr_vga,
			n_blank   => open,
			n_sync    => open
		);
	vgaimg: entity work.hw_image_generator
		port map(
			disp_ena => disp_ena,
			rgb_in   => rgb_in,
			red      => VGA_R,
			green    => VGA_G,
			blue     => VGA_B
		);
		
	-- Address space (check sections.ld) and chip select:
	-- 0x0000000000 ->  0b000 0000 0000 0000 0000 0000 0000
	-- 0x0002000000 ->  0b010 0000 0000 0000 0000 0000 0000		
	-- 0x0004000000 ->  0b100 0000 0000 0000 0000 0000 0000
	-- 0x0006000000 ->  0b110 0000 0000 0000 0000 0000 0000		
	with dcsel select 
		ddata_r <= idata when "00",
		           ddata_r_mem when "01",
		           input_in when "10",
		           (others => '0') when others;
	
	-- Softcore instatiation
	myRisc: entity work.core
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
	
	-- Output register (Dummy LED blinky)
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
				if (d_we = '1') and (dcsel = "10")then					
					-- ToDo: Simplify compartors
					-- ToDo: Maybe use byte addressing?  
					--       x"01" (word addressing) is x"04" (byte addressing)
					if to_unsigned(daddress, 32)(8 downto 0) = x"01" then										
						LEDR(4 downto 0) <= ddata_w(4 downto 0);
					elsif to_unsigned(daddress, 32)(8 downto 0) = x"02" then
					 	HEX0 <= ddata_w(7 downto 0);
						HEX1 <= ddata_w(15 downto 8);
						HEX2 <= ddata_w(23 downto 16);
						HEX3 <= ddata_w(31 downto 24);
						-- HEX4 <= ddata_w(7 downto 0);
						-- HEX5 <= ddata_w(7 downto 0);
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

