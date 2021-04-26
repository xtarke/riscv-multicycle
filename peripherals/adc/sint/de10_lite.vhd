-------------------------------------------------------------------
-- Name        : de0_lite.vhd
-- Author      : Renan Augusto Starke
-- Modified    : Jeferson Pedroso, Leticia de Oliveira Nunes, Marieli Matos
-- Version     : 0.2
-- Copyright   : Departamento de Eletronica, Florianopolis, IFSC
-- Description : riscV ADC example
-------------------------------------------------------------------
LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.decoder_types.all;

entity de10_lite is
    generic (
        --! Num of 32-bits memory words 
        IMEMORY_WORDS : integer := 1024;    --!= 4K (1024 * 4) bytes
        DMEMORY_WORDS : integer := 1024     --!= 2k (512 * 2) bytes
    );
    port (
        ---------- CLOCK ----------
        ADC_CLK_10: in std_logic;
        MAX10_CLK1_50: in std_logic;
        MAX10_CLK2_50: in std_logic;

        ----------- SDRAM ------------
        DRAM_ADDR   : out std_logic_vector (12 downto 0);
        DRAM_BA     : out std_logic_vector (1 downto 0);
        DRAM_CAS_N  : out std_logic;
        DRAM_CKE    : out std_logic;
        DRAM_CLK    : out std_logic;
        DRAM_CS_N   : out std_logic;
        DRAM_DQ     : inout std_logic_vector(15 downto 0);
        DRAM_LDQM   : out std_logic;
        DRAM_RAS_N  : out std_logic;
        DRAM_UDQM   : out std_logic;
        DRAM_WE_N   : out std_logic;

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
        VGA_B   : out std_logic_vector(3 downto 0);
        VGA_G   : out std_logic_vector(3 downto 0);
        VGA_HS  : out std_logic;
        VGA_R   : out std_logic_vector(3 downto 0);
        VGA_VS  : out std_logic;

        ----------- Accelerometer ------------
        GSENSOR_CS_N    : out std_logic;
        GSENSOR_INT     : in std_logic_vector(2 downto 1);
        GSENSOR_SCLK    : out std_logic;
        GSENSOR_SDI     : inout std_logic;
        GSENSOR_SDO     : inout std_logic;

        ----------- Arduino ------------
        ARDUINO_IO      : inout std_logic_vector(15 downto 0);
        ARDUINO_RESET_N : inout std_logic
    );
end entity;

