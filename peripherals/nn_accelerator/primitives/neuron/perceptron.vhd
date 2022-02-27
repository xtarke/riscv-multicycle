-------------------------------------------------------
--! @file    perceptron.vhd
--! @author  Leonardo Benitez
--! @version 0.1
--! @brief   Scalar Product circuit

-- For desambiguiation: 
-- "In the context of neural networks, a perceptron is 
-- an artificial neuron using the Heaviside step 
-- function as the activation function. The perceptron 
-- algorithm is also termed the single-layer perceptron, 
-- to distinguish it from a multilayer perceptron, which 
-- is a misnomer for a more complicated neural network"
-- Wikipedia
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	    
entity perceptron is
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
end entity perceptron;

architecture rtl of perceptron is
    signal pre_activation : std_logic_vector(N-1 downto 0);
begin
    scalar_produt: entity work.scalar_product 
        generic map (
            N => N
        ) 
        port map (
            x0 => x0,
            x1 => x1,
            w0 => w0,
            w1 => w1,
            output  => pre_activation
    );

    activation: entity work.heaviside 
        port map (
            input       => pre_activation,
            output        => output
        );

    --temp_output <= std_logic_vector(
    --    signed(x0) * signed(w0) + 
    --    signed(x1) * signed(w1)
    --);
    --output <=  "01111111"; --temp_output (N-1 downto 0) ;
end architecture rtl;