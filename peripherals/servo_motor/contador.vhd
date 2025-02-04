-------------------------------------------------------------------
-- Name        : adder.vhd
-- Author      : Thaine Martini
-- Version     : 0.1
-- Copyright   : Thaine, Departamento de Eletrônica, Florianópolis, IFSC
-- Description : 
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
        
entity contador is
     
    port (
        clk : in std_logic;
        rst : in std_logic;
        cont : out integer range 0 to 20000
    );
end entity contador;

architecture rtl of contador is
begin
    process (clk, rst) 
        variable temp: integer range 0 to 20000;
    begin            
        if rst = '1' then 
			cont <= 0;
            temp := 0;

        elsif rising_edge(clk) then
            temp:=temp + 1;
            if temp = 20001 then
                temp:= 0;
            end if;
        end if;
        cont <= temp;
        
    end process;
end architecture rtl;