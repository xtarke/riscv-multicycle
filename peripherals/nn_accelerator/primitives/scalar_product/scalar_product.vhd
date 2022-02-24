-------------------------------------------------------
--! @file    scalar_product.vhd
--! @author  Leonardo Benitez
--! @version 0.1
--! @brief   Scalar Product circuit
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	    
entity scalar_product is
    generic(
        N : integer := 5 --! number of bits
        N_INPUTS : integer := 16 --! Number of inputs
    );

    port (
        a : in std_logic_vector(N-1 downto 0);
        b : in std_logic_vector(N-1 downto 0);
        product : out std_logic_vector(N-1 downto 0)
    );
end entity scalar_product;

architecture rtl of scalar_product is
begin
    product <= std_logic_vector(unsigned(a) * unsigned(b)); --TODO
end architecture rtl;