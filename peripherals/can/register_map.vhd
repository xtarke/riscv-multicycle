library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.can_pkg.all;

entity register_map is
    port (
        clk           : in  std_logic;  -- system clock, may be the faster possible
        rst           : in  std_logic;  -- Restats the internal state of the CAN controller
        
        -- Risc-V Bus Interface
        bus_addr      : in  std_logic_vector(31 downto 0); -- Target reg address 
        bus_wdata     : in  std_logic_vector(31 downto 0); -- Data to be written to the target register
        bus_rdata     : out std_logic_vector(31 downto 0); -- Data read from the target register @TODO
        bus_we        : in  std_logic;                     -- Write Enable
        -- bus_ack       : out std_logic;                   -- Acknowledge (end of transmission)
        
        -- Interface de Interconexão com o Hardware Interno (CAN Core)
        -- Configurações Globais exportadas para can_engine e can_fsm
        baud_reg_out    : out  std_logic_vector(7 downto 0);   -- config FSM and transmisson baudrate
        --cnf1_out        : out std_logic_vector(7 downto 0);
        --cnf2_out        : out std_logic_vector(7 downto 0);
        --cnf3_out        : out std_logic_vector(7 downto 0);
        canctrl_out     : out std_logic_vector(7 downto 0);
        
        -- Transmission buffers exported to can_fsm 
        txb0ctrl_out    : out std_logic_vector(7 downto 0);
        txb0sidh_out    : out std_logic_vector(7 downto 0);
        txb0sidl_out    : out std_logic_vector(7 downto 0);
        txb0dlc_out     : out std_logic_vector(7 downto 0);
        txb0dn_out      : out t_tx_data_regs;
        
        -- Inputs from other componentes to update registers
        core_canstat_in : in  std_logic_vector(7 downto 0);
        core_canstat_we : in  std_logic
        --core_tec_in     : in  std_logic_vector(7 downto 0);
        --core_rec_in     : in  std_logic_vector(7 downto 0);
        --core_eflg_in    : in  std_logic_vector(7 downto 0);
        --core_status_we  : in  std_logic                      
    );
end entity register_map;

architecture RTL of register_map is

    -- Internal config and status registers
    signal r_CANCTRL  : std_logic_vector(7 downto 0);
    signal r_CANSTAT  : std_logic_vector(7 downto 0);
    --signal r_CNF1     : std_logic_vector(7 downto 0);
    --signal r_CNF2     : std_logic_vector(7 downto 0);
    --signal r_CNF3     : std_logic_vector(7 downto 0);
    signal r_BAUD_REG : std_logic_vector(7 downto 0);
    signal r_CANINTE  : std_logic_vector(7 downto 0);
    signal r_CANINTF  : std_logic_vector(7 downto 0);
    signal r_EFLG     : std_logic_vector(7 downto 0);
    signal r_TEC      : std_logic_vector(7 downto 0);
    signal r_REC      : std_logic_vector(7 downto 0);
    
    -- Transmission Buffers (TXB0)
    signal r_TXB0CTRL : std_logic_vector(7 downto 0);
    signal r_TXB0SIDH : std_logic_vector(7 downto 0);
    signal r_TXB0SIDL : std_logic_vector(7 downto 0);
    signal r_TXB0DLC  : std_logic_vector(7 downto 0);
    signal r_TXB0Dn   : t_tx_data_regs;

