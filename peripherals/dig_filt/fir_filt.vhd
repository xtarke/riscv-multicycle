-- fir filt.vhd
-- Created on: march 12, 2022
--     Author: Carolina de Farias
--      Instituto Federal de Santa Catarina
--
-- FIR Filter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_filt is
    generic(
        MY_CHIPSELECT     : std_logic_vector(1 downto 0) := "10";
        MY_WORD_ADDRESS   : unsigned(15 downto 0)        := x"00D0";
        DADDRESS_BUS_SIZE : integer                      := 32; 
        N_coefficients    : integer                      := 4; --! Número de coeficientes do filtro
        N_bits_registers  : integer                      := 32 
    );

    port(
        clk            : in  std_logic;
        rst            : in  std_logic;
        -- Core data bus signals
        -- ToDo: daddress shoud be unsgined
        daddress       : in  unsigned(DADDRESS_BUS_SIZE - 1 downto 0);
        ddata_w        : in  std_logic_vector(31 downto 0);
        ddata_r        : out std_logic_vector(31 downto 0);
        d_we           : in  std_logic;
        d_rd           : in  std_logic;
        dcsel          : in  std_logic_vector(1 downto 0); --! Chip select 
        -- ToDo: Module should mask bytes (Word, half word and byte access)
        dmask          : in  std_logic_vector(3 downto 0); --! Byte enable mask
        -- hardware input/output signals    
        data_in        : in  std_logic_vector(N_bits_registers - 1 downto 0); --! Dado de entrada do filtro.
        data_in_enable : out std_logic; --! Sinal para conferência do enable do hardware.
        data_out       : out signed(2 * N_bits_registers - 1 downto 0)  --! Somente para conferência.
        -- hardware input/output signals    

    );
end entity fir_filt;

architecture RTL of fir_filt is

    type registers is array (N_coefficients - 2 downto 0) of signed(N_bits_registers - 1 downto 0);

    -- Build a 2-D array type for the RAM
    subtype word_t is std_logic_vector(31 downto 0);
    type memory_t is array (0 to 3) of word_t;

    signal reg : registers;

    signal coef : memory_t;   

    signal data_ena : std_logic_vector(31 downto 0);

    signal data_reset : std_logic_vector(31 downto 0);

    signal data_out_c : signed(2 * N_bits_registers - 1 downto 0);

    signal load_coef : std_logic_vector(3 downto 0);

begin
    data_in_enable <= data_ena(0);
    data_ena(0)    <= load_coef(0) and load_coef(1) and load_coef(2) and load_coef(3); --! Habilitação do enable por hardware.
    data_out       <= data_out_c;

    escrita_de_barramento : process(clk, rst)
    begin
        if rst = '1' then
            data_reset <= (others => '0');
            load_coef  <= (others => '0');
        else

            if rising_edge(clk) then
                if (d_we = '1') and (dcsel = MY_CHIPSELECT) then
                    if daddress(15 downto 0) = (MY_WORD_ADDRESS) then
                        coef(0)      <= ddata_w;
                        load_coef(0) <= '1';   --! Utilizado para garantir a habilitação do enable
                    elsif daddress(15 downto 0) = (MY_WORD_ADDRESS) + 1 then 
                        coef(1)      <= ddata_w;
                        load_coef(1) <= '1';
                    elsif daddress(15 downto 0) = (MY_WORD_ADDRESS) + 2 then 
                        coef(2)      <= ddata_w;
                        load_coef(2) <= '1';
                    elsif daddress(15 downto 0) = (MY_WORD_ADDRESS) + 3 then
                        coef(3)      <= ddata_w;
                        load_coef(3) <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;

    FIR_filter : process(clk, rst)
        variable sum, prod : signed(2 * N_bits_registers - 1 downto 0) := (others => '0');
    begin
        if rst = '1' then
            for i in N_coefficients - 2 downto 0 loop  --! Zera os registradores quando o reset é ativado.
                for j in N_bits_registers - 1 downto 0 loop
                    reg(i)(j) <= '0';
                end loop;
            end loop;
        elsif rising_edge(clk) then
            if data_ena(0) = '1' then  --! Se todos os coeficientes tiverem sido carregados, então a entrada será filtrada.
                sum := signed(coef(0)) * signed(data_in);
                for i in 1 to N_coefficients - 1 loop
                    prod := signed(coef(i)) * reg(N_coefficients - 1 - i); 
                    sum  := sum + prod;
                end loop;
                reg <= signed(data_in) & reg(N_coefficients - 2 downto 1);
            end if;
        end if;
        data_out_c <= sum;
    end process;

    leitura_de_barramento : process(clk, rst)
    begin
        if rst = '1' then
            ddata_r <= (others => '0');
        else
            if rising_edge(clk) then
                if (d_rd = '1') and (dcsel = MY_CHIPSELECT) then
                    if daddress(15 downto 0) = MY_WORD_ADDRESS + 4 then
                        ddata_r <= std_logic_vector(data_out_c(63 downto 32)); --!Dados msb 
                    elsif daddress(15 downto 0) = MY_WORD_ADDRESS + 5 then
                        ddata_r <= std_logic_vector(data_out_c(31 downto 0)); --! Dados lsb 
                    end if;
                end if;
            end if;
        end if;
    end process;

end architecture RTL;
