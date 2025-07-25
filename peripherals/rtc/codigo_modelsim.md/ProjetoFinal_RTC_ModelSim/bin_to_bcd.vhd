library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Conversor de Binário para BCD (método shift-and-add-3)
entity bin_to_bcd is
    port(
        num_bin    : in  std_logic_vector(15 downto 0);
        num_signal : in  std_logic;
        num_bcd    : out unsigned(15 downto 0)
    );
end entity bin_to_bcd;

architecture rlt of bin_to_bcd is
begin
    process(num_bin, num_signal)
        variable temp : std_logic_vector(15 downto 0);
        variable bcd  : unsigned(19 downto 0) := (others => '0');
    begin
        -- Converte complemento de dois se negativo
        if num_signal = '1' then
            temp := std_logic_vector(unsigned(not num_bin) + 1);
        else
            temp := num_bin;
        end if;

        bcd := (others => '0');

        for i in 0 to 15 loop
            if bcd(3 downto 0) > 4 then
                bcd(3 downto 0) := bcd(3 downto 0) + 3;
            end if;
            if bcd(7 downto 4) > 4 then
                bcd(7 downto 4) := bcd(7 downto 4) + 3;
            end if;
            if bcd(11 downto 8) > 4 then
                bcd(11 downto 8) := bcd(11 downto 8) + 3;
            end if;
            if bcd(15 downto 12) > 4 then
                bcd(15 downto 12) := bcd(15 downto 12) + 3;
            end if;

            bcd  := bcd(18 downto 0) & temp(15);
            temp := temp(14 downto 0) & '0';
        end loop;

        num_bcd <= bcd(15 downto 0);
    end process;
end architecture rlt;

