-------------------------------------------------------
--! file: onewire.vhd
--! author: Eric Monteiro dos Reis
--! Description: OneWire Protocol implementation following the timing specifications for the DS18B20 sensor available at: 
--!              https://www.analog.com/media/en/technical-documentation/data-sheets/ds18b20.pdf
--!              For more details about how the onewire protocol was implemented here, access: https://github.com/ericreis27/vhdl_onewire
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity onewire is
    -- all generic values below represent a micro-seconds time value.
    generic (
        RESET_PULSE_TIME : positive := 500;
        SAMPLE_RESPONSE_TIME : positive := 100;
        DEVICE_RESPONSE_RECOVERY_TIME : positive := 400; 
        SEND_DATA_WAIT_TIME: positive := 500;
        MASTER_WRITE_TIME : positive := 10;
        MASTER_WRITE_SLOT_TIME : positive := 50;
        MASTER_WRITE_RECOVERY_TIME : positive := 5;
        MASTER_POST_WRITE_DELAY_TIME : positive := 480;
        MASTER_AWAIT_READ_SAMPLE_TIME : positive := 10;
        MASTER_READ_RECOVERY_TIME: positive := 55;
        MASTER_POST_READ_DELAY_TIME : positive := 480
    );

    port (
        clk : in std_logic;
        rst : in std_logic;
        data_bus : inout std_logic
    );
end entity onewire;

architecture rtl of onewire is
    type state_type is (
        IDLE,
        RESET,
        SAMPLE_DEVICE_RESPONSE,
        DEVICE_RECOVERY_RESPONSE,
        MASTER_WRITE_DELAY,
        MASTER_WRITE,
        MASTER_WRITE_SLOT,
        MASTER_WRITE_RECOVERY,
        MASTER_POST_WRITE_DELAY,
        MASTER_READ,
        MASTER_AWAIT_READ_SAMPLE,
        MASTER_READ_RECOVERY,
        MASTER_POST_READ_DELAY,
        DONE
    );
    signal all_zeros : unsigned(31 downto 0) := (others => '0'); 
    signal state : state_type;
    signal tristate : std_logic; -- this is used to control the inout data_bus
    signal iterator : unsigned(2 downto 0) := "000"; 
    signal counter_clk : std_logic;
    signal time_slot : unsigned(31 downto 0);
