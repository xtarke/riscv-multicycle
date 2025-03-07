library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DE2_115 is
    Port (
        -- Clock inputs
        CLOCK_50    : in  STD_LOGIC;
        CLOCK2_50   : in  STD_LOGIC;
        CLOCK3_50   : in  STD_LOGIC;
        ENETCLK_25  : in  STD_LOGIC;

        -- SMA
        SMA_CLKIN   : in  STD_LOGIC;
        SMA_CLKOUT  : out STD_LOGIC;

        -- LEDs
        LEDG        : out STD_LOGIC_VECTOR(8 downto 0);
        LEDR        : out STD_LOGIC_VECTOR(17 downto 0);

        -- Keys
        KEY         : in  STD_LOGIC_VECTOR(3 downto 0);

        -- Switches
        SW          : in  STD_LOGIC_VECTOR(17 downto 0);

        -- 7-Segment Displays
        HEX0        : out STD_LOGIC_VECTOR(6 downto 0);
        HEX1        : out STD_LOGIC_VECTOR(6 downto 0);
        HEX2        : out STD_LOGIC_VECTOR(6 downto 0);
        HEX3        : out STD_LOGIC_VECTOR(6 downto 0);
        HEX4        : out STD_LOGIC_VECTOR(6 downto 0);
        HEX5        : out STD_LOGIC_VECTOR(6 downto 0);
        HEX6        : out STD_LOGIC_VECTOR(6 downto 0);
        HEX7        : out STD_LOGIC_VECTOR(6 downto 0);

        -- LCD
        LCD_BLON    : out STD_LOGIC;
        LCD_DATA    : inout STD_LOGIC_VECTOR(7 downto 0);
        LCD_EN      : out STD_LOGIC;
        LCD_ON      : out STD_LOGIC;
        LCD_RS      : out STD_LOGIC;
        LCD_RW      : out STD_LOGIC;

        -- RS232
        UART_CTS    : in  STD_LOGIC;
        UART_RTS    : out STD_LOGIC;
        UART_RXD    : in  STD_LOGIC;
        UART_TXD    : out STD_LOGIC;

        -- PS2
        PS2_CLK     : inout STD_LOGIC;
        PS2_DAT     : inout STD_LOGIC;
        PS2_CLK2    : inout STD_LOGIC;
        PS2_DAT2    : inout STD_LOGIC;

        -- SD Card
        SD_CLK      : out STD_LOGIC;
        SD_CMD      : inout STD_LOGIC;
        SD_DAT      : inout STD_LOGIC_VECTOR(3 downto 0);
        SD_WP_N     : in  STD_LOGIC;

        -- VGA
        VGA_B       : out STD_LOGIC_VECTOR(7 downto 0);
        VGA_BLANK_N : out STD_LOGIC;
        VGA_CLK     : out STD_LOGIC;
        VGA_G       : out STD_LOGIC_VECTOR(7 downto 0);
        VGA_HS      : out STD_LOGIC;
        VGA_R       : out STD_LOGIC_VECTOR(7 downto 0);
        VGA_SYNC_N  : out STD_LOGIC;
        VGA_VS      : out STD_LOGIC;

        -- Audio
        AUD_ADCDAT  : in  STD_LOGIC;
        AUD_ADCLRCK : inout STD_LOGIC;
        AUD_BCLK    : inout STD_LOGIC;
        AUD_DACDAT  : out STD_LOGIC;
        AUD_DACLRCK : inout STD_LOGIC;
        AUD_XCK     : out STD_LOGIC;

        -- I2C for EEPROM
        EEP_I2C_SCLK : out STD_LOGIC;
        EEP_I2C_SDAT : inout STD_LOGIC;

        -- I2C for Audio and TV Decoder
        I2C_SCLK    : out STD_LOGIC;
        I2C_SDAT    : inout STD_LOGIC;

        -- Ethernet 0
        ENET0_GTX_CLK : out STD_LOGIC;
        ENET0_INT_N   : in  STD_LOGIC;
        ENET0_MDC     : out STD_LOGIC;
        ENET0_MDIO    : inout STD_LOGIC;
        ENET0_RST_N   : out STD_LOGIC;
        ENET0_RX_CLK  : in  STD_LOGIC;
        ENET0_RX_COL  : in  STD_LOGIC;
        ENET0_RX_CRS  : in  STD_LOGIC;
        ENET0_RX_DATA : in  STD_LOGIC_VECTOR(3 downto 0);
        ENET0_RX_DV   : in  STD_LOGIC;
        ENET0_RX_ER   : in  STD_LOGIC;
        ENET0_TX_CLK  : in  STD_LOGIC;
        ENET0_TX_DATA : out STD_LOGIC_VECTOR(3 downto 0);
        ENET0_TX_EN   : out STD_LOGIC;
        ENET0_TX_ER   : out STD_LOGIC;
        ENET0_LINK100 : in  STD_LOGIC;

        -- Ethernet 1
        ENET1_GTX_CLK : out STD_LOGIC;
        ENET1_INT_N   : in  STD_LOGIC;
        ENET1_MDC     : out STD_LOGIC;
        ENET1_MDIO    : inout STD_LOGIC;
        ENET1_RST_N   : out STD_LOGIC;
        ENET1_RX_CLK  : in  STD_LOGIC;
        ENET1_RX_COL  : in  STD_LOGIC;
        ENET1_RX_CRS  : in  STD_LOGIC;
        ENET1_RX_DATA : in  STD_LOGIC_VECTOR(3 downto 0);
        ENET1_RX_DV   : in  STD_LOGIC;
        ENET1_RX_ER   : in  STD_LOGIC;
        ENET1_TX_CLK  : in  STD_LOGIC;
        ENET1_TX_DATA : out STD_LOGIC_VECTOR(3 downto 0);
        ENET1_TX_EN   : out STD_LOGIC;
        ENET1_TX_ER   : out STD_LOGIC;
        ENET1_LINK100 : in  STD_LOGIC;

        -- TV Decoder
        TD_CLK27     : in  STD_LOGIC;
        TD_DATA      : in  STD_LOGIC_VECTOR(7 downto 0);
        TD_HS        : in  STD_LOGIC;
        TD_RESET_N   : out STD_LOGIC;
        TD_VS        : in  STD_LOGIC;

        -- USB OTG
        OTG_DATA     : inout STD_LOGIC_VECTOR(15 downto 0);
        OTG_ADDR     : out STD_LOGIC_VECTOR(1 downto 0);
        OTG_CS_N     : out STD_LOGIC;
        OTG_WR_N     : out STD_LOGIC;
        OTG_RD_N     : out STD_LOGIC;
        OTG_INT      : in  STD_LOGIC;
        OTG_RST_N    : out STD_LOGIC;

        -- IR Receiver
        IRDA_RXD     : in  STD_LOGIC;

        -- SDRAM
        DRAM_ADDR    : out STD_LOGIC_VECTOR(12 downto 0);
        DRAM_BA      : out STD_LOGIC_VECTOR(1 downto 0);
        DRAM_CAS_N   : out STD_LOGIC;
        DRAM_CKE     : out STD_LOGIC;
        DRAM_CLK     : out STD_LOGIC;
        DRAM_CS_N    : out STD_LOGIC;
        DRAM_DQ      : inout STD_LOGIC_VECTOR(31 downto 0);
        DRAM_DQM     : out STD_LOGIC_VECTOR(3 downto 0);
        DRAM_RAS_N   : out STD_LOGIC;
        DRAM_WE_N    : out STD_LOGIC;

        -- SRAM
        SRAM_ADDR    : out STD_LOGIC_VECTOR(19 downto 0);
        SRAM_CE_N    : out STD_LOGIC;
        SRAM_DQ      : inout STD_LOGIC_VECTOR(15 downto 0);
        SRAM_LB_N    : out STD_LOGIC;
        SRAM_OE_N    : out STD_LOGIC;
        SRAM_UB_N    : out STD_LOGIC;
        SRAM_WE_N    : out STD_LOGIC;

        -- Flash
        FL_ADDR      : out STD_LOGIC_VECTOR(22 downto 0);
        FL_CE_N      : out STD_LOGIC;
        FL_DQ        : inout STD_LOGIC_VECTOR(7 downto 0);
        FL_OE_N      : out STD_LOGIC;
        FL_RST_N     : out STD_LOGIC;
        FL_RY        : in  STD_LOGIC;
        FL_WE_N      : out STD_LOGIC;
        FL_WP_N      : out STD_LOGIC;

        -- GPIO
        GPIO         : inout STD_LOGIC_VECTOR(35 downto 0);

        -- HSMC
        HSMC_CLKIN_P1 : in  STD_LOGIC;
        HSMC_CLKIN_P2 : in  STD_LOGIC;
        HSMC_CLKIN0   : in  STD_LOGIC;
        HSMC_CLKOUT_P1 : out STD_LOGIC;
        HSMC_CLKOUT_P2 : out STD_LOGIC;
        HSMC_CLKOUT0   : out STD_LOGIC;
        HSMC_D        : inout STD_LOGIC_VECTOR(3 downto 0);
        HSMC_RX_D_P   : in  STD_LOGIC_VECTOR(16 downto 0);
        HSMC_TX_D_P   : out STD_LOGIC_VECTOR(16 downto 0);

        -- EXTEND IO
        EX_IO         : inout STD_LOGIC_VECTOR(6 downto 0)
    );
