------------------------------------------------------------------------
--! @file
--! @brief Functions used on the divider block
------------------------------------------------------------------------

--! Use standard library
library ieee;
--! Use aritimetic operations
use ieee.numeric_std.all;
--! Use logic elements
use ieee.std_logic_1164.all;

--! @brief Count Leading Zeros and Position of the must significant bit
package division_functions is
  function clz (bits : in std_logic_vector) return integer;
  function msb (bits : in std_logic_vector) return integer;
end package division_functions;

package body division_functions is

  function clz (bits : in std_logic_vector) return integer is

      variable sub_vector : std_logic_vector(7 downto 0);
      type sub_2d is array (0 to 7) of std_logic_vector(1 downto 0);
      variable vector_2d  : sub_2d;
      variable mux_2d     : std_logic_vector(7 downto 0);
      variable clz, expo  : std_logic_vector(0 to 4);

    begin
      --! Four bits count leading zeros
      for index in 7 downto 0 loop
        sub_vector(7-index) := not(bits(4*index+3) or bits(4*index+2) or bits(4*index+1) or bits(4*index));
        vector_2d(7-index)(1) := not (bits(4*index+3) or bits(4*index+2));
        vector_2d(7-index)(0) := (not (bits(4*index+3)) and bits(4*index+2)) or (not(bits(4*index+3) or bits(4*index+1)));
      end loop;

      for i in 0 to 3 loop
        if sub_vector(2*i) = '1' then
          mux_2d(2*i+1 downto 2*i) := vector_2d(2*i+1);
        else
          mux_2d(2*i+1 downto 2*i) := vector_2d(2*i);
        end if;
      end loop;

      expo(0) := sub_vector(0) and sub_vector(1);
      expo(1) := expo(0) and sub_vector(2) and sub_vector(3);
      expo(2) := expo(1) and sub_vector(4) and sub_vector(5);

      case expo(0 to 2) is
        when "000" => expo(3 to 4) := mux_2d(1 downto 0);
        when "100" => expo(3 to 4) := mux_2d(3 downto 2);
        when "110" => expo(3 to 4) := mux_2d(5 downto 4);
        when others => expo(3 to 4) := mux_2d(7 downto 6);
      end case;

      clz(0) := expo(1);
      clz(1) := (expo(0) and not expo(1)) or expo(2);
      clz(2) := (sub_vector(0) and not(expo(0))) or
      (expo(0) and sub_vector(2) and not(expo(1))) or
      (expo(1) and sub_vector(4) and not(expo(2))) or
      (expo(2) and sub_vector(6));
      clz(3) := expo(3);
      clz(4) := expo(4);

    return to_integer(unsigned(clz));

  end clz;

  function msb (bits : in std_logic_vector) return integer is

    variable mlb  : integer := 0;

    begin

      for i in bits'low to bits'high loop
        if bits(i) = '1' then
          mlb := i;
        end if;
      end loop;

      return mlb;

  end msb;

end package body division_functions;
