-------------------------------------------------------------------
-- Name        : de_10_lite.vhd
-- Author      : Elvis Fernandes
-- Version     : 0.1
-- Copyright   : Departamento de Eletrônica, Florianópolis, IFSC
-- Description : Projeto Final: síntese semáforo
-- Date        : 03/09/2024
-------------------------------------------------------------------

LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Importando o pacote de conversão BCD para 7 segmentos
USE work.bcd_to_7seg_pkg.all;

ENTITY de10_lite IS 
    PORT (
        ---------- CLOCK ----------
        ADC_CLK_10:        IN std_logic;
        MAX10_CLK1_50:     IN std_logic;
        MAX10_CLK2_50:     IN std_logic;
        
        ----------- SDRAM ------------
        DRAM_ADDR:         OUT std_logic_vector(12 downto 0);
        DRAM_BA:           OUT std_logic_vector(1 downto 0);
        DRAM_CAS_N:        OUT std_logic;
        DRAM_CKE:          OUT std_logic;
        DRAM_CLK:          OUT std_logic;
        DRAM_CS_N:         OUT std_logic;
        DRAM_DQ:           INOUT std_logic_vector(15 downto 0);
        DRAM_LDQM:         OUT std_logic;
        DRAM_RAS_N:        OUT std_logic;
        DRAM_UDQM:         OUT std_logic;
        DRAM_WE_N:         OUT std_logic;
        
        ----------- SEG7 ------------
        HEX0:              OUT std_logic_vector(7 downto 0);
        HEX1:              OUT std_logic_vector(7 downto 0);
        HEX2:              OUT std_logic_vector(7 downto 0);
        HEX3:              OUT std_logic_vector(7 downto 0);
        HEX4:              OUT std_logic_vector(7 downto 0);
        HEX5:              OUT std_logic_vector(7 downto 0);

        ----------- KEY ------------
        KEY:               IN std_logic_vector(1 downto 0);

        ----------- LED ------------
        LEDR:              OUT std_logic_vector(9 downto 0);

        ----------- SW ------------
        SW:                IN std_logic_vector(9 downto 0);

        ----------- VGA ------------
        VGA_B:             OUT std_logic_vector(3 downto 0);
        VGA_G:             OUT std_logic_vector(3 downto 0);
        VGA_HS:            OUT std_logic;
        VGA_R:             OUT std_logic_vector(3 downto 0);
        VGA_VS:            OUT std_logic;
    
        ----------- Accelerometer ------------
        GSENSOR_CS_N:      OUT std_logic;
        GSENSOR_INT:       IN std_logic_vector(2 downto 1);
        GSENSOR_SCLK:      OUT std_logic;
        GSENSOR_SDI:       INOUT std_logic;
        GSENSOR_SDO:       INOUT std_logic;
    
        ----------- Arduino ------------
        ARDUINO_IO:        INOUT std_logic_vector(15 downto 0);
        ARDUINO_RESET_N:   INOUT std_logic
    );
END ENTITY;

ARCHITECTURE rtl OF de10_lite IS

    -- Sinais para o semáforo e contadores
    SIGNAL clk               : std_logic;                  -- Sinal de clock
    SIGNAL rst               : std_logic;                  -- Sinal de reset
    SIGNAL start             : std_logic;                  -- Sinal para a chave de start
    SIGNAL pedestre          : std_logic;                  -- Sinal para a chave para contagem de pedestres
    SIGNAL carro             : std_logic;                  -- Sinal para a chave para contagem de carros
    SIGNAL r1               : std_logic;                  -- Sinal de saída para o vermelho do primeiro semáforo
    SIGNAL y1               : std_logic;                  -- Sinal de saída para o amarelo do primeiro semáforo
    SIGNAL g1               : std_logic;                  -- Sinal de saída para o verde do primeiro semáforo
    SIGNAL ped_count        : unsigned(7 DOWNTO 0);      -- Sinal de contador de pedestres 
    SIGNAL car_count        : unsigned(7 DOWNTO 0);      -- Sinal de contador de carros
    SIGNAL time_display     : unsigned(7 DOWNTO 0);      -- Sinal de contador de tempo de estados do semáforo
    
    SIGNAL clk_div          : std_logic := '0';
    
    -- Sinais para os displays de 7 segmentos
    SIGNAL hex0_data        : std_logic_vector(7 downto 0);
    SIGNAL hex1_data        : std_logic_vector(7 downto 0);
    SIGNAL hex2_data        : std_logic_vector(7 downto 0);
    SIGNAL visual_display   : unsigned(7 DOWNTO 0);      -- Sinal para visualizar os segundos finais de tempo de cada estado
    SIGNAL hex5_data        : std_logic_vector(7 downto 0);
    SIGNAL visual_display_test : unsigned(7 downto 0);  -- Inicializa o teste com 0

