    --------------------------------------------------------------------------------------------------
--! @ Luiz Fernando Assis Sene
--! @testbench
--! @brief 
-------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end entity testbench;

architecture RTL of testbench is
    signal clk       : std_logic;
    signal rst       : std_logic;
    signal daddress : unsigned(31 downto 0);
    signal ddata_r  : std_logic_vector(31 downto 0);
    signal ddata_w  : std_logic_vector(31 downto 0);
    signal dmask    : std_logic_vector(3 downto 0);
    signal dcsel    : std_logic_vector(1 downto 0);
    signal d_we     : std_logic := '0';
    signal d_rd : std_logic;
            
    -- I/O signals
    signal linhas : std_logic_vector(3 downto 0);
    signal colunas : std_logic_vector(3 downto 0);
    --signal tecla : std_logic_vector(3 downto 0);

begin

    keyboard : entity work.key
        generic map(
            MY_CHIPSELECT   => "10",
            MY_WORD_ADDRESS => x"0000"
        )
        port map(
            clk      => clk,
            rst      => rst,
            --daddress => daddress,
            --ddata_w  => ddata_w,
            ddata_r  => ddata_r,
            --d_we     => d_we,
            d_rd     => d_rd,
            dcsel    => dcsel,
            --dmask    => dmask,
            linhas    => linhas,
            colunas   => colunas
            --tecla       => tecla
        );

    clock_driver : process
        constant period : time := 10000 ns;
    begin
        clk <= '0';
        wait for period / 2;
        clk <= '1';
        wait for period / 2;
    end process clock_driver;

    reset : process is
    begin
        rst <= '1';
        wait for 10000 ns;
        rst <= '0';
        wait;
    end process reset;
    
    dcsel <= "10";
    d_rd <= '1' after 10000 ns;
    colunas <= "1111", "0111" after 800000 ns, "1011" after 850000 ns, "1101" after 900000 ns, "1110" after 950000 ns;

end architecture RTL;