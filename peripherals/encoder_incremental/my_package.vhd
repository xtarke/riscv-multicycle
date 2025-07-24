library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package my_package is
    function conversion_bin_to_7seg(num : unsigned(3 downto 0)) return std_logic_vector;
end package my_package;

package body my_package is
    function conversion_bin_to_7seg(num : unsigned(3 downto 0)) return std_logic_vector is
        type out_seven_seg is array (natural range <>) of std_logic_vector(7 downto 0);
        constant dados : out_seven_seg(0 to 15) := ("11000000", "11111001", "10100100", "10110000",
                                                    "10011001", "10010010", "10000010", "11111000",
                                                    "10000000", "10010000", "10100000", "10000011",
                                                    "11000110", "10100001", "10000100", "10001110");
    begin
        return dados(to_integer(num));
    end;
end package body my_package;

