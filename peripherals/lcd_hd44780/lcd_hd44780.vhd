-------------------------------------------------------------------------------
--! @file lcd_hd44780.vhd
--! @brief HD44780 LCD decoder peripheral for RISC-V MAX10 softcore
--! @author Rodrigo da Costa
--! @date 21/08/2021
-------------------------------------------------------------------------------

--! Use standard library
library ieee;
--! Use standard logic elements 
use ieee.std_logic_1164.all;
--! Use conversion functions
use ieee.numeric_std.all;

entity lcd_hd44780 is
    generic(
        MY_CHIPSELECT       : std_logic_vector(1 downto 0) := "11";
        MY_WORD_ADDRESS     : unsigned(15 downto 0)        := x"0020";
        DADDRESS_BUS_SIZE   : integer                      := 32;
        display_width       : integer                      := 16;
        display_heigth      : integer                      := 2;
        -- Countings
        t0_startup_time     : integer                      := 80000; --! 40ms [1]
        t1_short_wait       : integer                      := 200; --! 100us [1]
        t2_long_wait        : integer                      := 10000; --! 4.1ms [1]
        t3_enable_pulse     : integer                      := 500; --! 0,450us [1]
        t4_clear_and_return : integer                      := 2000 --! 1,52ms [1]
    );
    port(
        --! @brief Internal signals (RISC-V Datapath)
        clk         : in  std_logic;
        rst         : in  std_logic;
        -- Core data bus signals
        daddress    : in  unsigned(DADDRESS_BUS_SIZE - 1 downto 0);
        ddata_w     : in  std_logic_vector(31 downto 0);
        ddata_r     : out std_logic_vector(31 downto 0);
        d_we        : in  std_logic;
        d_rd        : in  std_logic;
        dcsel       : in  std_logic_vector(1 downto 0); --! Chip select 
        -- ToDo: Module should mask bytes (Word, half word and byte access)
        dmask       : in  std_logic_vector(3 downto 0); --! Byte enable mask

        -- --! @brief LCD peripheral 32-bit register ("LCDREG0")
        -- lcd_data_in    : in  std_logic; --! 0 to 7
        -- lcd_init       : in  std_logic; --! Bit 8 - Rising edge will start display initialization FSM
        -- lcd_write_char : in  std_logic; --! Bit 9 - '1' will write char in bits 0-7
        -- lcd_clear      : in  std_logic; --! Bit 10 - '1' will return cursor to home (Line1-0) and clear display
        -- lcd_goto_l1    : in  std_logic; --! Bit 11 - '1' will put cursor in first position of line 1
        -- lcd_goto_l2    : in  std_logic; --! Bit 12 - '1' will put cursor in first position of line 2
        lcd_is_busy : out std_logic;    --! Bit 13 - Status flag, during command send will be 1, else 0

        --! @brief External signals (IOs to interface with LCD)
        lcd_data    : out std_logic_vector(7 downto 0);
        lcd_rs      : out std_logic;    --! Controls if command or char data
        lcd_e       : out std_logic     --! Pulse in every command/data
    );
end lcd_hd44780;

architecture controller of lcd_hd44780 is
    type fsm_state is (
        LCD_OFF, LCD_STARTUP, LCD_ON
    );
    type lcd_commands is (
        LCD_CMD_IDLE, LCD_CMD_INITIALIZE, LCD_CMD_WRITE_CHAR, LCD_CMD_CLEAR_RETURN_HOME, LCD_CMD_GOTO_LINE_1, LCD_CMD_GOTO_LINE_2
    );
    type lcd_initialize is (
        LCD_INIT_0, LCD_INIT_1, LCD_INIT_2, LCD_INIT_3, LCD_INIT_4, LCD_INIT_5, LCD_INIT_6
    );

    signal hd44780_register : std_logic_vector(31 downto 0);

    signal power_state        : fsm_state      := LCD_STARTUP;
    signal command            : lcd_commands   := LCD_CMD_IDLE;
    signal lcd_cmd_init_state : lcd_initialize := LCD_INIT_0;
    signal startup_counter    : integer range 0 to 1000000; --! 0 microseconds to 1s
    signal time_counter       : integer range 0 to 1000000; --! 0 microseconds to 1s
    signal enable_counter     : integer range 0 to 1000000; --! 0 microseconds to 1s

    constant LCD_INIT_BIT       : integer := 8;
    constant LCD_WRITE_CHAR_BIT : integer := 9;
    constant LCD_CLEAR_BIT      : integer := 10;
    constant LCD_LINE1_BIT      : integer := 11;
    constant LCD_LINE2_BIT      : integer := 12;

