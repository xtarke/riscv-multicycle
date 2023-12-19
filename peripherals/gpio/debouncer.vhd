-------------------------------------------------------
--! @file
--! @brief RISCV Simple GPIO module
--         RAM mapped general purpose I/O

--! @Todo: Module should mask bytes (Word, half word and byte access)
--         Daddress shoud be unsgined
--        
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debouncer is

    generic (
        --! Chip selec	
        SYS_FREQ 		: integer := 1; 			-- em megahertz
        COUNTT 			: integer := 5				--
    );

    port(
        clk : in std_logic;
        rst : in std_logic;

        -- hardware input/output signals
        input  : in std_logic;
        output  : out std_logic

    );


end entity debouncer;

architecture RTL_gpio of debouncer is
    signal max_v : unsigned(31 downto 0);
begin
    debouncer: process(clk, rst)
        variable count: unsigned(31 downto 0);
    begin
        if rst = '1' then
            --output <= '0';
            --max_v <= to_unsigned(SYS_FREQ*COUNT, max_v'length);
        else
            if rising_edge(clk) then
                if (input = '1') then
                    if max_v = "00000000000000000000000000000000" then
                    --output <= '1';
                    else
                        max_v <= max_v - 1;
                    end if;
                else
                    --max_v <= to_unsigned(SYS_FREQ*COUNT, max_v'length);
                    --output <= '0';
                end if;
            end if;
        end if;
    end process;
    debouncer2: process(clk, rst)
        variable count: unsigned(2 downto 0);
        variable vetor: unsigned(7 downto 0);
    begin
        if rst = '1' then
            output <= '0';
            count := to_unsigned(0, count'length);
            vetor := to_unsigned(0, vetor'length);
        else
            if rising_edge(clk) then
                vetor(to_integer(count)) := input;
                count:= count +1;
                if ((vetor = "11111111") or (vetor = "00000000")) then -- se os ultimos 12 sao iguais
                    output <= input;
                end if;
            end if;
        end if;
    end process;

end architecture RTL_gpio;
