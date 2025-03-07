-------------------------------------------------------------------
-- Name        : de0_lite.vhd
-- Author      : Jonathan Chrysostomo Caral Bonette & Matheus Rodrigues da Cunha
-- Copyright   : Departamento de Eletrônica, Florianópolis, IFSC
-- Description : Implementação de um sistema de detecção de presença baseado em um sensor infravermelho TSSP580
-------------------------------------------------------------------
LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;

entity de10_lite is 
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

	----------------------------------------------------------------
	-- Sinais para o PLL e para o módulo led_tx
	----------------------------------------------------------------
	signal clk_1MHz   : std_logic;  -- Clock de 1 MHz gerado pelo PLL
	signal pll_locked : std_logic;  -- Sinal "locked" do PLL
	signal rst_sync   : std_logic;  -- Reset sincronizado (ativo em '1')
	signal led_tx_out : std_logic;  -- Saída do módulo led_tx

	----------------------------------------------------------------
	-- Declaração do componente led_tx
	----------------------------------------------------------------
	component led_tx is
    generic(
      MOD_PERIOD     : natural := 1000000; -- Período total do modulador (1s com clk de 1MHz)
      MOD_ON_TIME    : natural := 500000;  -- Tempo ativo do burst (500 ms)
      IR_HALF_PERIOD : natural := 13       -- Para gerar aproximadamente 38 kHz (13+13 = 26 ciclos)
    );
    port(
      clk     : in std_logic;
      rst     : in std_logic;
      led_out : out std_logic
    );
	end component;

	----------------------------------------------------------------
	-- Declaração do componente PLL
	----------------------------------------------------------------
	component pll is
    port(
      areset  : in  std_logic := '0';
      inclk0  : in  std_logic := '0';
      c0      : out std_logic;
      locked  : out std_logic
    );
	end component;

begin
	
	----------------------------------------------------------------
	-- Geração do Reset
	----------------------------------------------------------------
	rst_sync <= not KEY(0);

	----------------------------------------------------------------
	-- Instância do PLL para gerar 1 MHz a partir do pino do clock MAX10_CLK1_50 (50 MHz)
	----------------------------------------------------------------
	pll_inst: pll
    port map (
      areset => '0',               	-- Reset do PLL desativado
      inclk0 => MAX10_CLK1_50,      -- Clock de entrada (50 MHz)
      c0     => clk_1MHz,           -- Clock de saída configurado para 1 MHz
      locked => pll_locked
	);

	----------------------------------------------------------------
	-- Instância do módulo led_tx com o clock de 1 MHz
	----------------------------------------------------------------
	led_tx_inst: led_tx
    generic map(
      MOD_PERIOD     => 1000000, 	-- 1s (1.000.000 ciclos com clk de 1MHz)
      MOD_ON_TIME    => 500000,  	-- 500 ms ativos
      IR_HALF_PERIOD => 13       	-- para gerar aproximadamente 38 kHz
	)
    port map(
      clk     => clk_1MHz,
      rst     => rst_sync,
      led_out => led_tx_out
	);

	----------------------------------------------------------------
	-- Conexão do led_tx_out ao pino ARDUINO_IO(3)
	----------------------------------------------------------------
	ARDUINO_IO(3) <= led_tx_out;		-- Pino a ser usado pelo osciloscópio
	
	-- Para o resto dos pinos
	ARDUINO_IO(15 downto 4) <= (others => 'Z');
	ARDUINO_IO(2 downto 0) <= (others => 'Z');
	 
	----------------------------------------------------------------
	-- Conexão do sinal led_tx_out em um LED para monitor o comportamento do burst
	----------------------------------------------------------------
	LEDR(0) <= led_tx_out;				-- Led que será usado (teste)
	LEDR(9 downto 1) <= (others => '0');

end;
