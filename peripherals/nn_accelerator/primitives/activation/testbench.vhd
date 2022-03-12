LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

ENTITY testbench IS
END ENTITY testbench;

ARCHITECTURE stimulus OF testbench IS
    -- Declaração de sinais
    signal input: std_logic_vector(7 downto 0);
    signal output:  std_logic_vector(7 downto 0);

BEGIN  -- inicio do corpo da arquitetura
    dut: entity work.sigmoidal 
        port map (
            input       => input,
            output        => output
        );

    -------------
    process
    begin
        input <= "10000000";
        wait for 1ns;

        input <= "10000011";
        wait for 1ns;

        input <= "10000011";
        wait for 1ns;

        input <= "10001111";
        wait for 1ns;

        input <= "11111111";
        wait for 1ns;

        input <= "00000000";
        wait for 1ns;

        input <= "00000011";
        wait for 1ns;

        input <= "00001111";
        wait for 1ns;

        input <= "00111111";

        wait;
    end process;
END ARCHITECTURE stimulus;
