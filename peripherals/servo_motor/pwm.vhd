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
        rotate: in integer range 0 to 100;
        pwm : out std_logic
       -- test : out integer range 0 to 2000

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

        variable x: integer range 0 to 2000;

    begin
            
        if rst = '1' then 
			pwm <= '0';
            x:=0;

        elsif rising_edge(clk) then
            x:= rotate * 15;
            x:= x + 500;
            if contador < x then
                pwm <= '1';
            else
                pwm <= '0';
            end if;
        end if;
        --test <=x;
    end process;
end architecture rtl;