-------------------------------------------------------------------
-- Name        : de2_115.vhd
-- Author      : Guido Momm
-- Version     : 0.1
-- Copyright   : Departamento de Eletrônica, Florianópolis, IFSC
-- Description : Projeto base DE2-115
-------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.decoder_types.all;

entity DE2_115 is 
    generic (
        --! Num of 32-bits memory words
        IMEMORY_WORDS : integer := 1024;	--!= 4K (1024 * 4) bytes
        DMEMORY_WORDS : integer := 1024  	--!= 2k (512 * 2) bytes
    );
     port (
		  ---------- CLOCK ----------
        CLOCK_50 :  in std_logic;
        CLOCK2_50 :  in std_logic;
        CLOCK3_50 :  in std_logic;
        SMA_CLKIN :  in std_logic;
        SMA_CLKOUT :  out std_logic;
		  
		  ----------- SDRAM ------------
		  DRAM_ADDR :  out std_logic_vector( 12  downto 0  );
        DRAM_BA :  out std_logic_vector( 1  downto 0  );
        DRAM_CAS_N :  out std_logic;
        DRAM_CKE :  out std_logic;
        DRAM_CLK :  out std_logic;
        DRAM_CS_N :  out std_logic;
        DRAM_DQ :  inout std_logic_vector( 31  downto 0  );
        DRAM_DQM :  out std_logic_vector( 3  downto 0  );
        DRAM_RAS_N :  out std_logic;
        DRAM_WE_N :  out std_logic;
        SRAM_ADDR :  out std_logic_vector( 19  downto 0  );
        SRAM_CE_N :  out std_logic;
        SRAM_DQ :  inout std_logic_vector( 15  downto 0  );
        SRAM_LB_N :  out std_logic;
        SRAM_OE_N :  out std_logic;
        SRAM_UB_N :  out std_logic;
        SRAM_WE_N :  out std_logic;
		  
		  ----------- SEG7 ------------
		  HEX0 :  out std_logic_vector( 6  downto 0  );
        HEX1 :  out std_logic_vector( 6  downto 0  );
        HEX2 :  out std_logic_vector( 6  downto 0  );
        HEX3 :  out std_logic_vector( 6  downto 0  );
        HEX4 :  out std_logic_vector( 6  downto 0  );
        HEX5 :  out std_logic_vector( 6  downto 0  );
        HEX6 :  out std_logic_vector( 6  downto 0  );
        HEX7 :  out std_logic_vector( 6  downto 0  );
		  
		  ----------- KEY ------------
		  KEY :  in std_logic_vector( 3  downto 0  );
		  
		  ----------- LED ------------	  
        LEDG :  out std_logic_vector( 8  downto 0  );
        LEDR :  out std_logic_vector( 17  downto 0  );
		  
		  ----------- SW ------------
		  SW :  in std_logic_vector( 17  downto 0  );
		  
		  
        EX_IO :  inout std_logic_vector( 6  downto 0  );

        ----------- LCD ------------
        LCD_BLON :  out std_logic;
        LCD_DATA :  inout std_logic_vector( 7  downto 0  );
        LCD_EN :  out std_logic;
        LCD_ON :  out std_logic;
        LCD_RS :  out std_logic;
        LCD_RW :  out std_logic;
		  
		  ----------- UART ------------
        UART_CTS :  in std_logic;
        UART_RTS :  out std_logic;
        UART_RXD :  in std_logic;
        UART_TXD :  out std_logic;
		  
		  
        PS2_CLK :  inout std_logic;
        PS2_CLK2 :  inout std_logic;
        PS2_DAT :  inout std_logic;
        PS2_DAT2 :  inout std_logic;
		  
		  ----------- SD ------------
        SD_CLK :  out std_logic;
        SD_CMD :  inout std_logic;
        SD_DAT :  inout std_logic_vector( 3  downto 0  );
        SD_WP_N :  in std_logic;
		  
		  ----------- VGA ------------
        VGA_B :  out std_logic_vector( 7  downto 0  );
        VGA_BLANK_N :  out std_logic;
        VGA_CLK :  out std_logic;
        VGA_G :  out std_logic_vector( 7  downto 0  );
        VGA_HS :  out std_logic;
        VGA_R :  out std_logic_vector( 7  downto 0  );
        VGA_SYNC_N :  out std_logic;
        VGA_VS :  out std_logic;
		  
		  
        AUD_ADCDAT :  in std_logic;
        AUD_ADCLRCK :  inout std_logic;
        AUD_BCLK :  inout std_logic;
        AUD_DACDAT :  out std_logic;
        AUD_DACLRCK :  inout std_logic;
        AUD_XCK :  out std_logic;
		  
		  
        EEP_I2C_SCLK :  out std_logic;
        EEP_I2C_SDAT :  inout std_logic;
		  
		  ----------- I2C ------------
        I2C_SCLK :  out std_logic;
        I2C_SDAT :  inout std_logic;
		  
		  
        ENET0_GTX_CLK :  out std_logic;
        ENET0_INT_N :  in std_logic;
        ENET0_LINK100 :  in std_logic;
        ENET0_MDC :  out std_logic;
        ENET0_MDIO :  inout std_logic;
        ENET0_RST_N :  out std_logic;
        ENET0_RX_CLK :  in std_logic;
        ENET0_RX_COL :  in std_logic;
        ENET0_RX_CRS :  in std_logic;
        ENET0_RX_DATA :  in std_logic_vector( 3  downto 0  );
        ENET0_RX_DV :  in std_logic;
        ENET0_RX_ER :  in std_logic;
        ENET0_TX_CLK :  in std_logic;
        ENET0_TX_DATA :  out std_logic_vector( 3  downto 0  );
        ENET0_TX_EN :  out std_logic;
        ENET0_TX_ER :  out std_logic;
        ENETCLK_25 :  in std_logic;
        ENET1_GTX_CLK :  out std_logic;
        ENET1_INT_N :  in std_logic;
        ENET1_LINK100 :  in std_logic;
        ENET1_MDC :  out std_logic;
        ENET1_MDIO :  inout std_logic;
        ENET1_RST_N :  out std_logic;
        ENET1_RX_CLK :  in std_logic;
        ENET1_RX_COL :  in std_logic;
        ENET1_RX_CRS :  in std_logic;
        ENET1_RX_DATA :  in std_logic_vector( 3  downto 0  );
        ENET1_RX_DV :  in std_logic;
        ENET1_RX_ER :  in std_logic;
        ENET1_TX_CLK :  in std_logic;
        ENET1_TX_DATA :  out std_logic_vector( 3  downto 0  );
        ENET1_TX_EN :  out std_logic;
        ENET1_TX_ER :  out std_logic;
		  
		  
        TD_CLK27 :  in std_logic;
        TD_DATA :  in std_logic_vector( 7  downto 0  );
        TD_HS :  in std_logic;
        TD_RESET_N :  out std_logic;
        TD_VS :  in std_logic;
		  
		  
        OTG_ADDR :  out std_logic_vector( 1  downto 0  );
        OTG_CS_N :  out std_logic;
        OTG_DATA :  inout std_logic_vector( 15  downto 0  );
        OTG_INT :  in std_logic;
        OTG_RD_N :  out std_logic;
        OTG_RST_N :  out std_logic;
        OTG_WE_N :  out std_logic;

        IRDA_RXD :  in std_logic;
       
        FL_ADDR :  out std_logic_vector( 22  downto 0  );
        FL_CE_N :  out std_logic;
        FL_DQ :  inout std_logic_vector( 7  downto 0  );
        FL_OE_N :  out std_logic;
        FL_RST_N :  out std_logic;
        FL_RY :  in std_logic;
        FL_WE_N :  out std_logic;
        FL_WP_N :  out std_logic
    );