begin
    lcd_control : process(clk, rst)
    begin
        if (rst = '1') then
						hd44780_register <= (others => '0');
            power_state     <= LCD_OFF;
            startup_counter <= 0;
            time_counter    <= 0;
            enable_counter  <= 0;
            lcd_data        <= "00000000";
            lcd_e           <= '0';
            lcd_rs          <= '0';

        elsif rising_edge(clk) then
						if (d_we = '1') and (dcsel = MY_CHIPSELECT) then  
                startup_counter <= startup_counter + 1;
                time_counter    <= time_counter + 1;
                enable_counter  <= enable_counter + 1;

                case power_state is
                    when LCD_OFF =>
                        lcd_is_busy <= '0';
                        if (hd44780_register(LCD_INIT_BIT) = '1') then
                            power_state <= LCD_STARTUP;
                        end if;
                    when LCD_STARTUP =>
                        lcd_is_busy <= '1';
                        if (startup_counter >= t0_startup_time) then
                            startup_counter <= 0;
                            power_state     <= LCD_ON;
                        end if;

                    when LCD_ON =>
                        --! Busy flag control
                        if (command = LCD_CMD_IDLE) then
                            lcd_is_busy <= '0';
                        else
                            lcd_is_busy <= '1';
                        end if;
                end case;
                case command is
                    when LCD_CMD_IDLE =>
                        --! Fetch bit instructions to internal "command" signal
                        if (hd44780_register(LCD_INIT_BIT) = '1') then
                            command <= LCD_CMD_INITIALIZE;
                        elsif (hd44780_register(LCD_WRITE_CHAR_BIT) = '1') then
                            command <= LCD_CMD_WRITE_CHAR;
                        elsif (hd44780_register(LCD_CLEAR_BIT) = '1') then
                            command <= LCD_CMD_CLEAR_RETURN_HOME;
                        elsif (hd44780_register(LCD_LINE1_BIT) = '1') then
                            command <= LCD_CMD_GOTO_LINE_1;
                        elsif (hd44780_register(LCD_LINE2_BIT) = '1') then
                            command <= LCD_CMD_GOTO_LINE_2;
                        else
                            command <= LCD_CMD_IDLE;
                        end if;
                    --! Initialization state machine
                    when LCD_CMD_INITIALIZE =>
                        lcd_rs <= '0';
                        case lcd_cmd_init_state is
                            when LCD_INIT_0 =>
                                lcd_data <= "00110000"; --! Special function set 3x times
                                if (time_counter >= t2_long_wait) then
                                    time_counter       <= 0;
                                    lcd_e              <= '1';
                                    if (enable_counter >= t3_enable_pulse) then
                                        enable_counter <= 0;
                                        lcd_e          <= '0';
                                    end if;
                                    lcd_cmd_init_state <= LCD_INIT_1;
                                end if;
                            when LCD_INIT_1 =>
                                lcd_data <= "00110000";
                                if (time_counter >= t1_short_wait) then
                                    time_counter       <= 0;
                                    lcd_e              <= '1';
                                    if (enable_counter >= t3_enable_pulse) then
                                        enable_counter <= 0;
                                        lcd_e          <= '0';
                                    end if;
                                    lcd_cmd_init_state <= LCD_INIT_2;
                                end if;
                            when LCD_INIT_2 =>
                                lcd_data <= "00110000"; --! Function sets if Nlines = 1 or 2
                                if (time_counter >= t1_short_wait) then
                                    time_counter       <= 0;
                                    lcd_e              <= '1';
                                    if (enable_counter >= t3_enable_pulse) then
                                        enable_counter <= 0;
                                        lcd_e          <= '0';
                                    end if;
                                    lcd_cmd_init_state <= LCD_INIT_3;
                                end if;
                            when LCD_INIT_3 =>
                                lcd_data <= "00001000";
                                if (time_counter >= t1_short_wait) then
                                    time_counter       <= 0;
                                    lcd_e              <= '1';
                                    if (enable_counter >= t3_enable_pulse) then
                                        enable_counter <= 0;
                                        lcd_e          <= '0';
                                    end if;
                                    lcd_cmd_init_state <= LCD_INIT_4;
                                end if;
                            when LCD_INIT_4 =>
                                lcd_data <= "00000001";
                                if (time_counter >= t1_short_wait) then
                                    time_counter       <= 0;
                                    lcd_e              <= '1';
                                    if (enable_counter >= t3_enable_pulse) then
                                        enable_counter <= 0;
                                        lcd_e          <= '0';
                                    end if;
                                    lcd_cmd_init_state <= LCD_INIT_5;
                                end if;
                            when LCD_INIT_5 =>
                                lcd_data <= "00000101";
                                lcd_e    <= '0';
                                if (time_counter >= t1_short_wait) then
                                    time_counter       <= 0;
                                    lcd_e              <= '1';
                                    if (enable_counter >= t3_enable_pulse) then
                                        enable_counter <= 0;
                                        lcd_e          <= '0';
                                    end if;
                                    lcd_cmd_init_state <= LCD_INIT_6;
                                end if;
                            when LCD_INIT_6 =>
                                lcd_data <= "00001101";
                                if (time_counter >= t1_short_wait) then
                                    time_counter       <= 0;
                                    lcd_e              <= '1';
                                    if (enable_counter >= t3_enable_pulse) then
                                        enable_counter <= 0;
                                        lcd_e          <= '0';
                                    end if;
                                    lcd_cmd_init_state <= LCD_INIT_0;
                                    command            <= LCD_CMD_IDLE;
                                end if;
                        end case;
                    --! Write char
                    when LCD_CMD_WRITE_CHAR =>
                        lcd_rs   <= '1';
                        lcd_data <= "01000001"; --! 'A' 01000001 // 00000000
                        --          db7    db0

                        if (time_counter >= t1_short_wait) then
                            time_counter <= 0;
                            lcd_e        <= '1';
                            if (enable_counter >= t3_enable_pulse) then
                                enable_counter <= 0;
                                lcd_e          <= '0';
                            end if;
                        end if;
                        command <= LCD_CMD_IDLE;
                    --! Position cursor in 0x80 (L1) and clear DDRAM
                    when LCD_CMD_CLEAR_RETURN_HOME =>
                        lcd_rs   <= '0';
                        lcd_data <= "00000001";
                        if (time_counter >= t1_short_wait) then
                            time_counter <= 0;
                            lcd_e        <= '1';
                            if (enable_counter >= t3_enable_pulse) then
                                enable_counter <= 0;
                                lcd_e          <= '0';
                            end if;
                        end if;
                        command  <= LCD_CMD_IDLE;
                    --! Position cursor in 0x40 -> 0x80 (L1)
                    when LCD_CMD_GOTO_LINE_1 =>
                        lcd_rs   <= '0';
                        lcd_data <= "10000000";
                        if (time_counter >= t1_short_wait) then
                            time_counter <= 0;
                            lcd_e        <= '1';
                            if (enable_counter >= t3_enable_pulse) then
                                enable_counter <= 0;
                                lcd_e          <= '0';
                            end if;
                        end if;
                        command  <= LCD_CMD_IDLE;
                    --! Position cursor in 0x40 -> 0xC0 (L2)
                    when LCD_CMD_GOTO_LINE_2 =>
                        lcd_rs   <= '0';
                        lcd_data <= "11000000";
                        if (time_counter >= t1_short_wait) then
                            time_counter <= 0;
                            lcd_e        <= '1';
                            if (enable_counter >= t3_enable_pulse) then
                                enable_counter <= 0;
                                lcd_e          <= '0';
                            end if;
                        end if;
                        command  <= LCD_CMD_IDLE;
                end case;
            end if;
        end if;

    end process;

end controller;
