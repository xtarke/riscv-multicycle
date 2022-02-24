LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

ENTITY testbench IS
END ENTITY testbench;

ARCHITECTURE stimulus OF testbench IS
    -- Declaração de sinais
    signal input: std_logic_vector(3 downto 0);
    signal segs:  std_logic_vector(7 downto 0);

BEGIN  -- inicio do corpo da arquitetura
    dut: entity work.sigmoidal 
        port map (
            input       => input,
            segs        => segs
        );

    -------------
    process
    begin
        input <= "0000";
        wait for 100ns;

        input <= "0001";
        wait for 100ns;

        input <= "0010";
        wait for 100ns;

        input <= "1110";
        wait for 100ns;

        input <= "1111";
        wait;
    end process;
END ARCHITECTURE stimulus;
