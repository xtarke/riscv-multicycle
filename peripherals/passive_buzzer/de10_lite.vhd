-------------------------------------------------------------------
-- Name        : de10_lite.vhd
-- Author      : Sarah Bararua
-- Description : Seletor de Músicas
-- Pinagem     : Buzzer no ARDUINO_IO(8) (PIN_AB17)
-------------------------------------------------------------------
LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;

entity de10_lite is 
    port (
        ---------- CLOCK ----------
        ADC_CLK_10    : in std_logic;
        MAX10_CLK1_50 : in std_logic;
        MAX10_CLK2_50 : in std_logic;
        
        ----------- SDRAM ------------
        DRAM_ADDR  : out std_logic_vector (12 downto 0);
        DRAM_BA    : out std_logic_vector (1 downto 0);
        DRAM_CAS_N : out std_logic;
        DRAM_CKE   : out std_logic;
        DRAM_CLK   : out std_logic;
        DRAM_CS_N  : out std_logic;        
        DRAM_DQ    : inout std_logic_vector(15 downto 0);
        DRAM_LDQM  : out std_logic;
        DRAM_RAS_N : out std_logic;
        DRAM_UDQM  : out std_logic;
        DRAM_WE_N  : out std_logic;
        
        ----------- SEG7 ------------
        HEX0 : out std_logic_vector(7 downto 0);
        HEX1 : out std_logic_vector(7 downto 0);
        HEX2 : out std_logic_vector(7 downto 0);
        HEX3 : out std_logic_vector(7 downto 0);
        HEX4 : out std_logic_vector(7 downto 0);
        HEX5 : out std_logic_vector(7 downto 0);

        ----------- KEY ------------
        KEY : in std_logic_vector(1 downto 0);

        ----------- LED ------------
        LEDR : out std_logic_vector(9 downto 0);

        ----------- SW ------------
        SW : in std_logic_vector(9 downto 0);

        ----------- VGA ------------
        VGA_B  : out std_logic_vector(3 downto 0);
        VGA_G  : out std_logic_vector(3 downto 0);
        VGA_HS : out std_logic;
        VGA_R  : out std_logic_vector(3 downto 0);
        VGA_VS : out std_logic;
    
        ----------- Accelerometer ------------
        GSENSOR_CS_N : out std_logic;
        GSENSOR_INT  : in std_logic_vector(2 downto 1);
        GSENSOR_SCLK : out std_logic;
        GSENSOR_SDI  : inout std_logic;
        GSENSOR_SDO  : inout std_logic;
    
        ----------- Arduino ------------
        ARDUINO_IO      : inout std_logic_vector(15 downto 0);
        ARDUINO_RESET_N : inout std_logic
    );
end entity de10_lite;

architecture rtl of de10_lite is

    component buzzer is
        generic ( CLK_FREQ : integer := 50_000_000 );
        port (
            clk         : in  std_logic;
            sw_imperial : in  std_logic;
            sw_jingle   : in  std_logic;
            wave_out    : out std_logic
        );
    end component;

    signal som_interno : std_logic;
    signal sistema_ativo : std_logic;

begin

    -------------------------------------------------------------------------
    -- 1. INSTÂNCIA DO MODULO
    -------------------------------------------------------------------------
    u1_buzzer : buzzer
        generic map ( CLK_FREQ => 50_000_000 )
        port map (
            clk         => MAX10_CLK1_50,
            sw_imperial => SW(0),       -- Chave 0 toca Imperial
            sw_jingle   => SW(1),       -- Chave 1 toca Jingle Bells
            wave_out    => som_interno
        );

    -- Sinal auxiliar para saber se alguma chave está ligada
    sistema_ativo <= SW(0) or SW(1);

    -------------------------------------------------------------------------
    -- 2. SAÍDA DE AUDIO (Active Low)
    -------------------------------------------------------------------------
    -- Se alguma chave ligada, passa o som. Se não, trava em '1' (3.3V)
    ARDUINO_IO(8) <= som_interno when (sistema_ativo = '1') else '1';
    
    -- Alta impedância nos outros pinos
    ARDUINO_IO(7 downto 0)  <= (others => 'Z');
    ARDUINO_IO(15 downto 9) <= (others => 'Z');

    -------------------------------------------------------------------------
    -- 3. LEDS DE DEBUG
    -------------------------------------------------------------------------
    LEDR(0) <= SW(0); -- Indica Imperial selecionada
    LEDR(1) <= SW(1); -- Indica Jingle selecionada
    LEDR(2) <= som_interno when (sistema_ativo = '1') else '0';

    -- Limpa resto
    LEDR(9 downto 3) <= (others => '0');
    
    -- Limpa outros periféricos
    HEX0 <= (others => '1'); HEX1 <= (others => '1'); 
    HEX2 <= (others => '1'); HEX3 <= (others => '1');
    HEX4 <= (others => '1'); HEX5 <= (others => '1');
    DRAM_ADDR <= (others => '0'); DRAM_BA <= (others => '0');
    DRAM_CAS_N <= '1'; DRAM_CKE <= '0'; DRAM_CLK <= '0'; DRAM_CS_N <= '1';
    DRAM_LDQM <= '0'; DRAM_RAS_N <= '1'; DRAM_UDQM <= '0'; DRAM_WE_N <= '1';
    VGA_B <= (others => '0'); VGA_G <= (others => '0'); VGA_R <= (others => '0');
    VGA_HS <= '0'; VGA_VS <= '0';
    GSENSOR_CS_N <= '1'; GSENSOR_SCLK <= '0';


end architecture rtl;
