--! Use standard library
library ieee;
--! Use standard logic elements
use ieee.std_logic_1164.all;
--! Use conversion functions
use ieee.numeric_std.all;
--! Use utils functions
use work.all;

entity testbench is
end testbench;

architecture test of testbench is
        signal clk : std_logic;
        signal rst : std_logic;
        signal data_bus : std_logic;
        signal tristate : std_logic;
        signal test_data : std_logic_vector(7 downto 0) := "10101011";
begin
    data_bus <= '0' when tristate = '0' else 'Z';

    dut : entity work.onewire
        port map(
            clk => clk,
            rst => rst,
            data_bus => data_bus
        );

    --! Process Clock_driver generates a clock signal with a 1 us period.
    Clock_driver : process
        constant PERIOD : time :=  1 us;
    begin
        clk <= '0';
        wait for PERIOD / 2;
        clk <= '1';
        wait for PERIOD / 2;
    end process Clock_driver;

    Test : process
    begin
        tristate <= '1';
        rst <= '1';
        wait for 3 us;

        rst <= '0';
        wait for 1000 us;  

        tristate <= '0';
        wait for 700 us;
        
        tristate <= '1'; -- releasing the data_bus 
        wait for 1805 us;  -- TODO: improve this logic so it isn't hardcoded
        
        for i in 0 to 7 loop
            tristate <= '1';
            
            -- TODO: improve this logic so it isn't hardcoded
            if test_data(i) = '0' then
                tristate <= test_data(i);
            end if;
            wait for 15 us;
            tristate <= '1';
            wait for 51 us;
        end loop;
        wait;
    end process Test;

end architecture test;
