-------------------------------------------------------------------
-- Name        : HCSR04.vhd
-- Author      : Suzi Yousif
-- Description : Ultrassonic Sensor HC-SR04
-------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity HCSR04 is
    generic (
        --! Chip selec
        MY_CHIPSELECT : std_logic_vector(1 downto 0) := "10";
        MY_WORD_ADDRESS : unsigned(7 downto 0) := x"10";
        DADDRESS_BUS_SIZE : integer := 32                       --! Data bus size
    );

    port(
        clk : in std_logic;
        rst : in std_logic;

        -- Core data bus signals
        -- ToDo: daddress shoud be unsgined
        daddress  : in  unsigned(DADDRESS_BUS_SIZE-1 downto 0);
        ddata_w	  : in 	std_logic_vector(31 downto 0);
        ddata_r   : out	std_logic_vector(31 downto 0);
        d_we      : in std_logic;
        d_rd	  : in std_logic;
        dcsel	  : in std_logic_vector(1 downto 0);	--! Chip select 
        -- ToDo: Module should mask bytes (Word, half word and byte access)
        dmask     : in std_logic_vector(3 downto 0);	--! Byte enable mask

        -- hardware input/output signals
        echo  : in std_logic;
        trig : out std_logic;

        state_debug : out std_logic_vector(7 downto 0)
    );
end entity HCSR04;

architecture RTL of HCSR04 is
    type state_type is (IDLE, TRIG_STATE, SONIC_BURST, ECHO_STATE, REGISTER_STATE);
    signal state : state_type;

    signal counter : unsigned (31 downto 0);
    signal echo_counter : unsigned (31 downto 0);  
    signal measure_ms :   unsigned (31 downto 0);

    -- Simulation constants
    -- constant ECHO_TIMEOUT : integer := 100;    
    -- constant MEASUREMENT_CYCLE : integer := 600; 
    
    -- Real hardware constants
    -- Cycles to wait for echo signal (CLK = 1MHz, 1ms => 1k)
    constant ECHO_TIMEOUT : integer := 1000;    
    -- Cycles to wait for new measurement cycle (datahsheet) (CLK = 1MHz, 60ms => 60k)
    constant MEASUREMENT_CYCLE : integer := 60000; 

begin
    -- Input register
    process(clk, rst)
    begin
        if rst = '1' then
            ddata_r <= (others => '0');
        else
            if rising_edge(clk) then
                if (d_rd = '1') and (dcsel = MY_CHIPSELECT) then
                    ddata_r <= std_logic_vector(measure_ms);
                end if;
            end if;
        end if;
    end process;

    state_transation: process(clk, rst) is
    begin
        if rst = '1' then
            state <= IDLE;
            counter <= (others => '0');
            echo_counter <=  (others => '0');
            measure_ms <= (others => '0');           
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                
                    counter <= (others => '0');
                    echo_counter <=  (others => '0');
                    state <= TRIG_STATE;

                when TRIG_STATE =>
                    counter <= counter + 1;
               
                    if counter > x"0b" then
                        state <= SONIC_BURST;
                        counter <= (others => '0');
                    end if;

                when SONIC_BURST =>
                    
                    counter <= counter + 1;
               
                    if (counter > to_unsigned(ECHO_TIMEOUT, counter'length)) then
                        state <= REGISTER_STATE;
                        counter <= (others => '0');                    
                    elsif (echo = '1') then
                        state <= ECHO_STATE;
                        counter <= (others => '0');
                    end if;

                when ECHO_STATE =>
                     counter <= counter + 1;
                    
                    if (echo = '1') then                        
                        echo_counter <= echo_counter + 1;
                    end if;                    

                    if (counter > to_unsigned(MEASUREMENT_CYCLE, counter'length)) then
                        state <= REGISTER_STATE;
                        counter <= (others => '0');
                    end if;

                when REGISTER_STATE =>
                    measure_ms <= echo_counter;
                    state <= IDLE;   

            end case;
        end if;
    end process;


    moore: process(state)
    begin
        state_debug <= x"00";
        trig <= '0';
        
        case state is 
            when IDLE =>
                state_debug <= x"01";
            when TRIG_STATE =>
                state_debug <= x"02";
                trig <= '1';
            when SONIC_BURST =>
                state_debug <= x"03";
            when ECHO_STATE =>
                state_debug <= x"04";
            when REGISTER_STATE =>
                state_debug <= x"05";
        end case;
    end process;

end architecture RTL;
