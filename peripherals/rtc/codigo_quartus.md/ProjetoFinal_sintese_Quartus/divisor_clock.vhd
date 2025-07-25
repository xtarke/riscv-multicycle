-------------------------------------------------------------------
-- Name        : divisor_clock.vhd
-- Author      : Exemplo baseado em PEDRONI, Eletrônica Digital Moderna e VDHL
-- Version     : 0.1
-- Copyright   : Renan, Departamento de Eletrônica, Florianópolis, IFSC
-- Description : Exemplo de divisor de clock.
-------------------------------------------------------------------

-- Bibliotecas e clásulas
LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;

-- Entidade e portas
ENTITY divisor_clock IS
    PORT (clk, ena: IN std_logic;
          output: OUT std_logic);
END ENTITY;

-- Arquitetura
ARCHITECTURE rtl OF divisor_clock IS
    constant max: NATURAL := 16393;
BEGIN
    p0: process(clk)
        variable count: natural range 0 to max := 0;
        variable temp: std_logic := '0';
    begin
        if (rising_edge(clk)) then
            if ena = '1' then
                count := count + 1;
                if (count = max) then
                    temp := not temp;
                    count := 0;
                end if;           
            end if;            
        end if;    
        output <= temp;        
    end process;
END ARCHITECTURE;
