LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

ENTITY testbench IS
END ENTITY testbench;

ARCHITECTURE stimulus OF testbench IS
    constant N: integer := 8;

    -- Declaração de sinais
    signal x0 : std_logic_vector(N-1 downto 0);
    signal x1 : std_logic_vector(N-1 downto 0);
    signal w0 : std_logic_vector(N-1 downto 0);
    signal w1 : std_logic_vector(N-1 downto 0);
    signal output : std_logic_vector(N-1 downto 0);



BEGIN  -- inicio do corpo da arquitetura
    dut: entity work.scalar_product 
        generic map (
            N => N
        ) 
        port map (
            x0 => x0,
            x1 => x1,
            w0 => w0,
            w1 => w1,
            output  => output
    );

    process
    begin
        x0 <= std_logic_vector(To_signed(1, N));
        x1 <= std_logic_vector(To_signed(2, N));

        w0 <= std_logic_vector(To_signed(10, N));
        w1 <= std_logic_vector(To_signed(20, N));
        
        wait for 1 ns;
        assert output = std_logic_vector(To_signed(50, N)) severity failure;

        ---

        x0 <= std_logic_vector(To_signed(0, N));
        x1 <= std_logic_vector(To_signed(0, N));

        w0 <= std_logic_vector(To_signed(0, N));
        w1 <= std_logic_vector(To_signed(0, N));
        
        wait for 1 ns;
        assert output = std_logic_vector(To_signed(0, N)) severity failure;

        ---

        x0 <= std_logic_vector(To_signed(1, N));
        x1 <= std_logic_vector(To_signed(1, N));

        w0 <= std_logic_vector(To_signed(1, N));
        w1 <= std_logic_vector(To_signed(1, N));
        
        wait for 1 ns;
        assert output = std_logic_vector(To_signed(2, N)) severity failure;

        ---

        x0 <= std_logic_vector(To_signed(1, N));
        x1 <= std_logic_vector(To_signed(0, N));

        w0 <= std_logic_vector(To_signed(-1, N));
        w1 <= std_logic_vector(To_signed(-2, N));
        
        wait for 1 ns;
        assert output = std_logic_vector(To_signed(-1, N)) severity failure;

        wait;
    end process;
END ARCHITECTURE stimulus;