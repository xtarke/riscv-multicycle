-------------------------------------------------------------------
-- Name        : divisor_clock.vhd
-- Author      : Exemplo baseado em PEDRONI, Eletrônica Digital Moderna e VDHL
-- Version     : 0.1
-- Copyright   : Renan, Departamento de Eletrônica, Florianópolis, IFSC
-- Description : Exemplo de divisor de clock.
-------------------------------------------------------------------

-- Bibliotecas e clásulas
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entidade e portas
ENTITY divisor_clock IS
    PORT (clk, rst, ena: IN std_logic;
          speed : in std_logic_vector(1 downto 0);
          clk_output: OUT std_logic);
END ENTITY;

-- Arquitetura
ARCHITECTURE rtl OF divisor_clock IS
begin

    p0: process(clk)
        variable count : natural := 0;
        variable temp  : std_logic := '0';
        variable max   : natural := 10000;

    begin
	 
		
		if rst = '1' then
            count := 0;
            temp := '1';
				
      elsif (rising_edge(clk)) then
                case speed is
                    when "11" => max := 500;
                    when "10" => max := 1000;
                    when "01" => max := 2500;
                    when "00" => max := 10000;
                    when others => max := 500;
                end case;

            if ena = '1' then
                count := count + 1;
                if (count >= max) then
                    temp := not temp;
                    count := 0;
                end if;           
            end if;  
            
            clk_output <= temp;

        end if;  		  
    end process;
END ARCHITECTURE;