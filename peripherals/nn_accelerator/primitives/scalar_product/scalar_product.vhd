-------------------------------------------------------
--! @file    scalar_product.vhd
--! @author  Leonardo Benitez
--! @version 0.1
--! @brief   Scalar Product circuit

--! TODO: overflow check
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	    
entity scalar_product is
    generic(
        N : integer := 32 --! number of bits
    );

    port (
        x0 : in std_logic_vector(N-1 downto 0);
        x1 : in std_logic_vector(N-1 downto 0);
        w0 : in std_logic_vector(N-1 downto 0);
        w1 : in std_logic_vector(N-1 downto 0);
        output : out std_logic_vector(N-1 downto 0)
    );
end entity scalar_product;

architecture rtl of scalar_product is
    signal temp_output : std_logic_vector(2*N-1 downto 0);
begin
    temp_output <= std_logic_vector(
        signed(x0) * signed(w0) + 
        signed(x1) * signed(w1)
    );
    output <=  temp_output (N-1 downto 0) ;
end architecture rtl;