library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.can_pkg.all;

entity can_engine is
    port (
        clk               : in  std_logic; 
        clk_out           : out std_logic; -- FSM and transmission timing
        rst               : in  std_logic;
        
        -- Configurações vindas do Register Map
        cnf1_reg          : in  std_logic_vector(7 downto 0);   -- config FSM and transmisson timing
        cnf2_reg          : in  std_logic_vector(7 downto 0); 
        cnf3_reg          : in  std_logic_vector(7 downto 0); 
        
        -- Interface com a can_fsm
        current_state     : in  std_logic_vector(3 downto 0); 
        tx_bit_in         : in  std_logic;                    
        rx_bit_out        : out std_logic;                    
        tx_abort          : out std_logic;                    
        crc_error         : out std_logic;                    
        stuff_error       : out std_logic;                    
        
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
    -- 1. GERADOR DE GERENCIAMENTO DE TEMPO (Bit Timing)
    ------------------------------------------------------------------
    process(clk, rst)
        variable v_brp : unsigned(5 downto 0);
    begin
        if rst = '1' then
            tq_counter <= (others => '0');
            tq_pulse   <= '0';
        elsif rising_edge(clk) then
            v_brp := unsigned(cnf1_reg(5 downto 0)); 
            tq_pulse <= '0';
            
            if tq_counter >= (v_brp + 1) * 2 then
                tq_counter <= (others => '0');
                tq_pulse   <= '1'; 
            else
                tq_counter <= tq_counter + 1;
            end if;
        end if;
    end process;

    process(clk, rst)
    begin
        if rst = '1' then
            bit_time_count <= (others => '0');
            sample_point   <= '0';
        elsif rising_edge(clk) then
            sample_point <= '0';
            if tq_pulse = '1' then
                if bit_time_count = 15 then 
                    bit_time_count <= (others => '0');
                else
                    bit_time_count <= bit_time_count + 1;
                end if;
                
                if bit_time_count = 11 then
                    sample_point <= '1'; 
                end if;
            end if;
        end if;
    end process;

    -- Um bit só é válido para a FSM de controle se ele não for um Stuff Bit descartável
    bit_valid <= sample_point and (not rx_is_stuff_bit);

    ------------------------------------------------------------------
    -- 2. LÓGICA DE DESTUFFING CORRIGIDA
    ------------------------------------------------------------------
    process(clk, rst)
    begin
        if rst = '1' then
            rx_consec_ones   <= (others => '0');
            rx_consec_zeros  <= (others => '0');
            rx_is_stuff_bit  <= '0';
            stuff_error      <= '0';
            rx_clean_bit     <= '1';
        elsif rising_edge(clk) then
            if sample_point = '1' then
                rx_clean_bit <= can_rx;
                
                -- Se o bit atual foi marcado como um stuff bit no ciclo anterior, limpamos os contadores
                if rx_is_stuff_bit = '1' then
                    rx_is_stuff_bit <= '0';
                    if can_rx = '1' then
                        rx_consec_ones  <= "001";
                        rx_consec_zeros <= "000";
                    else
                        rx_consec_zeros <= "001";
                        rx_consec_ones  <= "000";
                    end if;
                else
                    -- Contagem padrão de bits consecutivos idênticos
                    if can_rx = '1' then
                        rx_consec_ones  <= rx_consec_ones + 1;
                        rx_consec_zeros <= (others => '0');
                        
                        -- Violação: 5 bits em '1' e o 6º também é '1'
                        if rx_consec_ones = 5 then
                            stuff_error <= '1';
                        else
                            stuff_error <= '0';
                        end if;
                    else
                        rx_consec_zeros <= rx_consec_zeros + 1;
                        rx_consec_ones  <= (others => '0');
                        
                        -- Violação: 5 bits em '0' e o 6º também é '0'
                        if rx_consec_zeros = 5 then
                            stuff_error <= '1';
                        else
                            stuff_error <= '0';
                        end if;
                    end if;

                    -- Sinaliza se o PRÓXIMO bit esperado deve ser tratado como Stuff Bit
                    if rx_consec_ones = 4 or rx_consec_zeros = 4 then
                        rx_is_stuff_bit <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;

    rx_bit_out <= rx_clean_bit;

    ------------------------------------------------------------------
    -- 3. CÁLCULO GATED DO CRC-15
    ------------------------------------------------------------------
    -- Habilita o cálculo de CRC estritamente durante a leitura de campos válidos de dados/id
    crc_enable <= '1' when (current_state = ST_ARBITRATION_VAL or 
                            current_state = ST_CONTROL_VAL or 
                            current_state = ST_DATA_VAL) else '0';

    process(clk, rst)
        variable crc_nxt : std_logic;
    begin
        if rst = '1' then
            crc_reg   <= (others => '0');
            crc_error <= '0';
        elsif rising_edge(clk) then
            -- Só calcula em bits úteis (Ignora automaticamente os Stuff Bits)
            if sample_point = '1' and crc_enable = '1' and rx_is_stuff_bit = '0' then 
                crc_nxt := can_rx xor crc_reg(14); 
                
                crc_reg(0)  <= crc_nxt;
                crc_reg(1)  <= crc_reg(0);
                crc_reg(2)  <= crc_reg(1);
                crc_reg(3)  <= crc_reg(2) xor crc_nxt; 
                crc_reg(4)  <= crc_reg(3) xor crc_nxt; 
                crc_reg(5)  <= crc_reg(4);
                crc_reg(6)  <= crc_reg(5);
                crc_reg(7)  <= crc_reg(6) xor crc_nxt; 
                crc_reg(8)  <= crc_reg(7) xor crc_nxt; 
                crc_reg(9)  <= crc_reg(8);
                crc_reg(10) <= crc_reg(9) xor crc_nxt; 
                crc_reg(11) <= crc_reg(10);
                crc_reg(12) <= crc_reg(11);
                crc_reg(13) <= crc_reg(12);
                crc_reg(14) <= crc_reg(13) xor crc_nxt; 
            
            -- Quando a FSM entra em modo de checagem do CRC enviado pela rede
            elsif sample_point = '1' and current_state = ST_CRC_VAL then
                if crc_reg /= "000000000000000" then
                    crc_error <= '1'; -- Os dados recebidos e o CRC não batem!
                else
                    crc_error <= '0';
                end if;
            end if;
        end if;
    end process;

    ------------------------------------------------------------------
    -- TRANSMISSÃO FÍSICA
    ------------------------------------------------------------------
    can_tx <= tx_bit_in;

end architecture behavioral;