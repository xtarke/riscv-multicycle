-------------------------------------------------------------------
-- Name        : de0_lite.vhd
-- Author      : 
-- Version     : 0.3 (Com Mux SW/Probe)
-- Copyright   : Departamento de Eletrônica, Florianópolis, IFSC
-- Description : Top Level DE10-Lite com Seleção de Fonte
-------------------------------------------------------------------
LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity de10_lite is 
    port (
        ---------- CLOCK ----------
        ADC_CLK_10: in std_logic;
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
            
    -- Sinais internos para conectar os displays (7 bits)
    signal s_hex0 : std_logic_vector(6 downto 0);
    signal s_hex1 : std_logic_vector(6 downto 0);
    signal s_hex2 : std_logic_vector(6 downto 0);
    signal s_hex3 : std_logic_vector(6 downto 0);
    
    -- Sinais de Controle
    signal s_comando_chaves : unsigned(19 downto 0); -- Valor vindo das SW
    signal s_comando_probe  : unsigned(19 downto 0); -- Valor vindo do PC (ISSP)
    signal s_comando_final  : unsigned(19 downto 0); -- Valor escolhido pelo MUX
    signal s_pwm            : std_logic;
    
    -- Sinais auxiliares para o Probe (std_logic_vector para conversão)
    signal s_probe_in_slv   : std_logic_vector(19 downto 0);

    -- COMPONENTE IP DO PROBE
    -- Se o seu IP tiver outro nome, altere aqui.
    component issp_probe is
        port (
            source : out std_logic_vector(19 downto 0); -- Saída do PC para o FPGA
            probe  : in  std_logic_vector(19 downto 0)  -- Entrada do FPGA para o PC (opcional)
        );
    end component;

begin

    -- ====================================================================
    -- 1. IP CORE: IN-SYSTEM SOURCES AND PROBES (ISSP)
    -- ====================================================================
    -- Largura: 20 bits
    u_probe : component issp_probe
        port map (
            source => s_probe_in_slv, -- O valor digitado no computador entra aqui
            probe  => std_logic_vector(s_comando_final) -- Opcional: Para ler de volta o que está sendo usado
        );
    
    -- Converte o vetor do probe para unsigned para usar na lógica
    s_comando_probe <= unsigned(s_probe_in_slv);

    -- ====================================================================
    -- 2. LÓGICA DAS CHAVES (SW1, SW2, SW3)
    -- ====================================================================
    process(SW)
    begin
        -- Prioridade: SW3 > SW2 > SW1
        if SW(3) = '1' then
            s_comando_chaves <= to_unsigned(2000, 20); -- Máximo
        elsif SW(2) = '1' then
            s_comando_chaves <= to_unsigned(1500, 20); -- Médio
        elsif SW(1) = '1' then
            s_comando_chaves <= to_unsigned(1000, 20); -- Mínimo
        else
            s_comando_chaves <= to_unsigned(0000, 20); -- Padrão 
        end if;
    end process;

    -- ====================================================================
    -- 3. MULTIPLEXADOR (Seleciona Fonte: Chaves ou Probe)
    -- ====================================================================
    -- Se SW(0) = '1', usa valor das chaves.
    -- Se SW(0) = '0', usa valor do Probe.
    s_comando_final <= s_comando_chaves when SW(0) = '1' else s_comando_probe;

    -- ====================================================================
    -- 4. INSTÂNCIA DO ONESHOT125
    -- ====================================================================
    u0 : entity work.oneshot125
         port map(
             clk           => MAX10_CLK1_50, 
		       rst           => SW(9),		 
             comando       => s_comando_final,  -- Entrada selecionada
             pwm_saida     => s_pwm,            
             valor_display => open,             
             HEX0          => s_hex0,           
             HEX1          => s_hex1,
             HEX2          => s_hex2,
             HEX3          => s_hex3
         );
    
    -- ====================================================================
    -- 5. SAÍDAS FÍSICAS
    -- ====================================================================
    
    -- Displays (Acendendo o ponto decimal com '1' & sinal)
    HEX0 <= '1' & s_hex0; 
    HEX1 <= '1' & s_hex1; 
    HEX2 <= '1' & s_hex2; 
    HEX3 <= '1' & s_hex3; 

    -- Apaga Displays Extras
    HEX4 <= (others => '1');
    HEX5 <= (others => '1');
    
    -- PWM no LED e Arduino IO
    LEDR(0)       <= s_pwm;
    ARDUINO_IO(5) <= s_pwm;
    
    -- Debug visual: Acende LEDR1 se estiver no modo CHAVES, Apaga se estiver no modo PROBE
    LEDR(1) <= SW(0);
    LEDR(9) <= SW(9);
    -- Apaga restante
    LEDR(8 downto 2) <= (others => '0');
    
end;