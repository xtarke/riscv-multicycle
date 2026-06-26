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
        -- cnf registers will be simplified into one register responsible for the preescalling
        -- @TODO Adicionar em can_pkg e register_map
        baud_reg          : in  std_logic_vector(7 downto 0);   -- config FSM and transmisson timing
        --cnf2_reg          : in  std_logic_vector(7 downto 0); 
        --cnf3_reg          : in  std_logic_vector(7 downto 0); 
        
        -- Interface with can_fsm
        current_state     : in  std_logic_vector(3 downto 0); 
        tx_bit_in         : in  std_logic;                    
        rx_bit_out        : out std_logic;                    
        tx_abort          : out std_logic; -- Abort transmission when tx /= rx
        stuff_nxt_bit_out : out std_logic;                 
        -- crc_error         : out std_logic;                 
        -- stuff_error       : out std_logic;                    
        
        -- Transceiver CAN communication
        can_rx            : in  std_logic;
        can_tx            : out std_logic
    );
end entity can_engine;

architecture behavioral of can_engine is

    -- contants to decode and sync with can_fsm states 
    constant ST_IDLE            : std_logic_vector(3 downto 0) := "0000";
    constant ST_SOF             : std_logic_vector(3 downto 0) := "0001";
    constant ST_ARBITRATION_VAL : std_logic_vector(3 downto 0) := "0010";
    constant ST_RTR             : std_logic_vector(3 downto 0) := "0011";
    constant ST_IDE             : std_logic_vector(3 downto 0) := "0100";
    constant ST_R0              : std_logic_vector(3 downto 0) := "0101";
    constant ST_DLC             : std_logic_vector(3 downto 0) := "0110";
    constant ST_DATA            : std_logic_vector(3 downto 0) := "0111";
    constant ST_CRC             : std_logic_vector(3 downto 0) := "1000";

    -- Signals to bit stuffing logic
    --signal compare_buffer  : std_logic_vector(3 downto 0);
    signal stuff_nxt_bit   : std_logic;
    
    
    -- Sinais para o Registrador de Deslocamento do CRC
    signal crc_reg        : std_logic_vector(14 downto 0) := (others => '0');
    signal crc_enable     : std_logic;

    -- Signals t
    signal clk_out_internal : std_logic;

    signal current_bit_to_stuff : std_logic;
    
