-------------------------------------------------------------------
-- Name        : rtc.vhd
-- Author      : Thais Silva Lisatchok
-- Created     : 08/07/2025
-- Description : Este código implementa um RTC (Relógio em Tempo Real) 
--               utilizando o método BCD (Código Decimal Codificado em 
--               Binário) para contar os segundos, minutos e horas.
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entidade principal do RTC 
entity rtc is
    Port(
        clk   : in  STD_LOGIC;                      -- Clock do sistema
        rst   : in  STD_LOGIC;                      -- Reset síncrono
        sec   : buffer STD_LOGIC_VECTOR(7 downto 0);   -- Saída: segundos em BCD
        min   : buffer STD_LOGIC_VECTOR(7 downto 0);   -- Saída: minutos em BCD
        hour  : buffer STD_LOGIC_VECTOR(7 downto 0);   -- Saída: horas em BCD
        day   : buffer STD_LOGIC_VECTOR(7 downto 0);   -- Saída: dia em BCD
        month : buffer STD_LOGIC_VECTOR(7 downto 0);   -- Saída: mês em BCD
        year  : buffer STD_LOGIC_VECTOR(15 downto 0);  -- Saída: ano em BCD
        seg0  : out STD_LOGIC_VECTOR(7 downto 0);
        seg1  : out STD_LOGIC_VECTOR(7 downto 0);
        seg2  : out STD_LOGIC_VECTOR(7 downto 0);
        seg3  : out STD_LOGIC_VECTOR(7 downto 0);
        seg4  : out STD_LOGIC_VECTOR(7 downto 0);
        seg5  : out STD_LOGIC_VECTOR(7 downto 0)
    );
end rtc;

architecture Behavioral of rtc is

    -- Função auxiliar para conversão BCD para 7 segmentos
    function bin_to_bcd(bin : std_logic_vector(3 downto 0)) return std_logic_vector is
    begin
        case bin is
            when "0000" => return "11000000"; -- 0
            when "0001" => return "11111001"; -- 1
            when "0010" => return "10100100"; -- 2
            when "0011" => return "10110000"; -- 3
            when "0100" => return "10011001"; -- 4
            when "0101" => return "10010010"; -- 5
            when "0110" => return "10000010"; -- 6
            when "0111" => return "11111000"; -- 7
            when "1000" => return "10000000"; -- 8
            when "1001" => return "10010000"; -- 9
            when others => return "11111111"; -- apagado
        end case;
    end function;

    -- Sinais internos para contadores em binário
    signal sec_cnt   : STD_LOGIC_VECTOR(7 downto 0)  := (others => '0');
    signal min_cnt   : STD_LOGIC_VECTOR(7 downto 0)  := (others => '0');
    signal hour_cnt  : STD_LOGIC_VECTOR(7 downto 0)  := (others => '0');
    signal day_cnt   : STD_LOGIC_VECTOR(7 downto 0)  := "00000001";
    signal month_cnt : STD_LOGIC_VECTOR(7 downto 0)  := "00000001";
    signal year_cnt  : STD_LOGIC_VECTOR(15 downto 0) := "0000011111101001";

    -- Sinais auxiliares para o conversor BCD
    signal sec_cnt_ext, min_cnt_ext, hour_cnt_ext   : STD_LOGIC_VECTOR(15 downto 0);
    signal day_cnt_ext, month_cnt_ext, year_cnt_ext : STD_LOGIC_VECTOR(15 downto 0);

    signal sec_bcd, min_bcd, hour_bcd     : unsigned(15 downto 0);
    signal day_bcd, month_bcd, year_bcd   : unsigned(15 downto 0);

    signal dummy_sign : STD_LOGIC := '0';

    -- Sinal do divisor de clock
    signal divisor_clock : STD_LOGIC;  -- O sinal de clock gerado pelo divisor de clock

