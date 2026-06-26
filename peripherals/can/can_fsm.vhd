library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.can_pkg.all;

entity can_fsm is
    port (
        clk              : in  std_logic;
        rst              : in  std_logic;
        
        -- higher ID message is being transmitted first -- reestart FSM from SOF when tx_abort LOW
        -- may be set for other errors in the future (ex: bus error, bit error, etc)
        tx_line_free     : in  std_logic; 

        current_state_out: out std_logic_vector(3 downto 0);
        
        -- Register Map Interface (transmission configuration and data)
        canctrl_reg      : in  std_logic_vector(7 downto 0); -- Control Register (CANCTRL) - Bit 0: REQOP0, Bit 1: REQOP1, Bit 2: REQOP2 (define the operating mode of the CAN controller)
        txb0ctrl_reg     : in  std_logic_vector(7 downto 0); -- TXREQ bit (3) is responsible for starting the transmission when set to '1' by the RISC-V
        txb0sidh_reg     : in  std_logic_vector(7 downto 0); -- ID Bits [10:3]
        txb0sidl_reg     : in  std_logic_vector(7 downto 0); -- ID Bits [2:0] mapped in [7:5]
        txb0dlc_reg      : in  std_logic_vector(7 downto 0); -- Data Length Code [3:0]
        r_TXB0Dn         : in  t_tx_data_regs;               -- Transmission data bytes (D0 a D7) 

        -- Interface com a linha física CAN (via Transceiver)
        can_rx           : in  std_logic;         -- can_fsm input | can_engine output            
        can_tx           : out std_logic;         -- can_fsm output | can_engine input           
        
        -- Sinais de Status para atualizar o Register Map
        core_canstat_out : out std_logic_vector(7 downto 0);
        core_canstat_we  : out std_logic;

        -- Signals from can_engine
        stuff_nxt_bit   : in std_logic   -- Tells FSM to stop data transmission for a clock cycle 

        -- Debug
        --debug            : out unsigned(7 downto 0)
    );
end entity can_fsm;

architecture RTL of can_fsm is

    signal current_state  : t_can_state;
    signal tx_request     : std_logic;
    signal data_length    : unsigned(7 downto 0);
    signal crc_reg        : std_logic_vector(14 downto 0) := (others => '0');