begin

    ------------------------------------------------------------------
    -- Register write process
    ------------------------------------------------------------------
    process(clk, rst)

        variable txb0SID_count : bit := '0';
        variable txb0_count : unsigned (2 downto 0) := "000";
        
    begin
        if rst = '1' then
            -- Standard register values(MCP2515)
            r_CANCTRL  <= x"87"; -- Config mode (1000 0111): CONFIG mode, CLKOUT disabled, RXnBF pins disabled
            r_CANSTAT  <= x"80"; -- Status mode (1000 0000): Normal mode, no errors, no interrupts
            --r_CNF1     <= x"00";
            --r_CNF2     <= x"00";
            --r_CNF3     <= x"00";
            r_BAUD_REG <= x"00";
            r_CANINTE  <= x"00";
            r_CANINTF  <= x"00";
            r_EFLG     <= x"00";
            r_TEC      <= x"00";
            r_REC      <= x"00";
            r_TXB0CTRL <= x"00";
            r_TXB0SIDH <= x"00";
            r_TXB0SIDL <= x"00";
            r_TXB0DLC  <= x"00";
            r_TXB0Dn <= (others => (others => '0'));

            txb0SID_count := '0';
            txb0_count := "000";
            
        elsif rising_edge(clk) then
            
            -- -----------------------------------------------------------
            -- Internal updates
            -- -----------------------------------------------------------
            if core_canstat_we = '1' then
                r_CANSTAT <= core_canstat_in;
            end if;
            
            --if core_status_we = '1' then
                --r_TEC  <= core_tec_in;
                --r_REC  <= core_rec_in;
                --r_EFLG <= core_eflg_in;
            --end if;

            -- -----------------------------------------------------------
            -- Updates from processor bus
            -- -----------------------------------------------------------

            -- Se a SPI disparar comando WRITE
            if bus_we = '1' then
                case bus_addr(7 downto 0) is
                    when CANCTRL  => r_CANCTRL  <= bus_wdata(7 downto 0);
                    --when CNF1     => r_CNF1     <= bus_wdata(7 downto 0);
                    --when CNF2     => r_CNF2     <= bus_wdata(7 downto 0);
                    --when CNF3     => r_CNF3     <= bus_wdata(7 downto 0);
                    when BAUD_REG => r_BAUD_REG <= bus_wdata(7 downto 0);
                    when CANINTE  => r_CANINTE  <= bus_wdata(7 downto 0);
                    when CANINTF  => r_CANINTF  <= bus_wdata(7 downto 0);
                    when TXB0CTRL => r_TXB0CTRL <= bus_wdata(7 downto 0);
                    when TXB0SIDH => 
                        if txb0SID_count = '0' then -- allows writing the entire ID with one adress, first the SIDH and then the SIDL
                            r_TXB0SIDH <= bus_wdata(7 downto 0);
                            txb0SID_count := '1';
                        else
                            r_TXB0SIDL <= bus_wdata(7 downto 0);
                            txb0SID_count := '0';
                        end if;
                    when TXB0SIDL => r_TXB0SIDL <= bus_wdata(7 downto 0);
                    when TXB0DLC  => r_TXB0DLC  <= bus_wdata(7 downto 0);
                    when TXB0D0   =>    -- allows writing the entire data payload with one adress, first D0 then D1, D2...D7
                        if txb0_count = "000" then
                            r_TXB0Dn(0) <= bus_wdata(7 downto 0);
                        elsif txb0_count = "001" then
                            r_TXB0Dn(1) <= bus_wdata(7 downto 0);
                        elsif txb0_count = "010" then
                            r_TXB0Dn(2) <= bus_wdata(7 downto 0);
                        elsif txb0_count = "011" then
                            r_TXB0Dn(3) <= bus_wdata(7 downto 0);
                        elsif txb0_count = "100" then
                            r_TXB0Dn(4) <= bus_wdata(7 downto 0);
                        elsif txb0_count = "101" then
                            r_TXB0Dn(5) <= bus_wdata(7 downto 0);
                        elsif txb0_count = "110" then
                            r_TXB0Dn(6) <= bus_wdata(7 downto 0);
                        elsif txb0_count = "111" then
                            r_TXB0Dn(7) <= bus_wdata(7 downto 0);
                        else
                            null;
                        end if;
                        txb0_count := txb0_count + 1;
                    when TXB0D1   => r_TXB0Dn(1) <= bus_wdata(7 downto 0);
                    when TXB0D2   => r_TXB0Dn(2) <= bus_wdata(7 downto 0);
                    when TXB0D3   => r_TXB0Dn(3) <= bus_wdata(7 downto 0);
                    when TXB0D4   => r_TXB0Dn(4) <= bus_wdata(7 downto 0);
                    when TXB0D5   => r_TXB0Dn(5) <= bus_wdata(7 downto 0);
                    when TXB0D6   => r_TXB0Dn(6) <= bus_wdata(7 downto 0);
                    when TXB0D7   => r_TXB0Dn(7) <= bus_wdata(7 downto 0);
                    when others   => null;
                end case;
                
            end if;

        end if;
    end process;


    ------------------------------------------------------------------
    -- Status registers updated by the CAN core (TEC, REC, EFLG)
    ------------------------------------------------------------------


    ------------------------------------------------------------------
    -- Connection signals (registers) with inputs and outputs
    ------------------------------------------------------------------
    --cnf1_out     <= r_CNF1;
    --cnf2_out     <= r_CNF2;
    --cnf3_out     <= r_CNF3;
    baud_reg_out <= r_BAUD_REG;
    canctrl_out  <= r_CANCTRL;
    txb0ctrl_out <= r_TXB0CTRL;
    txb0sidh_out <= r_TXB0SIDH;
    txb0sidl_out <= r_TXB0SIDL;
    txb0dlc_out  <= r_TXB0DLC;
    txb0dn_out   <= r_TXB0Dn;

end architecture RTL;