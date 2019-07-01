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
	
	
	--=====================================================
	--DECLARACAO COMPONENTE ADC
	-------------------------------------------------------	
	-- qsys MAX10 ADC component
	component adc_qsys is
		port(
			clk_clk                              : in  std_logic                    := 'X'; -- clk
			clock_bridge_sys_out_clk_clk         : out std_logic; -- clk
			modular_adc_0_command_valid          : in  std_logic                    := 'X'; -- valid
			modular_adc_0_command_channel        : in  std_logic_vector(4 downto 0) := (others => 'X'); -- channel
			modular_adc_0_command_startofpacket  : in  std_logic                    := 'X'; -- startofpacket
			modular_adc_0_command_endofpacket    : in  std_logic                    := 'X'; -- endofpacket
			modular_adc_0_command_ready          : out std_logic; -- ready
			modular_adc_0_response_valid         : out std_logic; -- valid
			modular_adc_0_response_channel       : out std_logic_vector(4 downto 0); -- channel
			modular_adc_0_response_data          : out std_logic_vector(11 downto 0); -- data
			modular_adc_0_response_startofpacket : out std_logic; -- startofpacket
			modular_adc_0_response_endofpacket   : out std_logic; -- endofpacket
			reset_reset_n                        : in  std_logic                    := 'X' -- reset_n
		);
	end component adc_qsys;

	--=====================================================
	--DECLARACAO DISPLAY COMPONENTE
	-------------------------------------------------------
	
	component display_dec is
		port(
			hex  : in  std_logic_vector(3 downto 0);
			dot  : in  std_logic;
			disp : out std_logic_vector(7 downto 0)
		);
	end component display_dec;

	type displays_type is array (0 to 5) of std_logic_vector(3 downto 0);
	type displays_out_type is array (0 to 5) of std_logic_vector(7 downto 0);

	signal displays     : displays_type;
	signal displays_out : displays_out_type;
	
	--=======================================================
	--SINAIS PARA adc_max
	--=======================================================
	
	signal adc_out_clk            : std_logic;
	signal command_valid          : std_logic;
	signal command_channel        : std_logic_vector(4 downto 0);
	signal command_startofpacket  : std_logic;
	signal command_endofpacket    : std_logic;
	signal command_ready          : std_logic;
	signal response_valid         : std_logic;
	signal response_channel       : std_logic_vector(4 downto 0);
	signal response_data          : std_logic_vector(11 downto 0);
	signal response_startofpacket : std_logic;
	signal response_endofpacket   : std_logic;

	signal adc_sample_data : std_logic_vector(11 downto 0);
	signal cur_adc_ch      : std_logic_vector(4 downto 0);
	signal reset     : std_logic;
	signal reset_n   : std_logic;
	
	
begin
	
	--=======================================================
	--GENERATE DISPLAYS
	--=======================================================
	
		hex_gen : for i in 0 to 5 generate
		hex_dec : display_dec
			port map(
				hex  => displays(i),
				dot  => '0',
				disp => displays_out(i)
			);
	end generate;
	
	HEX0 <= displays_out(0);
	HEX1 <= displays_out(1);
	HEX2 <= displays_out(2);
	HEX3 <= displays_out(3);
	HEX4 <= displays_out(4);
	HEX5 <= displays_out(5);
	
	--=====================================================
	--PORTMAP ADC
	-------------------------------------------------------	
	u0 : component adc_qsys
		port map(
			clk_clk                              => MAX10_CLK1_50,
			clock_bridge_sys_out_clk_clk         => adc_out_clk,
			modular_adc_0_command_valid          => command_valid,
			modular_adc_0_command_channel        => command_channel,
			modular_adc_0_command_startofpacket  => command_startofpacket,
			modular_adc_0_command_endofpacket    => command_endofpacket,
			modular_adc_0_command_ready          => command_ready,
			modular_adc_0_response_valid         => response_valid,
			modular_adc_0_response_channel       => response_channel,
			modular_adc_0_response_data          => response_data,
			modular_adc_0_response_startofpacket => response_startofpacket,
			modular_adc_0_response_endofpacket   => response_endofpacket,
			reset_reset_n                        => reset_n --reset_n
		);	
		
	--=====================================================
	command_startofpacket <= '1';
	command_endofpacket   <= '1';
	command_valid         <= '1';

	reset           <= SW(8);			--sw(9) e reset do ADC
	reset_n         <= not reset;
	LEDR(8)         <= reset;

	--=====================================================
	--process para ler adc
	--=====================================================		           
		           
	process(adc_out_clk, reset) --adc_out_clk
	begin
		if reset = '1' then
			adc_sample_data <= (others => '0');
			cur_adc_ch      <= (others => '0');
		else
			if (rising_edge(adc_out_clk) and response_valid = '1') then --adc_out_clk
				adc_sample_data <= response_data;
				cur_adc_ch      <= response_channel;
			end if;
		end if;
	end process;
	
	--=====================================================
	
	
	
	
	pll_inst: entity work.pll
		port map(
			areset => '0',
			inclk0 => MAX10_CLK1_50,
			c0     => clk,
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
			we      => d_we,
			csel    => dcsel(0),
			dmask   => dmask,
			q       => ddata_r_mem
		);
	
	-- Adress space mux ((check sections.ld) -> Data chip select:
	-- 0x00000    ->    Instruction memory
	-- 0x20000    ->    Data memory
	-- 0x40000    ->    Input/Output generic address space		
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
			
		else
			if rising_edge(clk) then		
				if (d_we = '1') and (dcsel = "10")then					
					-- ToDo: Simplify compartors
					-- ToDo: Maybe use byte addressing?  
					--       x"01" (word addressing) is x"04" (byte addressing)
					
					if to_unsigned(daddress, 32)(8 downto 0) = x"02" then --SEL_CH_ADC										
						command_channel <= ddata_w(4 downto 0);
						
--					elsif to_unsigned(daddress, 32)(8 downto 0) = x"01" then --CH_ADC_FEED
						
						
					elsif to_unsigned(daddress, 32)(8 downto 0) = x"03" then --OUT_SEGS
					 	displays(0) <= ddata_w(3 downto 0);
						displays(1) <= ddata_w(7 downto 4);
						displays(2) <= ddata_w(11 downto 8);
						displays(3) <= ddata_w(15 downto 12);
						displays(4) <= ddata_w(19 downto 16);
						displays(5) <= ddata_w(23 downto 20);
						
						
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
				if (d_we = '1') and (dcsel = "10") then
--					input_in(8 downto 0) <= SW(8 downto 0);
					input_in(11 downto 0) <= adc_sample_data;
					input_in(15 downto 12) <= cur_adc_ch(3 downto 0);
														
				end if;
			end if;
		end if;		
	end process;
	

end;

