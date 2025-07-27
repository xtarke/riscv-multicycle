-------------------------------------------------------------------
-- Name        : divisor_clock.vhd
-- Author      : Exemplo baseado em PEDRONI, Eletrônica Digital Moderna e VDHL
-- Version     : 0.1
-- Copyright   : Adaptação do código do professor Renan, Departamento de Eletrônica, Florianópolis, IFSC
-- Description : Divisor de clock com controle de velocidade.
--               Gera um clock de saída com frequência menor, ajustável pelo sinal "speed".
-------------------------------------------------------------------

-- Bibliotecas e clásulas
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entidade e portas
ENTITY divisor_clock IS
   PORT(
        clk        : IN std_logic;                     -- Clock de entrada (rápido)
        rst        : IN std_logic;                     -- Reset síncrono
        ena        : IN std_logic;                     -- Habilita o divisor
        speed      : IN std_logic_vector(1 downto 0);  -- Seleção da velocidade (2 bits)
        clk_output : OUT std_logic                     -- Clock dividido gerado
    );
END ENTITY;

ARCHITECTURE rtl OF divisor_clock IS
begin

    p0: process(clk)
        -- Contador usado para dividir a frequência
        variable count : natural := 0;
        -- Sinal temporário para armazenar o clock gerado
        variable temp  : std_logic := '0';
        -- Valor máximo do contador, ajustável via sinal de velocidade
        variable max   : natural := 10000;

    begin

	if rst = '1' then
            count := 0;
            temp := '1';
				
	elsif (rising_edge(clk)) then
                case speed is
                    when "11" => max := 500; --Mais rápido
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
