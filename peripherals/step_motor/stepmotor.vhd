-------------------------------------------------------------------
-- Name        : stepmotor.vhd
-- Author      : Rayan Martins Steinbach
-- Description : Step motor controller 
-------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stepmotor is
    port(
        clk                : in  std_logic;             -- Clock input
        reverse            : in  std_logic;             -- Reverse flag: Changes the rotation direction
        rst                : in  std_logic;             -- Reset flag: Changes the step motor to it's initial state
        stop               : in  std_logic;             -- Stop flag: Stops the motor in it's actual position
        ena                : in  std_logic;             -- Enable flag: Permits motor control  
        half_full          : in  std_logic;             -- Half or full step flag: Alternate the steps size
        in1, in2, in3, in4 : out std_logic;             -- Motor H-bridge control inputs
        speed              : in  unsigned(2 downto 0)   -- Defines the motor speed, in a range from 1 to 8
    );

end entity stepmotor;

architecture rtl of stepmotor is
    TYPE state_t is (A, AB, B, BC, C, CD, D, DA);
    signal state : state_t;
    signal rot, cntr : std_logic;
    signal outs  : std_logic_vector(3 downto 0);
begin
    in1 <= outs(0);
    in2 <= outs(1);
    in3 <= outs(2);
    in4 <= outs(3);
    rot <= cntr(to_integer(speed));
    
    rotate: process(clk, rst)
    begin
        if rst = '1' then
            cntr <= (others => '0');
        end if;

        if rising_edge(clk) then
            cntr <= cntr + 1;
        end if;
    end process rotate;

    mealy : process(rot, rst)
    begin
        if rst = '1' then
            state <= A;
        end if;
        if rising_edge(clk_s) then
            if en = '1' then
                if stop = '0' then
                    case state is
                        when A =>
                            if reverse = '1' and half_full = '0' then
                                state <= DA;
                            elsif reverse = '0' and half_full = '0' then
                                state <= AB;
                            elsif reverse = '1' and half_full = '1' then
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
                            if reverse = '1' and half_full = '0' then
                                state <= AB;
                            elsif reverse = '0' and half_full = '0' then
                                state <= BC;
                            elsif reverse = '1' and half_full = '1' then
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
                            if reverse = '1' and half_full = '0' then
                                state <= BC;
                            elsif reverse = '0' and half_full = '0' then
                                state <= CD;
                            elsif reverse = '1' and half_full = '1' then
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
                            if reverse = '1' and half_full = '0' then
                                state <= C;
                            elsif reverse = '0' and half_full = '0' then
                                state <= DA;
                            elsif reverse = '1' and half_full = '1' then
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
        end if;
    end process mealy;

    moore : process(clk)
    begin
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
    end process mealy;
end architecture;
