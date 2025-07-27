-------------------------------------------------------------------
-- Name        : fsm_animation_segs.vhd
-- Author      : Joana Wasserberg
-- Version     : 0.1
-- Copyright   : Joana, Departamento de Eletrônica, Florianópolis, IFSC
-- Description : Implementa uma máquina de estados finitos (FSM) que
--               controla uma sequência animada no display de 7 segmentos.
--               A direção da animação é controlada por um sinal externo.
--               A FSM avança ou retrocede por 13 estados.    
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm_animation_segs is
    port(
        direction : in std_logic;                          -- Direção da animação (1 = direita, 0 = esquerda)
        rst       : in std_logic;                          -- Reset assíncrono
        clk       : in std_logic;                          -- Clock da FSM
        output    : out std_logic_vector(3 downto 0)       -- Saída codificada para representar o estado atual
    );
end entity fsm_animation_segs;


architecture RTL of fsm_animation_segs is 

    -- Estados de animação do display
    type state_type is (IDLE, A, AB, B, BC, C, CD, D, DE, E, EF, F, FA); 
    signal state: state_type;

begin 
    state_transition: process (clk, rst)
    begin
        if rst = '1' then --Reset assíncrono máquina de estados
            state <= IDLE;
            
        elsif rising_edge(clk) then 
            case state is 
            when IDLE =>
                    state <= A;
                
            when A =>
                if direction = '1' then
                    state <= AB;
                elsif direction = '0' then
                    state <= FA;
                end if;

            when AB =>
                if direction = '1' then
                    state <= B;
                elsif direction = '0' then
                    state <= A;
                end if;

            when B =>
                if direction = '1' then
                    state <= BC;
                elsif direction = '0' then
                    state <= AB;
                end if;
            
            when BC =>
                if direction = '1' then
                    state <= C;
                elsif direction = '0' then
                    state <= B;
                end if;

            when C =>
                if direction = '1' then
                    state <= CD;
                elsif direction = '0' then
                    state <= BC;
                end if;

            when CD =>
                if direction = '1' then
                    state <= D;
                elsif direction = '0' then
                    state <= C;
                end if;

            when D =>
                if direction = '1' then
                    state <= DE;
                elsif direction = '0' then
                    state <= CD;
                end if;

            when DE =>
                if direction = '1' then
                    state <= E;
                elsif direction = '0' then
                    state <= D;
                end if;
            
            when E =>
                if direction = '1' then
                    state <= EF;
                elsif direction = '0' then
                    state <= DE;
                end if;

            when EF =>
                if direction = '1' then
                    state <= F;
                elsif direction = '0' then
                    state <= E;
                end if;

            when F =>
                if direction = '1' then
                    state <= FA;
                elsif direction = '0' then
                    state <= EF;
                end if;

            when FA =>
                if direction = '1' then
                    state <= A;
                elsif direction = '0' then
                    state <= F;
                end if;
            end case;
        end if;
    end process;

    out_transition: process (state)
    begin
        output <= "0000";
        case state is
            when IDLE =>
                output <= "0000";            
            when A =>
                output <= "0001";
            when AB =>
                output <= "0010";
            when B =>
                output <= "0011";
            when BC =>
                output <= "0100";
            when C =>
                output <= "0101";
            when CD =>
                output <= "0110";
            when D =>
                output <= "0111";
            when DE =>
                output <= "1000";
            when E =>
                output <= "1001";
            when EF =>
                output <= "1010";
            when F =>
                output <= "1011";
            when FA =>
                output <= "1100";
        end case;
    end process;
end architecture;
