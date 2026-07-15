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
    signal clk_out         : std_logic;

    signal baud_reg        : std_logic_vector(7 downto 0);
    
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
    
    signal tx_bit_in        : std_logic;         -- can_fsm input | can_engine output            
    signal rx_bit_out       : std_logic;         -- can_fsm output | can_engine input   

    -- Debug signals 
    signal debug            : unsigned(7 downto 0);

    signal tx_abort         : std_logic;

    signal stuff_nxt_bit_out : std_logic; 

begin

    ------------------------------------------------------------------
    -- Instanciação do Dispositivo Sob Teste (DUT)
    ------------------------------------------------------------------
    can_engine_inst : entity work.can_engine
        port map(
            clk           => clk,
            clk_out       => clk_out,
            rst           => rst,
            baud_reg      => baud_reg,
            current_state => current_state_out,
            tx_bit_in     => tx_bit_in,
            rx_bit_out    => rx_bit_out,
            tx_abort      => open,
            stuff_nxt_bit_out => stuff_nxt_bit_out,
            can_rx        => can_rx,
            can_tx        => can_tx
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

        tx_bit_in <= '0';

        --for i in 0 to 31 loop
        --    baud_reg  <= Std_Logic_Vector(to_unsigned(i, baud_reg'length));  
        --    wait for 200 ns;
        --end loop;

        baud_reg  <= "00000000";
        current_state_out <= "0010";
        wait;

    end process;

end architecture sim;