-------------------------------------------------------------------
-- Name        : HCSR04.vhd
-- Author      : Suzi Yousif, Thiago de Lira
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
        DADDRESS_BUS_SIZE : integer := 32
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
        Trig : out std_logic
    );
end entity HCSR04;

architecture RTL of HCSR04 is
    type state_type is (Idle, Trig_state, Sonic_Burst, Echo_state, Register_state);
    signal state : state_type;

    signal counter : unsigned (31 downto 0);

    signal echo_counter : unsigned (31 downto 0);
    signal echo_wait : unsigned (7 downto 0);
    signal measure_ms :   unsigned (31 downto 0);

    --
    constant ECHO_TIMEOUT : integer := 100;
    constant MEASUREMENT_CYCLE : integer := 600;

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
            state <= Idle;
            echo_wait <= to_unsigned(0, 8);
            echo_counter <=  to_unsigned(0, 32);

            measure_ms <= to_unsigned(0, 32);
            Trig <= '0';

            counter <= (others => '0');

        elsif rising_edge(clk) then
            case state is
                when Idle =>
                    Trig <= '0';
                    echo_counter <=  to_unsigned(0, 32);

                    counter <= (others => '0');

                    state <= Trig_state;

                when Trig_state =>

                    Trig <= '1';

                    counter <= counter + 1;
                    if counter > x"10" then
                        state <= Sonic_Burst;
                        counter <= (others => '0');
                    end if;

                when Sonic_Burst =>
                    Trig <= '0';

                   counter <= counter + 1;
                --if counter > x"0b" then

                        if echo <= '1' then
                            state <= Echo_state;
                            counter <= (others => '0');
                        end if;

                        if counter > to_unsigned (ECHO_TIMEOUT,counter'length)then
                            state <= Register_State;
                        end if;
                    --end if;

                when Echo_state =>
					if (echo = '1') then
						echo_counter <= echo_counter + 1;
					end if;

					counter <= counter + 1;
                    if counter > to_unsigned (MEASUREMENT_CYCLE,counter'length) then
                        state <= Register_State;
                    end if;

				when Register_State =>
				    measure_ms <= echo_counter;
				    state <= Idle;

			end case;
        end if;
    end process;
end architecture RTL;