begin

    ------------------------------------------------------------------
    -- Bit Timing process - Baud rate (abstracted cnf regs)
    ------------------------------------------------------------------
    process(clk, rst)

        variable v_counter : unsigned(7 downto 0) := (others => '0');
        variable var_clk   : std_logic := '0';
        
    begin
        if rst = '1' then
            v_counter := (others => '0');
            if clk = '0' then   --! syncronizes clk and clk_out logic levels
                clk_out_internal <= '0';
                var_clk := '0';
            else
                clk_out_internal <= '1';
                var_clk := '1';
            end if;
        -- using a counter for preescalling
        elsif rising_edge(clk) then
            if v_counter >= unsigned(baud_reg) then
                var_clk := not var_clk;
                v_counter := (others => '0');
            else 
                v_counter := v_counter + 1;
            end if;
        end if;

        clk_out_internal <= var_clk;

    end process;

    clk_out <= clk_out_internal;

    ------------------------------------------------------------------
    -- bit stuffing and rx_can output process
    ------------------------------------------------------------------
    -- bit stuffing occurs from SOF to CRC of can dataframe
    process (clk_out_internal, rst) is

        variable counter  : unsigned(2 downto 0) := (others => '0');
        variable curr_bit : std_logic := '0';

    begin
        if rst = '1' then
            counter := (others => '0');
            curr_bit := RECESSIVE_BIT;
            stuff_nxt_bit <= '0';

        elsif rising_edge(clk_out_internal) then
            if current_state = ST_IDLE then
                curr_bit := RECESSIVE_BIT; --! when in IDLE bit is RECESSIVE = '1'
                counter := (others => '0');
                stuff_nxt_bit <= '0';

            elsif (current_state = ST_SOF) or   --! CAN segments in wich bit stuffing is applied          
                  (current_state = ST_ARBITRATION_VAL) or  
                  (current_state = ST_RTR) or
                  (current_state = ST_IDE) or
                  (current_state = ST_R0) or
                  (current_state = ST_DLC) or
                  (current_state = ST_DATA) or
                  (current_state = ST_CRC) then

               -- Reset counting / prevents bit stuffing in wrong sequence
                if stuff_nxt_bit = '1' then
                    curr_bit := not curr_bit; 
                    counter  := (others => '0');
                    
                    if curr_bit = current_bit_to_stuff then
                        counter := counter + 1;
                    end if;
                    stuff_nxt_bit <= '0'; -- disables bit stuffing for the next clk cycle

                else
                    -- Compare and count sequence of same bits
                    if (curr_bit = current_bit_to_stuff) then    
                        counter := counter + 1;
                    else 
                        counter := "000";
                        curr_bit := current_bit_to_stuff;
                    end if;

                    -- Generates a signal to insert a inverted bit
                    if counter >= 4 then        
                        stuff_nxt_bit <= '1';
                    else
                        stuff_nxt_bit <= '0';
                    end if;
                end if;

            else    -- bit stuffing is not apllied to ACK, EOF and IFS
                curr_bit := current_bit_to_stuff;
                counter := (others => '0');
                stuff_nxt_bit <= '0';
            end if;
        end if;
    end process;

    stuff_nxt_bit_out <= stuff_nxt_bit;
    
    -- Process to transmit tx_can data to the transceiver considering bit stuffing and CRC multiplexing
    process(stuff_nxt_bit, current_state, tx_bit_in, crc_reg)
    begin
        -- with bit stuffing
        if stuff_nxt_bit = '1' then
            if current_state = ST_CRC then
                can_tx <= not crc_reg(14);
            else
                can_tx <= not tx_bit_in;
            end if;
        else
            -- no bit stuffing
            if current_state = ST_CRC then
                can_tx <= crc_reg(14);
            else
                can_tx <= tx_bit_in;
            end if;
        end if;
    end process;

    -- Selects wich signal must be considered to be counted repeated in bit stuffing process
    current_bit_to_stuff <= crc_reg(14) when current_state = ST_CRC 
        else tx_bit_in;

    ------------------------------------------------------------------
    -- CRC-15 calc process
    ------------------------------------------------------------------
    process(clk_out_internal, rst)
        variable crc_next : std_logic;
    begin
        if rst = '1' then
            crc_reg <= (others => '0');
            
        elsif rising_edge(clk_out_internal) then
            
            if current_state = ST_IDLE then
                crc_reg <= (others => '0'); -- Reset at every new frame
                
            elsif (current_state = ST_SOF) or 
                  (current_state = ST_ARBITRATION_VAL) or 
                  (current_state = ST_RTR) or 
                  (current_state = ST_IDE) or 
                  (current_state = ST_R0) or 
                  (current_state = ST_DLC) or 
                  (current_state = ST_DATA) then
                  
                if stuff_nxt_bit = '0' then
                    -- XOR with actual MSB and bit being transmited
                    crc_next := tx_bit_in xor crc_reg(14);
                    
                    -- CRC-15 polynomial shifts
                    crc_reg(14) <= crc_reg(13) xor crc_next;
                    crc_reg(13) <= crc_reg(12);
                    crc_reg(12) <= crc_reg(11);
                    crc_reg(11) <= crc_reg(10);
                    crc_reg(10) <= crc_reg(9)  xor crc_next;
                    crc_reg(9)  <= crc_reg(8);
                    crc_reg(8)  <= crc_reg(7)  xor crc_next;
                    crc_reg(7)  <= crc_reg(6)  xor crc_next;
                    crc_reg(6)  <= crc_reg(5);
                    crc_reg(5)  <= crc_reg(4);
                    crc_reg(4)  <= crc_reg(3)  xor crc_next;
                    crc_reg(3)  <= crc_reg(2)  xor crc_next;
                    crc_reg(2)  <= crc_reg(1);
                    crc_reg(1)  <= crc_reg(0);
                    crc_reg(0)  <= crc_next;
                end if;
                
            elsif current_state = ST_CRC then
                if stuff_nxt_bit = '0' then
                    -- shift CRC calc left every clk_internal cycle
                    crc_reg <= crc_reg(13 downto 0) & '0';
                end if;
            end if;
        end if;
    end process;

    ------------------------------------------------------------------
    -- can bus error check
    ------------------------------------------------------------------
    tx_abort <= '1' when (tx_bit_in /= can_rx) 
        else '0';


end architecture behavioral;