end entity; 


architecture rtl of DE2_115 is 
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
    signal ddata_r_spwm : std_logic_vector(31 downto 0);
    signal ddata_r_crc : std_logic_vector(31 downto 0);
    signal ddata_r_key : std_logic_vector(31 downto 0);
    signal ddata_r_accelerometer : std_logic_vector(31 downto 0);
	 signal ddata_r_irda : std_logic_vector(31 downto 0);

    -- Interrupt Signals
    signal interrupts : std_logic_vector(31 downto 0);
    signal gpio_interrupts : std_logic_vector(6 downto 0);
    signal timer_interrupt : std_logic_vector(5 downto 0);

    -- I/O signals
    signal input_in : std_logic_vector(31 downto 0);

    signal ifcap :  std_logic;      -- capture flag

    -- IRDA signals
    signal irda_data : std_logic_vector(31 downto 0);
	 signal irda_debug : std_logic_vector(31 downto 0);
	 
	 
	 signal data_ready: std_logic;
begin

    -- Reset
    rst <= SW(9);
    LEDR(9) <= SW(9);

    -- Clocks
    pll_inst : entity work.pll
        port map(
            areset	=> '0',
            inclk0 	=> CLOCK_50,
            c0		 	=> clk,
            c1	 		=> clk_50MHz
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
            d_sig	 	=> d_sig,
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
            ddata_r_nn_accelerator => ddata_r_nn_accelerator,
            ddata_r_spwm  		=> ddata_r_spwm,
            ddata_r_crc			=> ddata_r_crc,
            ddata_r_key       => ddata_r_key,
            ddata_r_accelerometer     => ddata_r_accelerometer,
            ddata_r_irda => ddata_r_irda
        );

--	  irda_bus: entity work.irda_bus	    
--        port map(
--            clk      => clk,
--            clk_50 => clk_50MHz,
--            rst      => rst,
--            daddress => daddress,
--            ddata_w  => ddata_w,
--            ddata_r  => ddata_r_irda,
--            d_we     => d_we,
--            d_rd     => d_rd,
--            dcsel    => dcsel,
--            dmask    => dmask,
--            irda_sensor => IRDA_RXD,
--				irda_debug => irda_debug
--        );

    -- Timer instantiation
    timer : entity work.Timer
        generic map(
            PRESCALER_SIZE => 16,
            COMPARE_SIZE   => 32
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
            timer_interrupt => timer_interrupt,
            ifcap => ifcap
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
            hex0(6 downto 0)     => HEX0,
            hex1(6 downto 0)     => HEX1,
            hex2(6 downto 0)     => HEX2,
            hex3(6 downto 0)     => HEX3,
            hex4(6 downto 0)     => HEX4,
            hex5(6 downto 0)     => HEX5,
            hex6(6 downto 0)     => open,
            hex7(6 downto 0)     => open
        );

    -- Connect input hardware to gpio data
    gpio_input(3 downto 0) <= SW(3 downto 0);
   -- LEDR(7 downto 0) <= gpio_output(7 downto 0);
	 LEDG(3 downto 0) <= irda_debug(31 downto 28);
	 
	 
	     u1: work.irda
        Port Map (
            iCLK        => CLOCK_50,
            iRST_n      => KEY(0),
            iIRDA       => IRDA_RXD,
            oDATA_READY => data_ready,
            oDATA       => irda_debug
        );
end;