architecture RTL of de10_lite is
    --  -- Display variables
    --  type displays_type is array (0 to 5) of std_logic_vector(3 downto 0);
    --  type displays_out_type is array (0 to 5) of std_logic_vector(7 downto 0);
    --  signal displays     : displays_type;
    --  signal displays_out : displays_out_type;

    signal clk : std_logic;
    signal rst : std_logic;

    -- Instruction bus signals
    signal idata     : std_logic_vector(31 downto 0);
    signal iaddress  : integer range 0 to IMEMORY_WORDS-1 := 0;
    signal address   : std_logic_vector (9 downto 0);

    -- Data bus signals
    signal daddress :  integer range 0 to DMEMORY_WORDS-1;
    signal ddata_r  :   std_logic_vector(31 downto 0);
    signal ddata_w  :   std_logic_vector(31 downto 0);
    signal dmask    : std_logic_vector(3 downto 0);
    signal dcsel    : std_logic_vector(1 downto 0);
    signal d_we     : std_logic := '0';

    signal ddata_r_mem : std_logic_vector(31 downto 0);
    signal d_rd : std_logic;

    -- SDRAM signals
    signal ddata_r_sdram : std_logic_vector(31 downto 0);
    
    -- PLL signals
    signal locked_sig : std_logic;

    -- CPU state signals
    signal state : cpu_state_t;
    signal d_sig : std_logic;
    
    -- interrupt Signals
    signal interrupts       : std_logic_vector(31 downto 0);
    signal gpio_interrupts  : std_logic_vector(6 downto 0);
    
    --ADC
    signal ddata_r_adc      : std_logic_vector(31 downto 0);
    signal ddata_r_periph   : std_logic_vector(31 downto 0);
    signal debug_adc        :std_logic_vector(11 downto 0);
    
    --GPIO
    signal ddata_r_gpio     : std_logic_vector(31 downto 0);
    signal reset            : std_logic;
    signal reset_n          : std_logic;
    signal disp7_output     :  std_logic_vector(7 downto 0);
    signal gpio_input       : std_logic_vector(31 downto 0);
    signal gpio_output      : std_logic_vector(31 downto 0);
        
    -- 7 segments display
    type displays_type      is array (0 to 5) of std_logic_vector(3 downto 0);
    type displays_out_type  is array (0 to 5) of std_logic_vector(7 downto 0);

    signal displays         : displays_type;
    signal displays_out     : displays_out_type;   
	 
	 signal clk_50MHz     : std_logic;   

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
            rst         => rst,
            clk         => clk,
            data        => ddata_w,
            address     => daddress,
            we          => d_we,
            csel        => dcsel(0),
            dmask       => dmask,
            signal_ext  => d_sig,
            q           => ddata_r_mem
        );

    -- Adress space mux ((check sections.ld) -> Data chip select:
    -- 0x00000    ->    Instruction memory
    -- 0x20000    ->    Data memory
    -- 0x40000    ->    Input/Output generic address space
    -- ( ... )    ->    ( ... )
    datamux: entity work.databusmux
        port map(
            dcsel           => dcsel,
            idata           => idata,
            ddata_r_mem     => ddata_r_mem,
            ddata_r_periph  => ddata_r_periph,
            ddata_r_sdram   => ddata_r_sdram,
            ddata_r         => ddata_r
        );
    with to_unsigned(daddress,16)(15 downto 4) select
 ddata_r_periph <= ddata_r_gpio when x"000",
        ddata_r_adc when x"003",
        --ddata_r_segments when x"001",
        -- ddata_r_gpio when x"000",
        -- ddata_r_segments when x"001",
        -- ddata_r_uart when x"002",
        -- ddata_r_adc when x"003",
        -- ddata_r_i2c when x"004",
        -- ddata_r_timer when x"005",
        (others => '0')when others;
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
            d_sig    => d_sig,
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

    adc_core: entity work.adc_core
        generic map(
            MY_CHIPSELECT   => "10",
            MY_WORD_ADDRESS => x"10"
        )
        port map(
            clk         => MAX10_CLK1_50,
            rst         => rst,
            clk_adc     => ADC_CLK_10,
            daddress    => daddress,
            ddata_w     => ddata_w,
            ddata_r     => ddata_r_adc,
            d_we        => d_we,
            d_rd        => d_rd,
            dcsel       => dcsel,
            dmask       => dmask,
            debug_adc   => debug_adc
        );

    hex_gen : for i in 0 to 5 generate
        hex_dec : entity work.display_dec
            port map(
                data_in => displays(i),
                disp    => displays_out(i)
            );
    end generate;
    
    HEX0 <= displays_out(0);
    HEX1 <= displays_out(1);
    HEX2 <= displays_out(2);
    HEX3 <= displays_out(3);
    HEX4 <= displays_out(4);
    HEX5 <= displays_out(5);

    process(clk, rst)               
    begin
        if (rising_edge(clk)) then
            LEDR(8 downto 0) <= ddata_w(8 downto 0);
        end if;
    end process;

    process(clk, rst)
    begin
        if rst = '1' then
            displays(0) <= "0000";
            displays(1) <= "0000";
            displays(2) <= "0000";
            displays(3) <= "0000";
            displays(4) <= "0000";
            displays(5) <= "0000";
        else
            if (rising_edge(clk)) then
                displays(0) <= gpio_output(3 downto 0);
                displays(1) <= gpio_output(7 downto 4);
                displays(2) <= gpio_output(11 downto 8);
                displays(3) <= gpio_output(15 downto 12);
                displays(4) <= gpio_output(19 downto 16);
                displays(5) <= gpio_output(23 downto 20);

            end if;
        end if;
    end process;

end architecture RTL;

