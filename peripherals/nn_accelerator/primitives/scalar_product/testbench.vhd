LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

ENTITY testbench IS
END ENTITY testbench;

ARCHITECTURE stimulus OF testbench IS
    constant N_0: integer := 32;
    constant N_1: integer := 64;

    -- Declaração do componente
    component scalar_product is
        generic(
            N: integer := 5
        );
        port (
            a, b: IN std_logic_vector(N-1 downto 0);
            product: OUT std_logic_vector(N-1 downto 0)
        );
    end component scalar_product;

    -- Declaração de sinais
    signal a_0: std_logic_vector(N_0-1 downto 0);
    signal b_0: std_logic_vector(N_0-1 downto 0);
    signal product_0: std_logic_vector(N_0-1 downto 0);

    signal a_1: std_logic_vector(N_1-1 downto 0);
    signal b_1: std_logic_vector(N_1-1 downto 0);
    signal product_1: std_logic_vector(N_1-1 downto 0);

BEGIN  -- inicio do corpo da arquitetura
    process
    begin
        --test N=4
        a_0 <= std_logic_vector(To_unsigned(3, N_0));
        b_0 <= std_logic_vector(To_unsigned(5 , N_0));

        --test N=10
        a_1 <= std_logic_vector(To_unsigned(3, N_1));
        b_1 <= std_logic_vector(To_unsigned(5, N_1));

        ------------------------------
        wait for 250ns;

        --test N=4
        a_0 <= std_logic_vector(To_unsigned(5, N_0));
        b_0 <= std_logic_vector(To_unsigned(2 , N_0));

        --test N=10
        a_1 <= std_logic_vector(To_unsigned(5, N_1));
        b_1 <= std_logic_vector(To_unsigned(2, N_1));

        wait;
    end process;

    dut0: mult 
        generic map (
            N => N_0
        ) 
        port map (
            a => a_0,
            b => b_0,
            product => product_0
    );

    dut1: mult 
        generic map (
            N => N_1
        ) 
        port map (
            a => a_1,
            b => b_1,
            product => product_1
    );
END ARCHITECTURE stimulus;