end DE2_115;

architecture Behavioral of DE2_115 is
    -- Sinais internos
    signal data_ready : STD_LOGIC;
    signal hex_data   : STD_LOGIC_VECTOR(31 downto 0);
    signal clk50      : STD_LOGIC;

    -- Componentes
    component pll1 is
        Port (
            inclk0 : in  STD_LOGIC;
            c0     : out STD_LOGIC;
            c1     : out STD_LOGIC
        );
    end component;

    component IR_RECEIVE is
        Port (
            iCLK         : in  STD_LOGIC;
            iRST_n       : in  STD_LOGIC;
            iIRDA        : in  STD_LOGIC;
            oDATA_READY  : out STD_LOGIC;
            oDATA        : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    component SEG_HEX is
        Port (
            iDIG    : in  STD_LOGIC_VECTOR(3 downto 0);
            oHEX_D  : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;

begin
    -- Configuração de portas inout
    SD_DAT      <= "111Z";
    AUD_ADCLRCK <= AUD_DACLRCK;
    GPIO        <= (others => 'Z');
    HSMC_D      <= (others => 'Z');
    EX_IO       <= (others => 'Z');

    -- Instanciação do PLL
    u0: pll1
        Port Map (
            inclk0 => CLOCK_50,
            c0     => clk50,
            c1     => open
        );

    -- Instanciação do receptor IR
    u1: IR_RECEIVE
        Port Map (
            iCLK        => clk50,
            iRST_n      => KEY(0),
            iIRDA       => IRDA_RXD,
            oDATA_READY => data_ready,
            oDATA       => hex_data
        );
		  
	 LEDG(3 downto 0) <= hex_data(31 downto 28);
	 
    -- Instanciação dos displays de 7 segmentos
    u2: SEG_HEX Port Map (hex_data(31 downto 28), HEX0);
    u3: SEG_HEX Port Map (hex_data(27 downto 24), HEX1);
    u4: SEG_HEX Port Map (hex_data(23 downto 20), HEX2);
    u5: SEG_HEX Port Map (hex_data(19 downto 16), HEX3);
    u6: SEG_HEX Port Map (hex_data(15 downto 12), HEX4);
    u7: SEG_HEX Port Map (hex_data(11 downto 8),  HEX5);
    u8: SEG_HEX Port Map (hex_data(7 downto 4),   HEX6);
    u9: SEG_HEX Port Map (hex_data(3 downto 0),   HEX7);

end Behavioral;