-------------------------------------------------------
-- IFSC
-- Projeto Final - Sofia e Ueslei
-- Periférico de Raiz Quadrada
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity raiz is
    generic (
        MY_CHIPSELECT     : std_logic_vector(1 downto 0) := "10";
        MY_WORD_ADDRESS   : unsigned(15 downto 0) := x"0030";
        DADDRESS_BUS_SIZE : integer := 32
    );

    port(
        clk : in std_logic;
        rst : in std_logic;

        -- Barramento do processador
        daddress : in unsigned(DADDRESS_BUS_SIZE-1 downto 0);
        ddata_w  : in std_logic_vector(31 downto 0);
        ddata_r  : out std_logic_vector(31 downto 0);
        d_we     : in std_logic;
        d_rd     : in std_logic;
        dcsel    : in std_logic_vector(1 downto 0);
        dmask    : in std_logic_vector(3 downto 0);

        -- Entrada física
        switches : in std_logic_vector(9 downto 0);

		-- Saídas físicas
		sqrt_result_out    : out std_logic_vector(4 downto 0);
		sqrt_remainder_out : out std_logic_vector(5 downto 0)
    );
end entity;

architecture RTL of raiz is

    -- Registradores
    signal input_reg       : std_logic_vector(9 downto 0);

    signal result_reg      : std_logic_vector(4 downto 0);
    signal remainder_reg   : std_logic_vector(5 downto 0);

    -- Saídas do ALTSQRT
    signal sqrt_q          : std_logic_vector(4 downto 0);
    signal sqrt_remainder  : std_logic_vector(5 downto 0);

begin

    -- Instância do ALTSQRT
    sqrt_inst : entity work.sqrt
    port map(
        radical   => input_reg,
        q         => sqrt_q,
        remainder => sqrt_remainder
    );

	sqrt_result_out    <= result_reg;
    sqrt_remainder_out <= remainder_reg;

    -- Registrador de entrada
    process(clk,rst)
    begin

        if rst='1' then

            input_reg <= (others=>'0');

        elsif rising_edge(clk) then
            -- O valor de entrada vem diretamente das chaves
            input_reg <= switches;

        end if;

    end process;

    -- Registradores de saída
    process(clk,rst)
    begin

        if rst='1' then

            result_reg    <= (others=>'0');
            remainder_reg <= (others=>'0');

        elsif rising_edge(clk) then

            result_reg    <= sqrt_q;
            remainder_reg <= sqrt_remainder;

        end if;

    end process;

    -- Leitura pelo software
    process(clk,rst)
    begin

        if rst='1' then

            ddata_r <= (others=>'0');

        elsif rising_edge(clk) then
            --ddata_r <= (others=>'0');
            ddata_r <= x"000000AB";

            if (d_rd='1') and (dcsel=MY_CHIPSELECT) then

                case daddress(15 downto 0) is
                    -- Registrador 0
                    -- Operando
                    when MY_WORD_ADDRESS =>
                        ddata_r <= (31 downto 10 => '0') &
                                   input_reg;
                    -- Registrador 1
                    -- Resultado
                    when MY_WORD_ADDRESS + 1 =>

                        ddata_r <= (31 downto 5 => '0') &
                                   result_reg;
                    -- Registrador 2
                    -- Resto
                    when MY_WORD_ADDRESS + 2 =>

                        ddata_r <= (31 downto 6 => '0') &
                                   remainder_reg;

                    when others =>

                        ddata_r <= (others=>'0');

                end case;

            end if;

        end if;

    end process;

    -- Escrita pelo software
    -- O nosso periférico utiliza as chaves como entrada mas se quiserem implementar a escrita do operando via software, adicionar aqui
    --Este processo foi mantido para seguir o padrão dos demais periféricos do projeto e facilitar futuras expansões.
    process(clk,rst)
    begin

        if rst='1' then

            null;

        elsif rising_edge(clk) then

            if (d_we='1') and (dcsel=MY_CHIPSELECT) then

                case daddress(15 downto 0) is

                    when MY_WORD_ADDRESS =>
                        -- Futuramente:
                        -- input_reg <= ddata_w(9 downto 0);
                        null;
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;
end architecture RTL;