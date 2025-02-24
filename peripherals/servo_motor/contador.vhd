-------------------------------------------------------------------
-- Name        : contador.vhd
-- Author      : Thaine Martini
-- Version     : 0.1
-- Copyright   : Thaine, Departamento de Eletrônica, Florianópolis, IFSC
-- Description : Contador de 0 a 200000, para converter 10MHz em 50Hz 
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
        
entity contador is
    generic (
        constant T: natural :=  31
    );  
    port (
        clk : in std_logic;
        rst : in std_logic;
        cont : out unsigned (T downto 0)
    );
end entity contador;

architecture rtl of contador is
begin
    process (clk, rst) 
        variable temp: integer range 0 to 200000;
         
    begin            
        if rst = '1' then 
			cont <=(others => '0');
            temp :=0;

        elsif rising_edge(clk) then
            temp:=temp + 1;
            if temp > (199999) then
                temp:= 0;
            end if;
        end if;
        cont <= to_unsigned(temp,cont'length); 
    end process;
end architecture rtl;
