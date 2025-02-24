-------------------------------------------------------------------
-- Name        : pwm.vhd
-- Author      : Thaine Martini
-- Version     : 0.1
-- Copyright   : Thaine, Departamento de Eletrônica, Florianópolis, IFSC
-- Description : Gera umm Pwm de 50 Hz com um duty cycle que varia de 
--	         5us a 1,5ms. Utiliza o contador.vhd para isso
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
        
entity pwm is
    generic (
        constant P: natural :=  31
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        rotate: in unsigned(P downto 0);
        pwm : out std_logic
    );
end entity pwm;

architecture rtl of pwm is
    signal contador : unsigned (P downto 0);
begin

    contador_inst : entity work.contador
    generic map(
            T => P
        )
        port map(
            clk  => clk,
            rst  => rst,
            cont => contador
        );

    process (clk, rst) 

        variable x: integer range 0 to 200000;
        --(63 downto 0);

    begin
            
        if rst = '1' then 
			pwm <= '1';
            x:=0;
    
        elsif rising_edge(clk) then
            x:= 100 * to_integer(rotate);   
            x:= x + 5000;
            if contador < x then
                pwm <= '1';
            else
                pwm <= '0';
            end if;
        end if;
    end process;
end architecture rtl;
