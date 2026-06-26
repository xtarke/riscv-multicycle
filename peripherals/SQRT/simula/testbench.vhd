-- Sofia Maia Lee e  Ueslei Marian
-- Testbench do periférico raiz
-- Projeto Final - Raiz quadrada com ALTSQRT


-- Bibliotecas padrão
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end entity testbench;

architecture rtl of testbench is

    -- Período do clock
    constant CLK_P : time := 20 ns;

    -- Sinais internos da testbench
    signal clk_tb      : std_logic := '0';
    signal rst_tb      : std_logic := '0';

    -- Barramento do softcore
    signal daddress_tb : unsigned(31 downto 0) := (others => '0');
    signal ddata_w_tb  : std_logic_vector(31 downto 0) := (others => '0');
    signal ddata_r_tb  : std_logic_vector(31 downto 0);
    signal d_we_tb     : std_logic := '0';
    signal d_rd_tb     : std_logic := '0';
    signal dcsel_tb    : std_logic_vector(1 downto 0) := "00";
    signal dmask_tb    : std_logic_vector(3 downto 0) := "1111";
    signal switches_tb : std_logic_vector(9 downto 0) := (others => '0');

begin

    -- Instanciação do periférico raiz
    raiz_inst : entity work.raiz
        generic map (
            MY_CHIPSELECT     => "10",
            MY_WORD_ADDRESS   => x"0010",
            DADDRESS_BUS_SIZE => 32
        )
        port map (
            clk      => clk_tb,
            rst      => rst_tb,

            daddress => daddress_tb,
            ddata_w  => ddata_w_tb,
            ddata_r  => ddata_r_tb,
            d_we     => d_we_tb,
            d_rd     => d_rd_tb,
            dcsel    => dcsel_tb,
            dmask    => dmask_tb,

            switches => switches_tb
        );

    clk_gen : process
    begin
        clk_tb <= '0';
        wait for CLK_P / 2;
        clk_tb <= '1';
        wait for CLK_P / 2;
    end process;

    reset_p : process
    begin
        rst_tb <= '1';
        wait for CLK_P * 2;
        rst_tb <= '0';
        wait;
    end process;

    leitura_p : process
    begin
        -- Estado inicial
        d_rd_tb <= '0';
        d_we_tb <= '0';
        dcsel_tb <= "00";
        daddress_tb <= (others => '0');

        -- Aguarda o reset terminar
        wait for 60 ns;

        -- Teste 1: switches = 9
        -- sqrt(9) = 3
        switches_tb <= std_logic_vector(to_unsigned(9, 10));
        wait for CLK_P * 2;

        -- Lê o resultado da raiz em MY_WORD_ADDRESS + 1
        dcsel_tb <= "10";
        daddress_tb <= x"00000011";
        d_rd_tb <= '1';

        wait for CLK_P;

        d_rd_tb <= '0';

        -- No ModelSim, observar ddata_r_tb = 3
        wait for CLK_P * 3;

        -- Teste 2: switches = 16
        -- sqrt(16) = 4
      
        switches_tb <= std_logic_vector(to_unsigned(16, 10));
        wait for CLK_P * 2;

        daddress_tb <= x"00000011";
        d_rd_tb <= '1';

        wait for CLK_P;

        d_rd_tb <= '0';

        wait for CLK_P * 3;

        -- Teste 3: switches = 100
        -- sqrt(100) = 10
        switches_tb <= std_logic_vector(to_unsigned(100, 10));
        wait for CLK_P * 2;

        daddress_tb <= x"00000011";
        d_rd_tb <= '1';

        wait for CLK_P;

        d_rd_tb <= '0';

        wait for CLK_P * 3;

        -- Teste 4: switches = 1023
        -- sqrt(1023) = 31
        switches_tb <= std_logic_vector(to_unsigned(1023, 10));
        wait for CLK_P * 2;

        daddress_tb <= x"00000011";
        d_rd_tb <= '1';

        wait for CLK_P;

        d_rd_tb <= '0';

        wait for CLK_P * 3;

        -- Teste 5: leitura da entrada
        -- switches = 25
        -- leitura em MY_WORD_ADDRESS + 0 deve retornar 25
        switches_tb <= std_logic_vector(to_unsigned(25, 10));
        wait for CLK_P * 2;

        daddress_tb <= x"00000010";
        d_rd_tb <= '1';

        wait for CLK_P;

        d_rd_tb <= '0';

        wait for CLK_P * 3;

        -- Teste 6: leitura do resto
        -- switches = 10
        -- sqrt(10) = 3, resto = 1
        switches_tb <= std_logic_vector(to_unsigned(10, 10));
        wait for CLK_P * 2;

        daddress_tb <= x"00000012";
        d_rd_tb <= '1';

        wait for CLK_P;

        d_rd_tb <= '0';
        wait;

    end process;

end architecture rtl;