begin

    -- TXB0CTRL(3) is TXREQ (Request to Send) bit, when set to '1' by the RISC-V, indicates that a transmission should be initiated with the current buffer configuration
    tx_request <= txb0ctrl_reg(3);      -- @TODO TXREQ do Registrador deve ser mudado ao final da transmissão

    ------------------------------------------------------------------
    -- FSM Process (Synchronous)
    ------------------------------------------------------------------
    process(clk, rst)

        -- bit and byte counters
        variable bit_count  : unsigned(7 downto 0) := (others => '0');
        variable byte_count : unsigned(2 downto 0) := (others => '0');

    begin

        if rst = '1' then
            current_state <= ST_IDLE;
            bit_count     := (others => '0');
            byte_count    := (others => '0');
            can_tx        <= RECESSIVE_BIT;
            data_length   <= x"00";

        -- @ TODO - ST_error - quando tx e rx são diferentes durante transmissão - deve ser verificado por can_engine.vhd
        elsif rising_edge(clk) then

            case current_state is

                when ST_IDLE =>
                    can_tx <= RECESSIVE_BIT;
                    if tx_line_free = '1' and tx_request = '1' then
                        current_state <= ST_SOF;
                    end if;

                when ST_SOF =>
                    can_tx <= DOMINANT_BIT;
                    current_state <= ST_ARBITRATION;

                when ST_ARBITRATION =>
                    if stuff_nxt_bit = '0' then
                        if tx_line_free = '0' then
                            current_state <= ST_IDLE; -- Message ID has less priority than another message being transmitted, aborting and waiting for the next opportunity
                        elsif bit_count >= 10 then
                            current_state <= ST_RTR;
                            can_tx <= txb0sidl_reg(5);      -- LSB of the ID is mapped in bit 5 of TXB0SIDL
                            bit_count := (others => '0');
                        else
                            -- serialize the first 10 bits of the ID
                            if bit_count <= 7 then
                                can_tx <= txb0sidh_reg(7 - to_integer(bit_count)); -- Bits [10:3] are mapped in TXB0SIDH
                            else
                                can_tx <= txb0sidl_reg(7 - (to_integer(bit_count) - 8)); -- Bits [2:0] are mapped in bits [7:5] of TXB0SIDL
                            end if;
                            bit_count := bit_count + 1;
                        end if;
                    end if;

                when ST_RTR =>
                    if stuff_nxt_bit = '0' then
                        can_tx <= txb0dlc_reg(6); -- RTR bit is mapped in bit 6 of TXB0DLC
                        current_state <= ST_IDE;
                    end if;

                when ST_IDE =>
                    if stuff_nxt_bit = '0' then
                        can_tx <= DOMINANT_BIT; -- IDE bit is '0' for standard frames
                        current_state <= ST_R0;
                    end if;
                    
                when ST_R0 =>
                    if stuff_nxt_bit = '0' then
                        can_tx <= DOMINANT_BIT; -- r0 bit is reserved and set to '0'
                        bit_count := (others => '0');
                        current_state <= ST_DLC;
                    end if;

                when ST_DLC =>
                    if stuff_nxt_bit = '0' then
                        data_length(3 downto 0) <= unsigned(txb0dlc_reg(3 downto 0)); -- lenght in bits of data load
                        if bit_count <= 2 then
                            can_tx <= txb0dlc_reg(3 - to_integer(bit_count)); -- DLC bits are mapped in bits [3:0] of TXB0DLC
                            bit_count := bit_count + 1;
                        else
                            can_tx <= txb0dlc_reg(0); -- Last bit of DLC
                            bit_count := (others => '0');
                            if txb0dlc_reg(6) = '0' then -- Transmission Frame
                                current_state <= ST_DATA;
                            else                         -- Remote Frame
                                current_state <= ST_CRC;
                            end if;
                        end if;
                    end if;

                when ST_DATA =>
                    if stuff_nxt_bit = '0' then
                        -- Serializes MSB First in each byte
                        can_tx <= r_TXB0Dn(to_integer(byte_count))(7 - to_integer(bit_count));
                        if bit_count < 7 then
                            bit_count := bit_count + 1;
                        else
                            bit_count := (others => '0');
                            if to_integer(byte_count) >= (data_length - 1) then
                                byte_count := (others => '0');
                                current_state <= ST_CRC;
                            else
                                byte_count := byte_count + 1;
                            end if;
                        end if;
                    end if;

                when ST_CRC =>
                    if stuff_nxt_bit = '0' then
                        -- CRC calculation is implemented in can_engine.vhd
                        if bit_count >= 14 then             -- 15 CRC data bits
                            bit_count := (others => '0');
                            current_state <= ST_CRC_DEL;
                        else 
                            bit_count := bit_count + 1;
                        end if;
                    end if;

                when ST_CRC_DEL =>
                    -- CRC delimiter
                    if stuff_nxt_bit = '0' then
                        can_tx <= RECESSIVE_BIT;
                        current_state <= ST_ACK;
                    end if;

                when ST_ACK =>
                    -- ack slot
                    if bit_count = 0 then
                        bit_count := bit_count + 1;
                        can_tx <= RECESSIVE_BIT; -- Transmitter always sends a recessive bit;
                    else    -- ack delimiter
                        bit_count := (others => '0');
                        can_tx <= RECESSIVE_BIT; -- ack delimiter is always recessive
                        current_state <= ST_EOF;
                    end if;
                    
                when ST_EOF =>
                    if bit_count <= 5 then
                        can_tx <= RECESSIVE_BIT; -- EOF is 7 recessive bits
                        bit_count := bit_count + 1;
                    else
                        can_tx <= RECESSIVE_BIT;
                        bit_count := (others => '0');
                        current_state <= ST_IFS;
                    end if;

                when ST_IFS => -- Interframe Space is at least 3 recessive bits between frames
                    if bit_count <= 1 then
                        bit_count := bit_count + 1;
                    else
                        bit_count := (others => '0');
                        current_state <= ST_IDLE;
                    end if;

                when others =>
                    current_state <= ST_IDLE;

            end case;

            --debug <= bit_count;

        end if;
    end process;

    ------------------------------------------------------------------
    -- Process to generate and sync FSM state with other components
    ------------------------------------------------------------------
    process(current_state, rst)
    begin
        if rst = '1' then
            current_state_out <= "0000";
        end if;

        case current_state is
            when ST_IDLE        => current_state_out <= "0000";
            when ST_SOF         => current_state_out <= "0001";
            when ST_ARBITRATION => current_state_out <= "0010";
            when ST_RTR         => current_state_out <= "0011";
            when ST_IDE         => current_state_out <= "0100";
            when ST_R0          => current_state_out <= "0101";
            when ST_DLC         => current_state_out <= "0110";
            when ST_DATA        => current_state_out <= "0111";
            when ST_CRC         => current_state_out <= "1000";
            when ST_CRC_DEL     => current_state_out <= "1001";
            when ST_ACK         => current_state_out <= "1010";
            when ST_EOF         => current_state_out <= "1011";
            when ST_IFS         => current_state_out <= "1100";
            when others         => current_state_out <= "0000";
        end case;

    end process;

end architecture RTL;