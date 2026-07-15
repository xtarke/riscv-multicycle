library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_rtc2 is
end entity;

architecture sim of tb_rtc2 is

    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';

    signal daddress : unsigned(31 downto 0) := (others => '0');
    signal ddata_w  : std_logic_vector(31 downto 0) := (others => '0');
    signal ddata_r  : std_logic_vector(31 downto 0);
    signal d_we     : std_logic := '0';
    signal d_rd     : std_logic := '0';
    signal dcsel    : std_logic_vector(1 downto 0) := "00";
    signal dmask    : std_logic_vector(3 downto 0) := "1111";

    signal sec_o    : std_logic_vector(5 downto 0);
    signal min_o    : std_logic_vector(5 downto 0);
    signal hour_o   : std_logic_vector(4 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    clk <= not clk after CLK_PERIOD / 2;

    DUT : entity work.rtc2
        generic map (
            MY_CHIPSELECT   => "10",
            MY_WORD_ADDRESS => x"0190",
            CLOCK_HZ        => 10
        )
        port map (
            clk      => clk,
            rst      => rst,
            daddress => daddress,
            ddata_w  => ddata_w,
            ddata_r  => ddata_r,
            d_we     => d_we,
            d_rd     => d_rd,
            dcsel    => dcsel,
            dmask    => dmask,
            sec_o    => sec_o,
            min_o    => min_o,
            hour_o   => hour_o
        );

    process
    begin
        rst <= '1';
        wait for 50 ns;
        rst <= '0';
        wait for 50 ns;

        dcsel <= "10"; --seleciona regiao para acessa perifericos

  
        daddress <= x"00000196"; --registrador controle
        ddata_w  <= x"00000000"; --escreve 0 nesse registrador de controle
        d_we     <= '1'; 

        wait for CLK_PERIOD;
        d_we     <= '0';
        wait for CLK_PERIOD;

        --escreve 37 no registrador de segundos
        daddress <= x"00000190"; --registrador de segundos
        ddata_w  <= x"00000025"; --escreve 37 nesse registrador
        d_we     <= '1';
        wait for CLK_PERIOD;
        d_we     <= '0';
        wait for CLK_PERIOD;

        daddress <= x"00000190";    
        d_rd     <= '1';        --leitura registrador de segundos
        wait for CLK_PERIOD;
        d_rd     <= '0';
        wait for 50 ns;

        daddress <= x"00000196";   --acessa controle do RTC
        ddata_w  <= x"00000001";   --escreve 1 nesse registrador de controle, habilitando o contador do RTC
        d_we     <= '1';
        wait for CLK_PERIOD;
        d_we     <= '0';

        wait for 300 ns;

        wait;
    end process;

end architecture;