begin
    data_bus <= '0' when tristate = '0' else 'Z';
    state_transition : process (counter_clk, rst) is
    variable device_response_flag : std_logic := '1';
    begin
        if rst = '1' then
            state <= IDLE;

        elsif rising_edge(counter_clk) then
            case state is
                when IDLE =>
                    state <= RESET;
                when RESET =>
                    state <= SAMPLE_DEVICE_RESPONSE;
                when SAMPLE_DEVICE_RESPONSE =>
                    if (data_bus = '0') then
                        device_response_flag := data_bus;
                    else
                        device_response_flag := '1'; --this is done so the device_response_flag doesn't have a tristate value due to the data_bus.
                    end if;

                    state <= DEVICE_RECOVERY_RESPONSE;
                when DEVICE_RECOVERY_RESPONSE =>
                    if (device_response_flag = '0') then
                        state <= MASTER_WRITE_DELAY;
                    else
                        state <= IDLE;
                    end if;
                when MASTER_WRITE_DELAY =>
                    state <= MASTER_WRITE;
                when MASTER_WRITE =>
                    state <= MASTER_WRITE_SLOT;
                when MASTER_WRITE_SLOT =>
                    state <= MASTER_WRITE_RECOVERY;

                when MASTER_WRITE_RECOVERY =>
                    if (iterator = 7) then
                        state <= MASTER_POST_WRITE_DELAY;
                        iterator <= (others => '0');
                    else
                        iterator <= iterator + 1;
                        state <= MASTER_WRITE;
                    end if;
                when MASTER_POST_WRITE_DELAY =>
                    state <= MASTER_READ;
                when MASTER_READ =>
                    state <= MASTER_AWAIT_READ_SAMPLE;
                when MASTER_AWAIT_READ_SAMPLE =>
                    state <= MASTER_READ_RECOVERY;
                when MASTER_READ_RECOVERY =>
                    if (iterator = 7) then
                        state <= MASTER_POST_READ_DELAY;
                        iterator <= (others => '0');
                    else
                        iterator <= iterator + 1;
                        state <= MASTER_READ;
                    end if;
                when MASTER_POST_READ_DELAY =>
                    state <= DONE;
                when DONE =>
                    null;
            end case;
        end if;
    end process state_transition;

    state_machine_control : process (state, iterator) is
        variable write_command : std_logic_vector(7 downto 0) := "00110011"; -- command value to be sent for test purposes
        variable data_buffer : std_logic_vector(7 downto 0) := "00000000"; -- buffer to be used to save the incoming values while reading from the device
    begin
        tristate <= '1';
        case state is
                when IDLE =>
                    null;
                when RESET =>
                    tristate <= '0';
                when SAMPLE_DEVICE_RESPONSE =>
                    null;
                when DEVICE_RECOVERY_RESPONSE =>
                    null;
                when MASTER_WRITE_DELAY =>
                    null;
                when MASTER_WRITE =>
                    tristate <= '0';
                when MASTER_WRITE_SLOT =>
                    if (write_command(to_integer(iterator)) = '1') then
                        tristate <= '1';
                    else
                        tristate <= '0';
                    end if;
                when MASTER_WRITE_RECOVERY =>
                    tristate <= '1';
                when MASTER_POST_WRITE_DELAY =>
                    null;
                when MASTER_READ =>
                    tristate <= '0';
                when MASTER_AWAIT_READ_SAMPLE =>
                    tristate <= '1';
                when MASTER_READ_RECOVERY =>
                    if (data_bus = '0') then
                        data_buffer(to_integer(iterator)) := '0';
                    else
                        data_buffer(to_integer(iterator)) := '1';
                    end if;
                when MASTER_POST_READ_DELAY =>
                    null;
                when DONE =>
                    null;
            end case;
    end process state_machine_control;

    counter : process (clk, rst) is
    begin
        if rst = '1' then
            time_slot <= to_unsigned(1, time_slot'length);
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    if (time_slot > 0) then
                        time_slot <= (others => '0');
                    else
                        time_slot <= time_slot + 1;
                    end if;
                when RESET =>
                    if (time_slot >= RESET_PULSE_TIME - 1) then
                        time_slot <= (others => '0');
                    else
                        time_slot <= time_slot + 1;
                    end if;
                when SAMPLE_DEVICE_RESPONSE =>
                    if (time_slot >= SAMPLE_RESPONSE_TIME - 1) then
                        time_slot <= (others => '0');
                    else
                        time_slot <= time_slot + 1;
                    end if;
                when DEVICE_RECOVERY_RESPONSE =>
                    if (time_slot >= DEVICE_RESPONSE_RECOVERY_TIME - 1) then
                        time_slot <= (others => '0');
                    else
                        time_slot <= time_slot + 1;
                    end if;
                when MASTER_WRITE_DELAY =>
                    if (time_slot >= SEND_DATA_WAIT_TIME - 1) then
                        time_slot <= (others => '0');
                    else
                        time_slot <= time_slot + 1;
                    end if;

                when MASTER_WRITE =>
                    if (time_slot >= MASTER_WRITE_TIME - 1) then
                        time_slot <= (others => '0');
                    else
                        time_slot <= time_slot + 1;
                    end if;
                when MASTER_WRITE_SLOT =>
                    if (time_slot >= MASTER_WRITE_SLOT_TIME - 1) then
                        time_slot <= (others => '0');
                    else
                        time_slot <= time_slot + 1;
                    end if;
                when MASTER_WRITE_RECOVERY =>
                    if (time_slot >= MASTER_WRITE_RECOVERY_TIME - 1) then
                        time_slot <= (others => '0');
                    else
                        time_slot <= time_slot + 1;
                    end if;
                when MASTER_POST_WRITE_DELAY =>
                    if (time_slot >= MASTER_POST_WRITE_DELAY_TIME - 1) then
                        time_slot <= (others => '0');
                    else
                        time_slot <= time_slot + 1;
                    end if;
                when MASTER_READ =>
                    if (time_slot > 0) then
                        time_slot <= (others => '0');
                    else
                        time_slot <= time_slot + 1;
                    end if;
                when MASTER_AWAIT_READ_SAMPLE =>
                    if (time_slot >= MASTER_AWAIT_READ_SAMPLE_TIME - 1) then
                        time_slot <= (others => '0');
                    else
                        time_slot <= time_slot + 1;
                    end if;
                when MASTER_READ_RECOVERY =>
                    if (time_slot >= MASTER_READ_RECOVERY_TIME - 1) then
                        time_slot <= (others => '0');
                    else
                        time_slot <= time_slot + 1;
                    end if;
                when MASTER_POST_READ_DELAY =>
                    if (time_slot >= MASTER_POST_READ_DELAY_TIME - 1) then
                        time_slot <= (others => '0');
                    else
                        time_slot <= time_slot + 1;
                    end if;
                when DONE =>
                    null;
            end case;
        end if;
    end process counter;

    -- process responsible to make the state machine sensible to time_slot reaching a specific time value depending on the current state
    counter_clk_cycle : process (time_slot)
    begin
        if time_slot = all_zeros then
            counter_clk <= '1';
        else
            counter_clk <= '0';
        end if;
    end process;

end architecture rtl;

