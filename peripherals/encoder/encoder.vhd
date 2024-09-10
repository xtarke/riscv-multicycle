library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity encoder is
    port (
        clk         : in  std_logic;                     
        aclr_n      : in  std_logic;                     
        select_time : in  std_logic_vector(2 downto 0);          
        encoder_pulse : in std_logic;                    
        frequency   : out unsigned(31 downto 0)          
    );
end entity encoder;

architecture rtl of encoder is
    signal pulse_count  : unsigned(21 downto 0) := (others => '0');
    signal time_period  : unsigned(31 downto 0);
    signal multiplicador: unsigned(9 downto 0):= (others => '0');
    signal time_counter : unsigned(31 downto 0) := (others => '0');
    signal flag         : std_logic := '0';  -- Sinal para reiniciar pulse_count

begin


    process(select_time)
    begin
        case select_time is
            when "000" => time_period <= to_unsigned(50000, 32);-- 1ms (assumindo clock de 50 MHz)
               multiplicador <= to_unsigned(1000, 10);
           when "001" => time_period <= to_unsigned(500000, 32);  -- 10ms
               multiplicador <= to_unsigned(100, 10);
           when "010" => time_period <= to_unsigned(5000000, 32); -- 100ms
               multiplicador <= to_unsigned(10, 10);
           when "011" => time_period <= to_unsigned(50000000, 32); -- 1000ms
               multiplicador <= to_unsigned(1, 10);
           when others => time_period <= to_unsigned(50000, 32); -- Default para 1ms
           multiplicador <= to_unsigned(1000, 10);
        end case;
    end process;

    -- Contagem dos pulsos do clock
    process(aclr_n, clk)
    begin
        if aclr_n = '0' then
            time_counter <= (others => '0');
            frequency <= (others => '0');
        elsif flag = '1' then
          flag <= '0';
        elsif rising_edge(clk) then
            if time_counter < time_period then
                time_counter <= time_counter + 1;
            else
                time_counter <= (others => '0');
                frequency <= pulse_count*multiplicador;  -- Frequência em pulsos por período (Hz)
                flag <= '1';  -- Garante que o flag seja resetado no início
            end if;
        end if;
    end process;

    -- Contagem dos pulsos do encoder
    process(aclr_n, encoder_pulse,flag)
        variable q_var : unsigned(21 downto 0) := (others => '0');
    begin
        if aclr_n = '0' then
          q_var := (others => '0');
        elsif flag = '1' then
          q_var := (others => '0');
        elsif rising_edge(encoder_pulse) then
            q_var := q_var + 1;
        end if;
        pulse_count <= q_var;
    end process;

end architecture rtl;
