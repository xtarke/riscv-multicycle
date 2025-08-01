library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
    generic(
        constant n_bits: integer :=2 
    );
    port(  
        clk    : in  std_logic;                               -- clock   clock para o incremento do contador
        aclr_n : in  std_logic;                               -- aclr_n  habilita o contador
        count  : out std_logic_vector(n_bits - 1 downto 0)    -- count   saída
        --termino: out std_logic;                               -- termino de contagem (16 shifts depois)
    );
end entity counter;

architecture RTL of counter is
begin
    
    counter : process(aclr_n,clk) is
    variable var : unsigned(n_bits -1 downto 0) := (count'range => '0');
    begin
        if aclr_n = '0' then
            var := (count'range => '0');
        elsif (clk'event and clk = '1') then
                var := var + 1;
        end if;
        count <= std_logic_vector(var);
    end process counter;
    
end architecture RTL;
