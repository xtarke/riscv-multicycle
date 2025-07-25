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

-- Entidade principal do RTC (Relógio de Tempo Real)
entity rtc is
    Port(
        clk   : in  STD_LOGIC;                     -- Clock do sistema
        rst   : in  STD_LOGIC;                     -- Reset síncrono
        sec   : out STD_LOGIC_VECTOR(7 downto 0);  -- Saída: segundos em BCD
        min   : out STD_LOGIC_VECTOR(7 downto 0);  -- Saída: minutos em BCD
        hour  : out STD_LOGIC_VECTOR(7 downto 0);  -- Saída: horas em BCD
        day   : out STD_LOGIC_VECTOR(7 downto 0);  -- Saída: dia em BCD
        month : out STD_LOGIC_VECTOR(7 downto 0);  -- Saída: mês em BCD
        year  : out STD_LOGIC_VECTOR(15 downto 0)  -- Saída: ano em BCD (2 dígitos por byte)
    );
end rtc;

architecture Behavioral of rtc is

    -- Sinais internos para contadores em binário
    signal sec_cnt   : STD_LOGIC_VECTOR(7 downto 0)  := (others => '0');             -- Contador de segundos (0–59)
    signal min_cnt   : STD_LOGIC_VECTOR(7 downto 0)  := (others => '0');             -- Contador de minutos (0–59)
    signal hour_cnt  : STD_LOGIC_VECTOR(7 downto 0)  := (others => '0');             -- Contador de horas (0–23)
    signal day_cnt   : STD_LOGIC_VECTOR(7 downto 0)  := "00000001";                  -- Contador de dias (1–31)
    signal month_cnt : STD_LOGIC_VECTOR(7 downto 0)  := "00000001";                  -- Contador de meses (1–12)
    signal year_cnt  : STD_LOGIC_VECTOR(15 downto 0) := "0000011111101001";          -- Contador de anos (inicia em 1)

    -- Sinais auxiliares para converter os contadores para 16 bits (entrada do conversor BCD)
    signal sec_cnt_ext, min_cnt_ext, hour_cnt_ext   : STD_LOGIC_VECTOR(15 downto 0);
    signal day_cnt_ext, month_cnt_ext, year_cnt_ext : STD_LOGIC_VECTOR(15 downto 0);

    -- Sinais de saída dos conversores BCD (unsigned)
    signal sec_bcd, min_bcd, hour_bcd     : unsigned(15 downto 0);
    signal day_bcd, month_bcd, year_bcd   : unsigned(15 downto 0);

    -- Sinal de controle de sinal numérico (positivo = '0')
    signal dummy_sign : STD_LOGIC := '0';

begin

    -- Processo de contagem do tempo
    process(clk, rst)
    begin
        if rst = '1' then
            -- Reseta todos os contadores
            sec_cnt   <= (others => '0');
            min_cnt   <= (others => '0');
            hour_cnt  <= (others => '0');
            day_cnt   <= "00000001";       -- Dia começa em 1
            month_cnt <= "00000001";       -- Mês começa em 1
            year_cnt  <= "0000011111101001"; -- Ano começa em 2025

        elsif rising_edge(clk) then
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

    -- Atribuição das saídas com conversão final para std_logic_vector
    sec   <= std_logic_vector(sec_bcd(7 downto 0));
    min   <= std_logic_vector(min_bcd(7 downto 0));
    hour  <= std_logic_vector(hour_bcd(7 downto 0));
    day   <= std_logic_vector(day_bcd(7 downto 0));
    month <= std_logic_vector(month_bcd(7 downto 0));
    year  <= std_logic_vector(year_bcd);

end Behavioral;









