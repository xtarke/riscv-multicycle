library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity as5600_pwm is
    generic (
        MY_CHIPSELECT : std_logic_vector(1 downto 0) := "10";   -- chip select do modulo
        MY_WORD_ADDRESS : unsigned(15 downto 0) := x"0160";     -- endereco base (slot 22)
        DADDRESS_BUS_SIZE : integer := 32                       -- tamanho do barramento
    );
    port(
        clk      : in std_logic;
        rst      : in std_logic;
        
        -- sinais do barramento do processador
        daddress : in  unsigned(DADDRESS_BUS_SIZE-1 downto 0);
        ddata_w  : in  std_logic_vector(31 downto 0);
        ddata_r  : out std_logic_vector(31 downto 0);
        d_we     : in std_logic;
        d_rd     : in std_logic;
        dcsel    : in std_logic_vector(1 downto 0);
        dmask    : in std_logic_vector(3 downto 0);
        
        -- entradas/saídas do hardware
        pwm_in   : in std_logic
    );
end entity as5600_pwm;

architecture RTL of as5600_pwm is
    signal high_counter   : unsigned(31 downto 0);
    signal period_counter : unsigned(31 downto 0);
    signal t_high_reg     : unsigned(31 downto 0);
    signal t_period_reg   : unsigned(31 downto 0);
    
    -- registradores para sincronizar o sinal pwm e evitar metastabilidade
    signal pwm_sync_1 : std_logic;
    signal pwm_sync_2 : std_logic;
begin

    -- sincroniza o sinal externo de pwm com o clock interno
    process(clk, rst)
    begin
        if rst = '1' then
            pwm_sync_1 <= '0';
            pwm_sync_2 <= '0';
        else
            if rising_edge(clk) then
                pwm_sync_1 <= pwm_in;
                pwm_sync_2 <= pwm_sync_1;
            end if;
        end if;
    end process;

    -- conta o tempo em nível alto e o período total do pwm
    process(clk, rst)
    begin
        if rst = '1' then
            high_counter   <= (others => '0');
            period_counter <= (others => '0');
            t_high_reg     <= (others => '0');
            t_period_reg   <= (others => '0');
        else
            if rising_edge(clk) then
                -- incrementa o contador de período
                period_counter <= period_counter + 1;
                
                -- incrementa o contador alto caso o pwm estiver em 1
                if pwm_sync_2 = '1' then
                    high_counter <= high_counter + 1;
                end if;
                
                -- detecta quando o pwm vai de 0 para 1 (borda de subida)
                if pwm_sync_1 = '1' and pwm_sync_2 = '0' then
                    -- guarda os valores calculados nos registradores
                    t_period_reg <= period_counter;
                    t_high_reg   <= high_counter;
                    
                    -- zera os contadores para o próximo ciclo
                    period_counter <= to_unsigned(1, 32); 
                    high_counter   <= to_unsigned(1, 32);
                end if;
            end if;
        end if;
    end process;

    -- leitura dos dados pelo processador
    process(clk, rst)
    begin
        if rst = '1' then
            ddata_r <= (others => '0');
        else
            if rising_edge(clk) then
                if (d_rd = '1') and (dcsel = MY_CHIPSELECT) then
                    if daddress(15 downto 0) = MY_WORD_ADDRESS then
                        ddata_r <= std_logic_vector(t_high_reg);
                    elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 1) then
                        ddata_r <= std_logic_vector(t_period_reg);
                    end if;
                end if;
            end if;
        end if;
    end process;

end architecture RTL;
