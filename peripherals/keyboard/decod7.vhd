--------------------------------------------------------------------------------------------------
--! @ Luiz Fernando Assis Sene
--! @shifter
--! @brief  Este código descreve o funcionamento de decodificado de 7 segmentos anodo comum.
--!         A entrada do compomenente e um sinal do tipo unsigned de 4 bits e sua saida um
--!         sinal unsigned de 8 bits, ambos possuem o bit mais signficativo a esquerda e cada
--!         entrada esta relacionada a um numero de 0 a 9 e "A a F" no display de 7 segmentos
-------------------------------------------------------------------------------------------------

--! Use standard library
library ieee;
--! Use standard logic elements
use ieee.std_logic_1164.all;
--! Use conversion functions
use ieee.numeric_std.all;

package decod7 is
    
    function decodifica (input7 : unsigned) return unsigned;
    function decodifica (input7 : std_logic_vector) return unsigned;
    
end package decod7;


package body decod7 is
    
    
    type table_convert is array (natural range <>) of unsigned (7 downto 0);
    --variable saida : unsigned(7 downto 0);
    
    constant var : table_convert (0 to 15) :=
    ("11000000","11111001","10100100","10110000","10011001","10010010","10000010", -- 0,1,2,3,4,5,6
     "11111000","10000000","10011000","10001000","10000011","11000110","10100001", -- 7,8,9,A,b,C,d
     "10000110","10001110");                                                       -- e,f

function decodifica (input7 : unsigned) return unsigned is
begin     
    return  var(to_integer(input7));
    
end decodifica;  

function decodifica (input7 : std_logic_vector) return unsigned is
begin     
    return var(to_integer(unsigned(input7)));
    
end decodifica;  
    
end package body decod7;