begin

    -- Divisor de Clock
    -- Instância do divisor de clock para gerar o sinal de 1 segundo
    divisor_clock_inst : entity work.divisor_clock
        port map (
            clk => clk,    -- 1 MHz (ou o seu clock de entrada)
            ena => '1',    -- Habilita o contador
            output => divisor_clock  -- O sinal divisor_clock será o sinal de 1 segundo gerado
        );

    -- Processo de contagem do tempo
    process(divisor_clock, rst)
    begin
        if rst = '1' then
            -- Reseta todos os contadores
            sec_cnt   <= (others => '0');
            min_cnt   <= (others => '0');
            hour_cnt  <= (others => '0');
            day_cnt   <= "00000001";       -- Dia começa em 1
            month_cnt <= "00000001";       -- Mês começa em 1
            year_cnt  <= "0000011111101001"; -- Ano começa em 2025

        elsif rising_edge(divisor_clock) then
            -- Incrementa os segundos até 59
            if sec_cnt = "00111011" then -- 59 decimal
                sec_cnt <= (others => '0');

                -- Incrementa os minutos até 59
                if min_cnt = "00111011" then -- 59 decimal
                    min_cnt <= (others => '0');

                    -- Incrementa as horas até 23
                    if hour_cnt = "00010111" then -- 23 decimal
                        hour_cnt <= (others => '0');

                        -- Incrementa os dias até 31 (simplificado, sem meses de 30/28 dias)
                        if day_cnt = "00011111" then -- 31 decimal
                            day_cnt <= "00000001"; -- Reinicia o dia

                            -- Incrementa os meses até 12
                            if month_cnt = "00001100" then -- 12 decimal
                                month_cnt <= "00000001"; -- Reinicia mês
                                year_cnt  <= std_logic_vector(unsigned(year_cnt) + 1); -- Incrementa ano
                            else
                                month_cnt <= std_logic_vector(unsigned(month_cnt) + 1); -- Próximo mês
                            end if;

                        else
                            day_cnt <= std_logic_vector(unsigned(day_cnt) + 1); -- Próximo dia
                        end if;

                    else
                        hour_cnt <= std_logic_vector(unsigned(hour_cnt) + 1); -- Próxima hora
                    end if;

                else
                    min_cnt <= std_logic_vector(unsigned(min_cnt) + 1); -- Próximo minuto
                end if;

            else
                sec_cnt <= std_logic_vector(unsigned(sec_cnt) + 1); -- Próximo segundo
            end if;
        end if;
    end process;

    -- Expansão dos sinais de 8 para 16 bits, necessário para o conversor BCD
    sec_cnt_ext   <= (7 downto 0 => '0') & sec_cnt;
    min_cnt_ext   <= (7 downto 0 => '0') & min_cnt;
    hour_cnt_ext  <= (7 downto 0 => '0') & hour_cnt;
    day_cnt_ext   <= (7 downto 0 => '0') & day_cnt;
    month_cnt_ext <= (7 downto 0 => '0') & month_cnt;
    year_cnt_ext  <= year_cnt;

    -- Instâncias do conversor binário para BCD
    bin_to_bcd_sec: entity work.bin_to_bcd
        port map(num_bin => sec_cnt_ext, num_signal => dummy_sign, num_bcd => sec_bcd);

    bin_to_bcd_min: entity work.bin_to_bcd
        port map(num_bin => min_cnt_ext, num_signal => dummy_sign, num_bcd => min_bcd);

    bin_to_bcd_hour: entity work.bin_to_bcd
        port map(num_bin => hour_cnt_ext, num_signal => dummy_sign, num_bcd => hour_bcd);

    bin_to_bcd_day: entity work.bin_to_bcd
        port map(num_bin => day_cnt_ext, num_signal => dummy_sign, num_bcd => day_bcd);

    bin_to_bcd_month: entity work.bin_to_bcd
        port map(num_bin => month_cnt_ext, num_signal => dummy_sign, num_bcd => month_bcd);

    bin_to_bcd_year: entity work.bin_to_bcd
        port map(num_bin => year_cnt_ext, num_signal => dummy_sign, num_bcd => year_bcd);

    -- Conversores BCD para cada dígito de sec, min, hour
    -- Aqui você divide os valores de sec, min e hour em dígitos para exibição
    -- Segundos
    seg0 <= bin_to_bcd(sec(3 downto 0));  -- Unidade dos segundos
    seg1 <= bin_to_bcd(sec(7 downto 4));  -- Dezena dos segundos

    -- Minutos
    seg2 <= bin_to_bcd(min(3 downto 0));  -- Unidade dos minutos
    seg3 <= bin_to_bcd(min(7 downto 4));  -- Dezena dos minutos

    -- Horas
    seg4 <= bin_to_bcd(hour(3 downto 0)); -- Unidade das horas
    seg5 <= bin_to_bcd(hour(7 downto 4)); -- Dezena das horas
    
    -- Atribuição das saídas com conversão final para std_logic_vector
    sec   <= std_logic_vector(sec_bcd(7 downto 0));
    min   <= std_logic_vector(min_bcd(7 downto 0));
    hour  <= std_logic_vector(hour_bcd(7 downto 0));
    day   <= std_logic_vector(day_bcd(7 downto 0));
    month <= std_logic_vector(month_bcd(7 downto 0));
    year  <= std_logic_vector(year_bcd);

end Behavioral;















