library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.can_pkg.all;

entity can_engine is
    port (
        clk               : in  std_logic; 
        clk_out           : out std_logic; -- FSM and transmission timing
        rst               : in  std_logic;
        
        -- Timing configs 
        cnf1_reg          : in  std_logic_vector(7 downto 0);   -- config FSM and transmisson timing
        cnf2_reg          : in  std_logic_vector(7 downto 0); 
        cnf3_reg          : in  std_logic_vector(7 downto 0); 
        
        -- Interface com a can_fsm
        current_state     : in  std_logic_vector(3 downto 0); 
        tx_bit_in         : in  std_logic;                    
        rx_bit_out        : out std_logic;                    
        tx_abort          : out std_logic; -- Abort transmission when tx /= rx                 
        -- crc_error         : out std_logic;                 
        -- stuff_error       : out std_logic;                    
        
        -- Linhas físicas conectadas ao Transceiver CAN
        can_rx            : in  std_logic;
        can_tx            : out std_logic
    );
end entity can_engine;

architecture behavioral of can_engine is

    -- Constantes para decodificação de estado interno da can_fsm
    constant ST_IDLE            : std_logic_vector(3 downto 0) := "0000";
    constant ST_SOF             : std_logic_vector(3 downto 0) := "0001";
    constant ST_ARBITRATION_VAL : std_logic_vector(3 downto 0) := "0010";
    constant ST_RTR             : std_logic_vector(3 downto 0) := "0011";
    constant ST_IDE             : std_logic_vector(3 downto 0) := "0100";
    constant ST_R0              : std_logic_vector(3 downto 0) := "0101";
    constant ST_DLC             : std_logic_vector(3 downto 0) := "0110";
    constant ST_DATA            : std_logic_vector(3 downto 0) := "0111";
    constant ST_CRC             : std_logic_vector(3 downto 0) := "1000";
    constant ST_ACK             : std_logic_vector(3 downto 0) := "1001";
    constant ST_EOF             : std_logic_vector(3 downto 0) := "1010";
    constant ST_IFS             : std_logic_vector(3 downto 0) := "1011";


    -- Sinais para a lógica de Bit Timing
    signal tq_pulse       : std_logic := '0';
    signal tq_counter     : unsigned(7 downto 0) := (others => '0');
    signal sample_point   : std_logic := '0';
    signal bit_time_count : unsigned(4 downto 0) := (others => '0');

    -- Sinais para a lógica de Bit Stuffing
    signal rx_consec_ones   : unsigned(2 downto 0) := (others => '0');
    signal rx_consec_zeros  : unsigned(2 downto 0) := (others => '0');
    signal rx_is_stuff_bit  : std_logic := '0';
    signal rx_clean_bit     : std_logic := '1';
    
    -- Sinais para o Registrador de Deslocamento do CRC
    signal crc_reg        : std_logic_vector(14 downto 0) := (others => '0');
    signal crc_enable     : std_logic;

begin

    ------------------------------------------------------------------
    -- Bit Timing process - Baud rate (based in MCP2515 CNF1 reg)
    ------------------------------------------------------------------


    ------------------------------------------------------------------
    -- bit stuffing and rx_can moutput process
    ------------------------------------------------------------------


    ------------------------------------------------------------------
    -- CRC-15 calc process
    ------------------------------------------------------------------


    ------------------------------------------------------------------
    -- can bus error check
    ------------------------------------------------------------------
    can_tx <= tx_bit_in;

end architecture behavioral;