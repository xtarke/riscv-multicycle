library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.can_pkg.all;

entity testbench is
end entity testbench;

architecture sim of testbench is

    -- Período do Clock (Ex: 50 MHz -> 20 ns)
    constant CLK_PERIOD : time := 20 ns;

    -- Sinais do Stimulus
    signal clk             : std_logic := '0';
    signal rst             : std_logic := '1';
    
    -- Interface de Controle (SPI -> Register Map)
    signal reg_addr        : std_logic_vector(7 downto 0) := (others => '0');
    signal reg_wr_en       : std_logic := '0';
    signal reg_bit_mod_en  : std_logic := '0';
    signal reg_data_in     : std_logic_vector(7 downto 0) := (others => '0');
    signal reg_bit_mask    : std_logic_vector(7 downto 0) := (others => '0');
    signal reg_data_out    : std_logic_vector(7 downto 0);
    
    -- Linhas físicas do barramento CAN
    signal can_rx          : std_logic := '1'; 
    signal can_tx          : std_logic;

    -- Sinal tradicional para controle do fim da simulação
    signal sim_frenar      : boolean := false;

    -- Procedimento auxiliar para simular uma escrita de registrador via SPI
    procedure write_register(
        constant addr : in std_logic_vector(7 downto 0);
        constant data : in std_logic_vector(7 downto 0);
        signal s_addr : out std_logic_vector(7 downto 0);
        signal s_data : out std_logic_vector(7 downto 0);
        signal s_we   : out std_logic
    ) is
    begin
        s_addr <= addr;
        s_data <= data;
        s_we   <= '1';
        wait for CLK_PERIOD;
        s_we   <= '0';
        s_addr <= (others => '0');
        s_data <= (others => '0');
        wait for CLK_PERIOD;
    end procedure;

begin

    ------------------------------------------------------------------
    -- Instanciação do Dispositivo Sob Teste (DUT)
    ------------------------------------------------------------------
    dut : entity work.can_top
        port map (
            clk            => clk,
            rst            => rst,
            reg_addr       => reg_addr,
            reg_wr_en      => reg_wr_en,
            reg_bit_mod_en => reg_bit_mod_en,
            reg_data_in    => reg_data_in,
            reg_bit_mask   => reg_bit_mask,
            reg_data_out   => reg_data_out,
            can_rx         => can_rx,
            can_tx         => can_tx
        );

    ------------------------------------------------------------------
    -- Gerador de Clock Condicional (Substitui o stop do std.env)
    ------------------------------------------------------------------
    clk_process : process
    begin
        -- O clock roda continuamente até que o sinal sim_frenar vire TRUE
        while not sim_frenar loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait; -- Trava o processo definitivamente quando a simulação acaba
    end process;

    ------------------------------------------------------------------
    -- Processo de Estímulo (Stimulus)
    ------------------------------------------------------------------
    stimulus_process : process
    begin
        -- 1. Reset Inicial do Sistema
        rst <= '1';
        can_rx <= '1';
        wait for CLK_PERIOD * 5;
        rst <= '0';
        wait for CLK_PERIOD * 2;

        report "--- Iniciando configuracao dos registradores via SPI ---";

        -- 2. Configura o Baud Rate (CNF1, CNF2, CNF3)
        write_register(CNF1, x"00", reg_addr, reg_data_in, reg_wr_en);
        write_register(CNF2, x"90", reg_addr, reg_data_in, reg_wr_en);
        write_register(CNF3, x"02", reg_addr, reg_data_in, reg_wr_en);

        -- 3. Preenche o payload de transmissão (Buffer TXB0)
        write_register(TXB0SIDH, x"B4", reg_addr, reg_data_in, reg_wr_en); 
        write_register(TXB0SIDL, x"00", reg_addr, reg_data_in, reg_wr_en); 
        write_register(TXB0DLC,  x"01", reg_addr, reg_data_in, reg_wr_en); 
        write_register(TXB0D0,   x"AA", reg_addr, reg_data_in, reg_wr_en);

        -- Altera modo de operação para Modo Normal
        write_register(CANCTRL,  x"00", reg_addr, reg_data_in, reg_wr_en);
        wait for CLK_PERIOD * 20;

        report "--- Disparando solicitacao de transmissao (TXREQ) ---";
        
        -- 4. Setar bit TXREQ para iniciar a transmissão
        write_register(TXB0CTRL, x"08", reg_addr, reg_data_in, reg_wr_en);

        -- Loopback de monitoramento do barramento
        for i in 0 to 5000 loop
            can_rx <= can_tx; 
            wait for CLK_PERIOD;
        end loop;

        report "--- Transmissao concluida. Verificando Reset do TXREQ ---";
        wait for CLK_PERIOD * 100;

        -- Finaliza a simulação parando o gerador de clock
        report "Simulacao concluida com sucesso!";
        sim_frenar <= true; 
        wait; -- Trava este processo de estímulo
    end process;

end architecture sim;