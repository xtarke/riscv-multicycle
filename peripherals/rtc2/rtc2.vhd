library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rtc2 is
    generic (
        MY_CHIPSELECT     : std_logic_vector(1 downto 0) := "10"; --regiao de memoria dos perifericos(10)
        MY_WORD_ADDRESS : unsigned(15 downto 0) := x"0260";  --Endereço base interno do RTC nos perifericos
        DADDRESS_BUS_SIZE : integer := 32;    --Tamanho do barramento de endereço.
        CLOCK_HZ          : integer := 1000000 --Frequência do clock de entrada em Hz.para contar 1 segundo
    );

    port (
        clk : in std_logic;
        rst : in std_logic;

        --portas barramento
        daddress : in  unsigned(DADDRESS_BUS_SIZE-1 downto 0); --Endereço que o processador quer acessa
        ddata_w  : in  std_logic_vector(31 downto 0);   --Dado vindo do processador para o periférico
        ddata_r  : out std_logic_vector(31 downto 0);   --Dado que o periférico devolve para o processador
        d_we     : in  std_logic;   --d_we = '1', o processador está fazendo escrita
        d_rd     : in  std_logic;   --d_rd = '1', o processador está fazendo leitura
        dcsel    : in  std_logic_vector(1 downto 0); --Chip select da região de memória(so responde se dcsel = MY_CHIPSELECT)
        dmask    : in  std_logic_vector(3 downto 0); --Máscara de bytes

        --portas RTC
        sec_o  : out std_logic_vector(5 downto 0);
        min_o  : out std_logic_vector(5 downto 0);
        hour_o : out std_logic_vector(4 downto 0)
    );
end entity;

architecture rtl of rtc2 is


    --registradores internos do RTC
    signal tick_counter : integer range 0 to CLOCK_HZ-1 := 0; --Conta ciclos de clock até formar 1 segundo

    signal sec_reg  : unsigned(5 downto 0) := (others => '0');
    signal min_reg  : unsigned(5 downto 0) := (others => '0');
    signal hour_reg : unsigned(4 downto 0) := (others => '0');

    signal day_reg   : unsigned(4 downto 0) := to_unsigned(1, 5);
    signal month_reg : unsigned(3 downto 0) := to_unsigned(1, 4);
    signal year_reg  : unsigned(7 downto 0) := (others => '0');

    signal ctrl_reg : std_logic_vector(31 downto 0) := x"00000001"; --para habilitar o contador do RTC

begin

    sec_o  <= std_logic_vector(sec_reg);
    min_o  <= std_logic_vector(min_reg);
    hour_o <= std_logic_vector(hour_reg);

    --processo de contagem + escrita
    process(clk, rst)
    begin
        if rst = '1' then
            --zera tudo pra default
            tick_counter <= 0;

            sec_reg  <= (others => '0');
            min_reg  <= (others => '0');
            hour_reg <= (others => '0');

            day_reg   <= to_unsigned(1, 5);
            month_reg <= to_unsigned(1, 4);
            year_reg  <= (others => '0');

            ctrl_reg <= x"00000001";

        elsif rising_edge(clk) then

            if ctrl_reg(0) = '1' then --habilita o contador do RTC
                if tick_counter = CLOCK_HZ-1 then
                    tick_counter <= 0;

                    if sec_reg = 59 then
                        sec_reg <= (others => '0');

                        if min_reg = 59 then
                            min_reg <= (others => '0');

                            if hour_reg = 23 then
                                hour_reg <= (others => '0');

                                if day_reg = 31 then
                                    day_reg <= to_unsigned(1, 5);

                                    if month_reg = 12 then
                                        month_reg <= to_unsigned(1, 4);
                                        year_reg <= year_reg + 1;
                                    else
                                        month_reg <= month_reg + 1;
                                    end if;

                                else
                                    day_reg <= day_reg + 1;
                                end if;

                            else
                                hour_reg <= hour_reg + 1;
                            end if;

                        else
                            min_reg <= min_reg + 1;
                        end if;

                    else
                        sec_reg <= sec_reg + 1;
                    end if;

                else
                    tick_counter <= tick_counter + 1;
                end if;
            end if;

            --se o processador está escrevendo no endereço certo doRTC, atualiza os registradores internos
            if (d_we = '1') and (dcsel = MY_CHIPSELECT) then
                case daddress(15 downto 0) is
                    when MY_WORD_ADDRESS =>
                        sec_reg <= unsigned(ddata_w(5 downto 0));

                    when MY_WORD_ADDRESS + 1 =>
                        min_reg <= unsigned(ddata_w(5 downto 0));

                    when MY_WORD_ADDRESS + 2 =>
                        hour_reg <= unsigned(ddata_w(4 downto 0));

                    when MY_WORD_ADDRESS + 3 =>
                        day_reg <= unsigned(ddata_w(4 downto 0));

                    when MY_WORD_ADDRESS + 4 =>
                        month_reg <= unsigned(ddata_w(3 downto 0));

                    when MY_WORD_ADDRESS + 5 =>
                        year_reg <= unsigned(ddata_w(7 downto 0));

                    when MY_WORD_ADDRESS + 6 =>
                        ctrl_reg <= ddata_w;

                    when others =>
                        null;
                end case;
            end if;

        end if;
    end process;

    --processo de leitura
    process(clk, rst)
    begin
        if rst = '1' then
            ddata_r <= (others => '0');

        elsif rising_edge(clk) then
            ddata_r <= (others => '0');

            if (d_rd = '1') and (dcsel = MY_CHIPSELECT) then
                case daddress(15 downto 0) is
                    
                    --se ler o endereço do RTC, devolve o valor do registrador correspondente
                    when MY_WORD_ADDRESS =>
                        ddata_r <= std_logic_vector(resize(sec_reg, 32));

                    when MY_WORD_ADDRESS + 1 =>
                        ddata_r <= std_logic_vector(resize(min_reg, 32));

                    when MY_WORD_ADDRESS + 2 =>
                        ddata_r <= std_logic_vector(resize(hour_reg, 32));

                    when MY_WORD_ADDRESS + 3 =>
                        ddata_r <= std_logic_vector(resize(day_reg, 32));

                    when MY_WORD_ADDRESS + 4 =>
                        ddata_r <= std_logic_vector(resize(month_reg, 32));

                    when MY_WORD_ADDRESS + 5 =>
                        ddata_r <= std_logic_vector(resize(year_reg, 32));

                    when MY_WORD_ADDRESS + 6 =>
                        ddata_r <= ctrl_reg;

                    when others =>
                        ddata_r <= (others => '0');
                end case;
            end if;
        end if;
    end process;

end architecture;