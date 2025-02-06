-------------------------------------------------------------------
-- Name        : pwm.vhd
-- Author      : Thaine Martini
-- Version     : 0.1
-- Copyright   : Thaine, Departamento de Eletrônica, Florianópolis, IFSC
-- Description : 
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
        
entity pwm is
     
    port (
        clk : in std_logic;
        rst : in std_logic;
       -- angulo: in integer range 0 to 100;
        pwm : out std_logic
    );
end entity pwm;

architecture rtl of pwm is
    signal contador : integer range 0 to 20000;
begin

    countador_inst : entity work.contador
        port map(
            clk  => clk,
            rst  => rst,
            cont => contador
        );

    process (clk, rst) 
    begin            
        if rst = '1' then 
			pwm <= '0';

        elsif rising_edge(clk) then
            
            if contador < 1250 then
                pwm <= '1';
            else
                pwm <= '0';
            end if;
        end if;
        
    end process;
end architecture rtl;