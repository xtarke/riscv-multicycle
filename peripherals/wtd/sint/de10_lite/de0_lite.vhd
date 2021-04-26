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
	signal clk_50MHz : std_logic;
	
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
	signal input_in	: std_logic_vector(31 downto 0);
	
	-- SDRAM signals
	signal ddata_r_sdram : std_logic_vector(31 downto 0);
	
	
	-- PLL signals
	signal locked_sig : std_logic;
	
	-- CPU state signals
	signal state : cpu_state_t;
	signal d_sig : std_logic;
	
	-- I/O signals
	signal gpio_input : std_logic_vector(31 downto 0);
	signal gpio_output : std_logic_vector(31 downto 0);
	
	-- Peripheral data signals
   signal ddata_r_gpio : std_logic_vector(31 downto 0);
   signal ddata_r_timer : std_logic_vector(31 downto 0); 
   signal ddata_r_wtd : std_logic_vector(31 downto 0);      
   signal ddata_r_periph : std_logic_vector(31 downto 0);
    
   -- Interrupt Signals
   signal interrupts : std_logic_vector(31 downto 0);
   signal gpio_interrupts : std_logic_vector(6 downto 0);   
   signal timer_interrupt : std_logic_vector(5 downto 0);

   -- Timer Signals
   -- TIMER Signals
	signal timer_reset : std_logic;
	signal timer_mode  : unsigned(1 downto 0);
	signal prescaler   : unsigned(15 downto 0);
	signal top_counter : unsigned(31 downto 0);
	signal compare_0A  : unsigned(31 downto 0);
	signal compare_1A  : unsigned(31 downto 0);
	signal compare_2A  : unsigned(31 downto 0);
	signal compare_0B  : unsigned(31 downto 0);
	signal compare_1B  : unsigned(31 downto 0);
	signal compare_2B  : unsigned(31 downto 0);
	signal output_A    : std_logic_vector(2 downto 0);
	signal output_B    : std_logic_vector(2 downto 0);
	
	-- Watchdog Signals
	signal wtd_out	: std_logic;

begin
	
	pll_inst : entity work.pll
		port map(
			areset	=> '0',
			inclk0 	=> MAX10_CLK1_50,
			c0		 	=> clk,
			c1	 		=> clk_50MHz,
			locked	=> locked_sig
		);
	
	-- Dummy out signals	
	rst <= SW(9);	
	LEDR(9) <= SW(9);	
	
	-- IMem shoud be read from instruction and data buses
	-- Not enough RAM ports for instruction bus, data bus and in-circuit programming
	instr_mux: entity work.instructionbusmux
		generic map(
			IMEMORY_WORDS => IMEMORY_WORDS,			
			DMEMORY_WORDS => DMEMORY_WORDS
		)
		port map(
			d_rd     => d_rd,
			dcsel    => dcsel,
			daddress => daddress,
			iaddress => iaddress,
			address  => address
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
		
		
		
        with to_unsigned(daddress,16)(15 downto 4) select 
        ddata_r_periph <= ddata_r_gpio when x"000",
--                          ddata_r_segments when x"001",
--                          ddata_r_uart when x"002",
--                          ddata_r_adc when x"003",
--                          ddata_r_i2c when x"004",
                          ddata_r_timer when x"005",
                          ddata_r_wtd	when x"009",
                          (others => '0')when others;
              
        
		
		
		interrupts(17 downto 0)		<= (others => '0');
		interrupts(24 downto 18)	<=gpio_interrupts(6 downto 0);
		interrupts(30 downto 25) 	<= timer_interrupt;
		interrupts(31)<='0';
		
	-- Softcore instatiation
	myRiscv : entity work.core
		generic map(
			IMEMORY_WORDS => IMEMORY_WORDS,
			DMEMORY_WORDS => DMEMORY_WORDS
		)
		port map(
			clk      => clk,
			clk_32x  => clk_50MHz,
			rst      => rst,
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
			output   => gpio_output,
			gpio_interrupts => gpio_interrupts
		);
	
	    -- timer instantiation
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
            timer_interrupt=>timer_interrupt
            
        );
	
	watchdog : entity work.watchdog
		generic map(
			prescaler_size => 16,
			WTD_BASE_ADDRESS => x"0090"
		)
		port map(
			clock    => clk,
			reset    => rst,
			daddress => daddress,
			ddata_w  => ddata_w,
			ddata_r  => ddata_r_wtd,
			d_we     => d_we,
			d_rd     => d_rd,
			dcsel    => dcsel,
			dmask    => dmask,
			wtd_out  => wtd_out
		);
	
	-- Connect gpio data to output hardware
	LEDR(7 downto 0) <= gpio_output(7 downto 0);
	
	
	-- Output register
	process(clk, rst)
	        constant SEGMETS_BASE_ADDRESS : unsigned(15 downto 0):=x"0010";
    begin
        if rst = '1' then
                -- Turn off all HEX displays
            HEX0 <= (others => '1');
            HEX1 <= (others => '1');    
            HEX2 <= (others => '1');
            HEX3 <= (others => '1');
            HEX4 <= (others => '1');
				HEX5 <= (others => '1');
        else
            if rising_edge(clk) then
                if (d_we = '1') and (dcsel = "10") then
                    -- ToDo: Simplify compartors
                    -- ToDo: Maybe use byte addressing?  
                    --       x"01" (word addressing) is x"04" (byte addressing)
                    
                    if to_unsigned(daddress, 32)(15 downto 0) =(SEGMETS_BASE_ADDRESS + x"0000") then -- TIMER_ADDRESS
                        HEX0 <= ddata_w(7 downto 0);
                    elsif to_unsigned(daddress, 32)(15 downto 0) =(SEGMETS_BASE_ADDRESS + x"0001") then -- TIMER_ADDRESS
                        HEX1 <= ddata_w(7 downto 0);
                    elsif to_unsigned(daddress, 32)(15 downto 0) =(SEGMETS_BASE_ADDRESS + x"0002") then -- TIMER_ADDRESS
                        HEX2 <= ddata_w(7 downto 0);
                    elsif to_unsigned(daddress, 32)(15 downto 0) =(SEGMETS_BASE_ADDRESS + x"0003") then -- TIMER_ADDRESS
                        HEX3 <= ddata_w(7 downto 0);
                    elsif to_unsigned(daddress, 32)(15 downto 0) =(SEGMETS_BASE_ADDRESS + x"0004") then -- TIMER_ADDRESS
                        HEX4 <= ddata_w(7 downto 0);
                    elsif to_unsigned(daddress, 32)(15 downto 0) =(SEGMETS_BASE_ADDRESS + x"0005") then -- TIMER_ADDRESS
                        HEX5 <= ddata_w(7 downto 0);
                    end if;
                end if;
            end if;
        end if;
    end process;
	



	

	-- Connect input hardware to gpio data
	gpio_input(3 downto 0) <= SW(3 downto 0);

end;

