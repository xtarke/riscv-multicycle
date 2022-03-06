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
        MY_CHIPSELECT     : std_logic_vector(1 downto 0) := "10";
        MY_WORD_ADDRESS   : unsigned(15 downto 0)        := x"00A0";
        DADDRESS_BUS_SIZE   : integer                      := 32;
        
        display_width       : integer                      := 16;
        display_heigth      : integer                      := 2;

        -- Countings (clk in = 1MHz)
        t0_startup_time     : integer                      := 40000+20000; --! 40ms [1]
        t1_short_wait       : integer                      := 100+50; --! 100us [1]
        t2_long_wait        : integer                      := 4100+2050; --! 4.1ms [1]
        t3_enable_pulse     : integer                      := 450+225; --! 0,450us [1]
        t4_clear_and_return : integer                      := 1520+760 --! 1,52ms [1]

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
        dmask       : in  std_logic_vector(3 downto 0); --! Byte enable mask

        lcd_is_busy : out std_logic;    --! Bit 13 - Status flag, during command send will be 1, else 0

        --! @brief External signals (IOs to interface with LCD)        
        lcd_data    : out std_logic_vector(7 downto 0);
        lcd_rs      : out std_logic;    --! Controls if command or char data
        lcd_e       : out std_logic;     --! Pulse in every command/data
        
        teste0: out std_logic;
        teste1: out std_logic
        
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

    signal power_state        : fsm_state      := LCD_STARTUP;
    signal command            : lcd_commands   := LCD_CMD_IDLE;
    signal lcd_cmd_init_state : lcd_initialize := LCD_INIT_0;
    signal startup_counter    : integer range 0 to 1000000; --! 0 microseconds to 1s
    signal time_counter       : integer range 0 to 1000000; --! 0 microseconds to 1s
    signal enable_counter     : integer range 0 to 1000000; --! 0 microseconds to 1s

    --! @brief LCD peripheral 32-bit register ("LCDREG0")
    signal lcd_init       : std_logic; --! Bit 8 - Rising edge will start display initialization FSM
    signal lcd_write_char : std_logic; --! Bit 9 - '1' will write char in bits 0-7
    signal lcd_clear      : std_logic; --! Bit 10 - '1' will return cursor to home (Line1-0) and clear display
    signal lcd_goto_l1    : std_logic; --! Bit 11 - '1' will put cursor in first position of line 1
    signal lcd_goto_l2    : std_logic; --! Bit 12 - '1' will put cursor in first position of line 2
    signal lcd_character  : std_logic_vector(7 downto 0);

begin

    process(clk, rst)
    begin
        if (rst = '1') then
            lcd_init <= '0'; 
            lcd_write_char <= '0';
            lcd_clear <= '0';
            lcd_goto_l1 <= '0';
            lcd_goto_l2 <= '0'; 
        elsif rising_edge(clk) then
            if (d_we = '1') and (dcsel = MY_CHIPSELECT) then

                if daddress(15 downto 0) = (MY_WORD_ADDRESS) then
                    lcd_character <= ddata_w(7 downto 0);
                elsif daddress(15 downto 0) = (MY_WORD_ADDRESS+1) then
                    lcd_init <= ddata_w(0);
                elsif daddress(15 downto 0) = (MY_WORD_ADDRESS+2) then
                    lcd_write_char <= ddata_w(0);
                elsif daddress(15 downto 0) = (MY_WORD_ADDRESS+3) then
                    lcd_clear <= ddata_w(0);
                elsif daddress(15 downto 0) = (MY_WORD_ADDRESS+4) then
                    lcd_goto_l1 <= ddata_w(0);
                elsif daddress(15 downto 0) = (MY_WORD_ADDRESS+5) then
                    lcd_goto_l2 <= ddata_w(0);                    
                end if;
            end if;
        end if;
    end process;

    lcd_control : process(clk, rst)
    begin        
        if (rst = '1') then
            power_state     <= LCD_OFF;
            startup_counter <= 0;
            time_counter    <= 0;
            enable_counter  <= 0;
            lcd_data        <= "00000000";
            lcd_e           <= '0';
            lcd_rs          <= '0';

            -- command <= LCD_CMD_INITIALIZE;

            teste0 <= '0';
            teste1 <= '0';

        elsif rising_edge(clk) then

            startup_counter <= startup_counter + 1;
            time_counter    <= time_counter + 1;
            enable_counter  <= enable_counter + 1;

            case power_state is
                when LCD_OFF =>
                    lcd_is_busy <= '0';
                    if (lcd_init = '1') then
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
                    teste0 <= '1';
                    --! Fetch bit instructions to internal "command" signal
                    if (lcd_init = '1') then
                        command <= LCD_CMD_INITIALIZE;
                    elsif (lcd_write_char = '1') then
                        command <= LCD_CMD_WRITE_CHAR;
                        teste1 <= '1';
                    elsif (lcd_clear = '1') then
                        command <= LCD_CMD_CLEAR_RETURN_HOME;
                    elsif (lcd_goto_l1 = '1') then
                        command <= LCD_CMD_GOTO_LINE_1;
                    elsif (lcd_goto_l2 = '1') then
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
                                -- command  <= LCD_CMD_CLEAR_RETURN_HOME;
                                command            <= LCD_CMD_IDLE;
                            end if;
                    end case;
                --! Write char
                when LCD_CMD_WRITE_CHAR =>                        
                    lcd_rs   <= '1';
                    lcd_data <= lcd_character; --lcd_character;
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
    end process;

end controller;
