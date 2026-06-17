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
    
    signal tx_line_free    : std_logic; 

    signal current_state_out: std_logic_vector(3 downto 0);
    
    -- Register Map Interface (transmission configuration and data)
    signal canctrl_reg      : std_logic_vector(7 downto 0); -- Control Register (CANCTRL) - Bit 0: REQOP0, Bit 1: REQOP1, Bit 2: REQOP2 (define the operating mode of the CAN controller)
    signal txb0ctrl_reg     : std_logic_vector(7 downto 0); -- TXREQ bit (3) is responsible for starting the transmission when set to '1' by the RISC-V
    signal txb0sidh_reg     : std_logic_vector(7 downto 0); -- ID Bits [10:3]
    signal txb0sidl_reg     : std_logic_vector(7 downto 0); -- ID Bits [2:0] mapped in [7:5]
    signal txb0dlc_reg      : std_logic_vector(7 downto 0); -- Data Length Code [3:0]
    signal r_TXB0Dn         : t_tx_data_regs;               -- Transmission data bytes (D0 a D7) 
    -- Interface com a linha física CAN (via Transceiver)
    signal can_rx           : std_logic;         -- can_fsm input | can_engine output            
    signal can_tx           : std_logic;         -- can_fsm output | can_engine input      

    -- Debug signals 
    signal debug            : unsigned(7 downto 0);

begin

    ------------------------------------------------------------------
    -- Instanciação do Dispositivo Sob Teste (DUT)
    ------------------------------------------------------------------
    dut: entity work.can_fsm
        port map (
            clk              => clk,
            rst              => rst,
            tx_line_free     => tx_line_free,
            can_rx           => can_rx,
            can_tx           => can_tx,
            current_state_out => current_state_out,
            canctrl_reg      => canctrl_reg, 
            txb0ctrl_reg     => txb0ctrl_reg,
            txb0sidh_reg     => txb0sidh_reg,
            txb0sidl_reg     => txb0sidl_reg,
            txb0dlc_reg      => txb0dlc_reg,
            r_TXB0Dn         => r_TXB0Dn, -- Dados de transmissão não são o foco deste teste
            core_canstat_out => open,
            core_canstat_we  => open,
            debug => debug
        );

    ------------------------------------------------------------------
    -- Gerador de Clock 
    ------------------------------------------------------------------
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    ------------------------------------------------------------------
    -- Processo de reset
    ------------------------------------------------------------------
    reset_p : process
    begin
        -- 1. Reset Inicial do Sistema
        rst <= '1';
        wait for 1 ns;
        rst <= '0';
        wait;
    end process;

    ------------------------------------------------------------------
    -- escrita dos registadores
    ------------------------------------------------------------------
    regiters_config_p : process
    begin
        --
        tx_line_free <= '1';    -- allow the transmission
        txb0ctrl_reg <= x"FF";  -- 3th bit TXREQ is 1 
        -- current test ID is xF = 
        txb0sidh_reg <= x"F0";
        txb0sidl_reg <= "10100000";
        -- datalength (first 8 bits) - 1 byte
        txb0dlc_reg <= x"01";
        -- all dataload registers are the same;
        r_TXB0Dn <= (others => "00001000"); 
        wait for 500 ns;

    end process;

end architecture sim;