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

    --signal tx_line_free    : std_logic;

    --signal current_state_out: std_logic_vector(3 downto 0);

    -- Register Map Interface (transmission configuration and data)
    --signal canctrl_reg      : std_logic_vector(7 downto 0); -- Control Register (CANCTRL) - Bit 0: REQOP0, Bit 1: REQOP1, Bit 2: REQOP2 (define the operating mode of the CAN controller)
    --signal txb0ctrl_reg     : std_logic_vector(7 downto 0); -- TXREQ bit (3) is responsible for starting the transmission when set to '1' by the RISC-V
    --signal txb0sidh_reg     : std_logic_vector(7 downto 0); -- ID Bits [10:3]
    --signal txb0sidl_reg     : std_logic_vector(7 downto 0); -- ID Bits [2:0] mapped in [7:5]
    --signal txb0dlc_reg      : std_logic_vector(7 downto 0); -- Data Length Code [3:0]
    --signal r_TXB0Dn         : t_tx_data_regs;               -- Transmission data bytes (D0 a D7)
    -- Interface com a linha física CAN (via Transceiver)
    signal can_rx           : std_logic;         -- can_fsm input | can_engine output
    signal can_tx           : std_logic;         -- can_fsm output | can_engine input

    -- Interface com a CPU
    signal bus_addr  : unsigned(7 downto 0):=(others => '0');
    signal reg_wr_en : std_logic;                       -- Habilita a escrita nos registradores
    signal bus_wdata : std_logic_vector(31 downto 0):=(others => '0');   -- A CPU escreve nos registradores do perfiférico
    signal bus_rdata : std_logic_vector(31 downto 0):=(others => '0');   -- A CPU Lê os registradores do periférico

	signal bus_addr_vec : std_logic_vector(7 downto 0);
    -- Debug signals
    signal debug            : unsigned(7 downto 0);

begin
	can_rx<='1';
	-- bus_addr_vec <= std_logic_vector(bus_addr);
    ------------------------------------------------------------------
    -- Instanciação do Dispositivo Sob Teste (DUT)
    ------------------------------------------------------------------
    can_top_inst : entity work.can_top
        port map(
            clk       => clk,
            rst       => rst,
            bus_addr  => bus_addr,
            reg_wr_en => reg_wr_en,
            bus_wdata => bus_wdata,
            bus_rdata => bus_rdata,
            can_rx    => can_rx,
            can_tx    => can_tx
        );


    ------------------------------------------------------------------
    -- Gerador de Clock
    ------------------------------------------------------------------
    clk_process : process
    begin
        clk <= '1';
        wait for CLK_PERIOD / 2;
        clk <= '0';
        wait for CLK_PERIOD / 2;
    end process;

    ------------------------------------------------------------------
    -- Processo de reset
    ------------------------------------------------------------------
    reset_p : process
    begin
        -- 1. Reset Inicial do Sistema
        rst <= '1';
        wait for 10 ns;
        rst <= '0';
        wait;
    end process;

    ------------------------------------------------------------------
    -- escrita dos registadores
    ------------------------------------------------------------------
	regiters_config_p : process
    begin
        -- espera o fim do reset
        wait for 10 ns;

        -- 1. TXB0SIDH (ID alto)
        bus_addr  <= unsigned(TXB0SIDH);
        bus_wdata <= x"000000AA";
        reg_wr_en <= '1';
        wait for CLK_PERIOD*2;  -- Escreve os registradores TXB0SIDH e TXB0SIDH

        -- 2. TXB0DLC (DLC = 5)
        bus_addr  <= unsigned(TXB0DLC);
        bus_wdata <= x"00000005";
        wait for CLK_PERIOD;

        -- 3. TXB0D0 (primeiro byte de dados)
        bus_addr  <= unsigned(TXB0D0);
        bus_wdata <= x"000000AA";
        wait for CLK_PERIOD;
        -- Escreve os registradores TXB0D1 a TXB0D7
        bus_wdata <= x"00000000";
        wait for CLK_PERIOD*7;

        -- 4. BAUD_REG (prescaler = 0)
        bus_addr  <= unsigned(BAUD_REG);
        bus_wdata <= x"00000000";
        -- reg_wr_en <= '1';
        wait for CLK_PERIOD;

        -- 5. TXB0CTRL (pedido de transmissão)
        bus_addr  <= unsigned(TXB0CTRL);
        bus_wdata <= x"00000008";
        wait for CLK_PERIOD;
        reg_wr_en <= '0';
		wait;
    end process;

end architecture sim;