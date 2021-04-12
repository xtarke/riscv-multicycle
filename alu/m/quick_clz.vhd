library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.division_functions.all;

entity quick_clz is
  generic (
    N : natural := 32
  );
  port (
    clk      : in  std_logic;
    rst      : in  std_logic;
    dividend : in  unsigned(N-1 downto 0);
    divisor  : in  unsigned(N-1 downto 0);
    ready    : out std_logic;
    quotient : out unsigned(N-1 downto 0);
    remainder: out unsigned(N-1 downto 0)
  );
end entity;

architecture RTL of quick_clz is

  signal start : std_logic;
  signal new_dividend, new_divisor  : unsigned(N-1 downto 0);

begin

  quick_clz_load : process(clk, rst, dividend, divisor)
  begin

    if rising_edge(clk) then
      if (rst = '1') then
        new_divisor <= (others => '0');
        new_dividend <= (others => '0');
      elsif (divisor /= new_divisor) or (dividend /= new_dividend) then
        start <= '1';
        new_divisor <= divisor;
        new_dividend <= dividend;
      else
        start <= '0';
      end if;
    end if;

  end process quick_clz_load;

  quick_clz_process : process(clk, rst, start)

    variable clz_d, clz_remainder, clz_div  : integer range 0 to N-1;
    variable pre_shifted_divisor            : unsigned(N-1 downto 0);
    variable div_est, div_safe              : unsigned(N-1 downto 0);
    variable sub_result                     : unsigned(N-1 downto 0);
    variable sub_overflow                   : unsigned(N downto 0);
    variable t_remainder, t_quotient        : unsigned(N-1 downto 0);

  begin

    if rst = '1' then
      ready <= '0';
      quotient <= (others => '0');
      remainder <= (others => '0');
      t_quotient := (others => '0');
      t_remainder := (others => '0');
    elsif rising_edge(clk) then
      if start = '1' then
        ready <= '0';
        t_remainder := dividend;
        t_quotient := (others => '0');
      else
        clz_div := clz(std_logic_vector(divisor));
        pre_shifted_divisor := shift_left(divisor, clz_div);
        if divisor <= t_remainder then
          clz_remainder := clz(std_logic_vector(t_remainder));
          clz_d := clz_div - clz_remainder;
          div_est := shift_right(pre_shifted_divisor, clz_remainder);
          div_safe := shift_right(pre_shifted_divisor, clz_remainder+1);
          sub_overflow := (b"0" & t_remainder) - (b"0" & div_est);
          sub_result := t_remainder - div_safe;
          if(sub_overflow(N) = '1') then
            t_remainder := sub_result;
            t_quotient(clz_d-1) := '1';
          else
            t_remainder := sub_overflow(N-1 downto 0);
            t_quotient(clz_d) := '1';
          end if;
        else
          ready <= '1';
          quotient <= t_quotient;
          remainder <= t_remainder;
        end if;
      end if;
    end if;

  end process quick_clz_process;

end architecture;
