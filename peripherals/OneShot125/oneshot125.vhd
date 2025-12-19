library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity oneshot125 is
    port(
        clk           : in  std_logic;  -- 50 MHz
        rst           : in  std_logic;
        comando       : in  unsigned(19 downto 0);
        pwm_saida     : out std_logic;
        valor_display : out unsigned(11 downto 0);
        HEX0          : out std_logic_vector(6 downto 0);
        HEX1          : out std_logic_vector(6 downto 0);
        HEX2          : out std_logic_vector(6 downto 0);
        HEX3          : out std_logic_vector(6 downto 0)
    );
end entity;

architecture rtl of oneshot125 is

    type   state_type is (IDLE, PULSO_ALTO, ESPERA_BAIXO);
    signal state      : state_type := IDLE;

    constant PULSO_MIN : integer := 6250;
    constant PULSO_MAX : integer := 12500;

    signal count          : unsigned(14 downto 0) := (others => '0');
    signal largura_pulso  : unsigned(14 downto 0) := (others => '0');
    signal cmd_int        : integer range 0 to 9999;
    signal digito_milhar  : integer range 0 to 9;
    signal digito_centena : integer range 0 to 9;
    signal digito_dezena  : integer range 0 to 9;
    signal digito_unidade : integer range 0 to 9;

    function int_to_7seg(digito : integer) return std_logic_vector is
    begin
        case digito is
            when 0      => return "1000000";
            when 1      => return "1111001";
            when 2      => return "0100100";
            when 3      => return "0110000";
            when 4      => return "0011001";
            when 5      => return "0010010";
            when 6      => return "0000010";
            when 7      => return "1111000";
            when 8      => return "0000000";
            when 9      => return "0010000";
            when others => return "1111111";
        end case;
    end function;

begin

    process(clk, rst)
        variable comando_entrada : integer;
        variable ticks_pulso     : integer;
    begin
        if rst = '1' then
            state     <= IDLE;
            count     <= (others => '0');
             pwm_saida <= '0';
            largura_pulso <= (others => '0');
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    pwm_saida       <= '0';
                    count           <= (others => '0');
                    comando_entrada := to_integer(comando);

                    if comando_entrada < 1000 then
                        valor_display <= to_unsigned(1000, 12);
                    elsif comando_entrada < 1500 then
                        valor_display <= to_unsigned(1500, 12);
                    else
                        valor_display <= to_unsigned(2000, 12);
                    end if;

                    ticks_pulso   := PULSO_MIN + ((comando_entrada - 1000) * (PULSO_MAX - PULSO_MIN)) / 1000;
                    largura_pulso <= to_unsigned(ticks_pulso, largura_pulso'length);
                    state         <= PULSO_ALTO;

                when PULSO_ALTO =>
                    pwm_saida <= '1';
                    if count = largura_pulso - 1 then
                        count <= (others => '0');
                        state <= ESPERA_BAIXO;
                    else
                        count <= count + 1;
                    end if;

                when ESPERA_BAIXO =>
                    pwm_saida <= '0';

                    if count = 19999 - largura_pulso then
                        count <= (others => '0');
                        state <= IDLE;
                    else
                        count <= count + 1;
                    end if;
            end case;
        end if;
    end process;

    cmd_int <= 0 when rst = '1' else to_integer(comando);

    digito_milhar  <= cmd_int / 1000;
    digito_centena <= (cmd_int / 100) mod 10;
    digito_dezena  <= (cmd_int / 10) mod 10;
    digito_unidade <= cmd_int mod 10;

    HEX3 <= int_to_7seg(digito_milhar);
    HEX2 <= int_to_7seg(digito_centena);
    HEX1 <= int_to_7seg(digito_dezena);
    HEX0 <= int_to_7seg(digito_unidade);

end architecture;
