-------------------------------------------------------------------
-- Name        : semaforo_testbench.vhd
-- Author      : Elvis Fernandes
-- Version     : 0.1
-- Copyright   : Departamento de Eletrônica, Florianópolis, IFSC
-- Description : Projeto Final: Semáforo
-- Date        : 30/08/2024
-------------------------------------------------------------------
--Esse testbench deve instanciar a entidade semáforo, deve possuir os seguintes processos bem como os sinais a serem visualizados no software modelsim:
--Processo de clock: realiza o estímulo do sinal de clock
--Processo de reset: realiza o estímulo do sinal de reset
--Processo de start: realiza o estímulo do sinal de start
--Processo de pedestre: realiza o estímulo do sinal de pedestre
--Processo de carro: realiza o estímulo do sinal de carro
-------------------------------------------------------------------
--Sinais a serem visualizados no software modelsim
--clk: sinal de clock
--rst: sinal de reset
--start: sinal de inicio do semáforo
--pedestre: sinal de início de contagem de pedestre
--carro: sinal de início de contagem de pedestre
--r1: sinal do estado red
--y1: sinal do estado yellow
--g1: sinal do estado green
--ped_count: sinal do número de pedestres contabilizados a ser exibido no no display
--car_count: sinal do número de carros contabilizados a ser exibido no no display
--time_display: sinal de tempo de cada estado do semáforo a ser exibido no display
--visual_display: sinal de segmento de tempo de cada estado do semáforo a ser exibido em cada display
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity semaforo_testbench is
end entity semaforo_testbench;

architecture stimulus of semaforo_testbench is
    signal clk             : std_logic;				-- Sinal de clock
    signal rst             : std_logic;				-- Sinal de reset
    signal start           : std_logic;				-- Sinal para a chave de start
	signal pedestre        : std_logic;				-- Sinal para a chave para contagem de pedestres
	signal carro   	       : std_logic;				-- Sinal para a chave para contagem de carros
	signal r1      	       : std_logic;          	-- Sinal de saída para o vermelho do primeiro semáforo
    signal y1              : std_logic;          	-- Sinal de saída para o amarelo do primeiro semáforo
    signal g1              : std_logic;          	-- Sinal de saída para o verde do primeiro semáforo
    signal ped_count  	   : unsigned(7 DOWNTO 0); 	-- Sinal de contador de pedestres 
	signal car_count  	   : unsigned(7 DOWNTO 0); 	-- Sinal de contador de carros
	signal time_display    : unsigned(7 DOWNTO 0); -- Sinal de contador de tempo de estados do semáforo
	signal visual_display  : unsigned(7 DOWNTO 0); 	-- Sinal para visualizar os segundos finais de tempo de cada estado
	

begin

    -- Instância do DUT do semaforo
    dut : entity work.semaforo
        port map(
            clk            => clk,
            rst            => rst,
            start          => start,
			pedestre       => pedestre,
            carro          => carro,
            r1             => r1,
            y1             => y1,
            g1             => g1,
            ped_count      => ped_count,
			car_count      => car_count,
			time_display   => time_display,
			visual_display => visual_display
        );

    -- Geração do clock de 10 ns (50 MHz)
    stimulus_process_clk : process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process stimulus_process_clk;

    -- Processo para resetar o sistema
    stimulus_process_reset : process
    begin
        rst <= '1';                     -- Ativa reset
        wait for 10 ns;
        rst <= '0';                     -- Libera reset após 10 ns
        wait;
    end process stimulus_process_reset;

    -- Processo para controlar o sinal start
    start_process : process
    begin
        start <= '0';
        wait for 30 ns;                 -- Espera 30 ns antes de ativar o start
        start <= '1';
        wait;
    end process start_process;
	
	-- Processo para controlar o sinal da contagem de pedestres
    pedestre_process : process
    begin
        pedestre <= '0';
        wait for 30 ns;                 -- Espera 30 ns antes de ativar o sinal de pedestres
        pedestre <= '1';
        wait;
    end process pedestre_process;
	
	-- Processo para controlar o sinal da contagem de carros
    carro_process : process
    begin
        carro <= '0';
        wait for 30 ns;                 -- Espera 30 ns antes de ativar o sinal de carros
        carro <= '1';
        wait;
    end process carro_process;
	
end architecture stimulus;
