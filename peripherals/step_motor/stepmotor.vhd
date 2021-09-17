-------------------------------------------------------------------
-- Name        : stepmotor.vhd                                   --
-- Author      : Rayan Martins Steinbach                         --
-- Description : Step motor controller                           --
-------------------------------------------------------------------
library ieee;                           -- Biblioteca padrao
use ieee.std_logic_1164.all;            -- Elementos logicos
use ieee.numeric_std.all;               -- Conversoes entre tipos

entity stepmotor is
    generic(
        --! Chip selec
        MY_CHIPSELECT     : std_logic_vector(1 downto 0) := "10";
        MY_WORD_ADDRESS   : unsigned(15 downto 0)        := x"0090";
        DADDRESS_BUS_SIZE : integer                      := 32
    );

    port(
        clk      : in  std_logic;       -- Clock input
        rst      : in  std_logic;       -- Reset flag: Changes the step motor to it's initial state

        -- Core data bus signals
        daddress : in  unsigned(DADDRESS_BUS_SIZE - 1 downto 0);
        ddata_w  : in  std_logic_vector(31 downto 0);
        ddata_r  : out std_logic_vector(31 downto 0);
        d_we     : in  std_logic;
        d_rd     : in  std_logic;
        dcsel    : in  std_logic_vector(1 downto 0); --! Chip select 
        -- ToDo: Module should mask bytes (Word, half word and byte access)
        dmask    : in  std_logic_vector(3 downto 0); --! Byte enable mask

        -- hardware input/output signals        
        outs     : out std_logic_vector(3 downto 0) -- Motor H-bridge control inputs
    );

end entity stepmotor;

architecture rtl of stepmotor is
    TYPE state_t is (A, AB, B, BC, C, CD, D, DA);
    signal state              : state_t;
    signal rot                : std_logic;            -- Rotation flag: Trigger the rotation of motor
    signal reset              : std_logic;            -- Reset flag: Returns motor to A state
    signal reverse            : std_logic;            -- Reverse flag: Changes the rotation direction
    signal stop               : std_logic;            -- Stop flag: Stops the motor in it's actual position
    signal half_full          : std_logic;            -- Half or full step flag: Alternate the steps size
    signal speed              : unsigned(2 downto 0); -- Defines the motor speed, in a range from 0 to 7
    signal cntr               : unsigned(7 downto 0); -- Counter signal that controls speed
begin
    -- Process give input value -- processo leitura do Barramento
    process(clk, rst)
    begin
        if rst = '1' then
            reset <= '1';
            reverse <= '0';
            stop <= '0';
            half_full <= '0';
            speed <= to_unsigned(0,speed'length);
        else
            if rising_edge(clk) then
                if (d_we = '1') and (dcsel = MY_CHIPSELECT) then
                    if daddress(15 downto 0) = (MY_WORD_ADDRESS) then
                        reset   <= ddata_w(0);
                    elsif daddress(15 downto 0) = (MY_WORD_ADDRESS+1) then
                        stop <= ddata_w(0);
                    elsif daddress(15 downto 0) = (MY_WORD_ADDRESS+2) then
                        reverse <= ddata_w(0);
                    elsif daddress(15 downto 0) = (MY_WORD_ADDRESS+3) then
                        half_full <= ddata_w(0);
                    elsif daddress(15 downto 0) = (MY_WORD_ADDRESS+4) then
                        speed <= unsigned(ddata_w(2 downto 0));
                    end if;
                end if;
            end if;
        end if;
    end process;

    rotate : process(clk, reset)
    begin
        if reset = '1' then
            cntr <= (others => '0');
        elsif rising_edge(clk) then
            cntr <= cntr + 1;
        end if;
    end process rotate;
    rot <= cntr(7 - to_integer(speed));

    mealy : process(rot, reset)
    begin
        if reset = '1' then
            state <= A;
        elsif rising_edge(rot) then
            if stop = '0' then
                case state is
                    when A =>
                        if (reverse = '1') and half_full = '0' then
                            state <= DA;
                        elsif (reverse = '0') and half_full = '0' then
                            state <= AB;
                        elsif (reverse = '1') and half_full = '1' then
                            state <= D;
                        else
                            state <= B;
                        end if;
                    when AB =>
                        if reverse = '1' then
                            state <= A;
                        else
                            state <= B;
                        end if;
                    when B =>
                        if (reverse = '1') and half_full = '0' then
                            state <= AB;
                        elsif (reverse = '0') and half_full = '0' then
                            state <= BC;
                        elsif (reverse = '1') and half_full = '1' then
                            state <= A;
                        else
                            state <= C;
                        end if;
                    when BC =>
                        if reverse = '1' then
                            state <= B;
                        else
                            state <= C;
                        end if;
                    when C =>
                        if (reverse = '1') and half_full = '0' then
                            state <= BC;
                        elsif (reverse = '0') and half_full = '0' then
                            state <= CD;
                        elsif (reverse = '1') and half_full = '1' then
                            state <= B;
                        else
                            state <= D;
                        end if;
                    when CD =>
                        if reverse = '1' then
                            state <= C;
                        else
                            state <= D;
                        end if;
                    when D =>
                        if (reverse = '1') and half_full = '0' then
                            state <= C;
                        elsif (reverse = '0') and half_full = '0' then
                            state <= DA;
                        elsif (reverse = '1') and half_full = '1' then
                            state <= C;
                        else
                            state <= A;
                        end if;
                    when DA =>
                        if reverse = '1' then
                            state <= D;
                        else
                            state <= A;
                        end if;
                end case;
            end if;
        end if;
    end process mealy;

    moore : process(state)
    begin
        outs <= (others => '0');
        case state is
            when A =>
                outs <= "1000";
            when AB =>
                outs <= "1100";
            when B =>
                outs <= "0100";
            when BC =>
                outs <= "0110";
            when C =>
                outs <= "0010";
            when CD =>
                outs <= "0011";
            when D =>
                outs <= "0001";
            when DA =>
                outs <= "1001";
        end case;
    end process moore;
end architecture;