BEGIN

    -- Divisor de Clock para gerar um sinal de clock mais lento
    PROCESS(MAX10_CLK1_50)
        VARIABLE counter : integer := 0;
    BEGIN
        IF rising_edge(MAX10_CLK1_50) THEN
            counter := counter + 1;
            IF counter = 50000000 THEN 
                clk_div <= NOT clk_div;
                counter := 0;
            END IF;
        END IF;
    END PROCESS;

    -- Instância do DUT (Design Under Test)
    dut : ENTITY work.semaforo
        PORT MAP (
            clk          => clk_div,
            rst          => SW(1),
            start        => SW(0),
            pedestre     => SW(9),
            carro        => SW(8),
            r1           => LEDR(2),
            y1           => LEDR(1),
            g1           => LEDR(0),
            ped_count    => ped_count,
            car_count    => car_count,
            time_display => time_display,
            visual_display => visual_display
        );

    -- Convertendo os valores de contagem para displays de 7 segmentos
    PROCESS(ped_count, car_count, time_display, visual_display)
    BEGIN
        -- Display HEX0 mostra ped_count
        hex0_data <= convert_8bits_to_dual_7seg(std_logic_vector(ped_count))(7 downto 0);

        -- Display HEX1 mostra car_count
        hex1_data <= convert_8bits_to_dual_7seg(std_logic_vector(car_count))(7 downto 0);

        -- Display HEX2 mostra a contagem de tempo de cada estado do semáforo
        hex2_data <= convert_8bits_to_dual_7seg(std_logic_vector(time_display))(7 downto 0);

        -- Display HEX5 mostra visual_display
        hex5_data <= convert_8bits_to_dual_7seg(std_logic_vector(visual_display))(7 downto 0);
    END PROCESS;

    -- Atribuindo os valores convertidos aos displays
    HEX0 <= hex0_data;
    HEX1 <= hex1_data;
    HEX2 <= hex2_data;
    HEX3 <= "11111111";  -- (dp,g,f,e,d,c,b,a) apagados
    --HEX4 <= "11111111";  -- (dp,g,f,e,d,c,b,a) apagados
    --HEX5 <= "10000000"; -- (dp) apagado
    --HEX5 <= "11000000"; -- (dp,g) apagados
    --HEX5 <= "11100000"; -- (dp,g,f) apagados
    --HEX5 <= "11110000"; -- (dp,g,f,e) apagados
    --HEX5 <= "11111000"; -- (dp,g,f,e,d) apagados
    --HEX5 <= "11111100"; -- (dp,g,f,e,d,c) apagados
    --HEX5 <= "11111110"; -- (dp,g,f,e,d,c,b) apagados
    --HEX5 <= "11111111"; -- (dp,g,f,e,d,c,b,a) apagados
	
	--Sincronizando o valor de time_display a visual_display_test a cada subida de clock
    PROCESS(clk_div)
    BEGIN
        IF rising_edge(clk_div) THEN
            visual_display_test <= time_display;
        END IF;
    END PROCESS;

    -- Processo para controlar o displays HEX4 e HEX5 com base no valor de visual_display_test
    PROCESS(visual_display_test)
    BEGIN
        CASE to_integer(unsigned(visual_display_test)) IS
				
				WHEN 16 =>
                HEX4 <= "00000000"; -- Todos segmentos acesos (para um visual "15")
				WHEN 15 =>
                HEX4 <= "10000000"; -- Todos segmentos acesos (para um visual "15")
				WHEN 14 =>
                HEX4 <= "11000000"; -- (dp,g) apagados (para um visual "14")
				WHEN 13 =>
                HEX4 <= "11100000"; -- (dp,g,f) apagados (para um visual "13")
				WHEN 12 =>
                HEX4 <= "11110000"; -- (dp,g,f,e) apagados (para um visual "12")
				WHEN 11 =>
                HEX4 <= "11111000"; -- (dp,g,f,e,d) apagados (para um visual "11")
				WHEN 10 =>
                HEX4 <= "11111100"; -- (dp,g,f,e,d,c) apagados (para um visual "10")
				WHEN 9 =>
                HEX4 <= "11111110"; -- (dp,g,f,e,d,c,b) apagados (para um visual "9")
				WHEN 8 =>
                HEX5 <= "00000000"; -- Todos segmentos acesos (para um visual "8")
				WHEN 7 =>
                HEX5 <= "10000000"; -- (dp,g) apagados (para um visual "7")
				WHEN 6 =>
                HEX5 <= "11000000"; -- (dp,g,f) apagados (para um visual "6")
				WHEN 5 =>
                HEX5 <= "11100000"; -- (dp,g,f) apagados (para um visual "5")
				WHEN 4 =>
                HEX5 <= "11110000"; -- (dp,g,f,e) apagados (para um visual "4")
				WHEN 3 =>
                HEX5 <= "11111000"; -- (dp,g,f,e,d) apagados (para um visual "3")
				WHEN 2 =>
                HEX5 <= "11111100"; -- (dp,g,f,e,d,c) apagados (para um visual "2")
				WHEN 1 =>
                HEX5 <= "11111110"; -- (dp,g,f,e,d,c,b) apagados (para um visual "1")
				WHEN 0 =>
                HEX5 <= "11111111"; -- (dp,g,f,e,d,c,b,a) apagados (para um visual "0")
				WHEN OTHERS =>
                HEX4 <= "11111111"; -- (dp,g,f,e,d,c,b,a) apagados (default para "8.")
			    HEX5 <= "00000000"; -- (dp,g,f,e,d,c,b,a) acesos (default para "8.")

        END CASE;
    END PROCESS;

END ARCHITECTURE;