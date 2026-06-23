library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_as5600_pwm is
end entity tb_as5600_pwm;

architecture sim of tb_as5600_pwm is

    -- Declaração do Componente
    component as5600_pwm is
        generic(
            MY_CHIPSELECT   : std_logic_vector(1 downto 0) := "10";
            MY_WORD_ADDRESS : unsigned(15 downto 0)        := x"01A0"
        );
        port(
            clk      : in  std_logic;
            rst      : in  std_logic;
            daddress : in  unsigned(31 downto 0);
            ddata_w  : in  std_logic_vector(31 downto 0);
            ddata_r  : out std_logic_vector(31 downto 0);
            d_we     : in  std_logic;
            d_rd     : in  std_logic;
            dcsel    : in  std_logic_vector(1 downto 0); 
            dmask    : in  std_logic_vector(3 downto 0); 
            pwm_in   : in  std_logic
        );
    end component;

    -- Sinais de teste
    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal daddress : unsigned(31 downto 0) := (others => '0');
    signal ddata_w  : std_logic_vector(31 downto 0) := (others => '0');
    signal ddata_r  : std_logic_vector(31 downto 0);
    signal d_we     : std_logic := '0';
    signal d_rd     : std_logic := '0';
    signal dcsel    : std_logic_vector(1 downto 0) := "00";
    signal dmask    : std_logic_vector(3 downto 0) := "0000";
    signal pwm_in   : std_logic := '0';

    -- Período de 1us = 1 MHz (Frequência do clock do barramento da CPU configurado no SoC)
    constant clk_period : time := 1 us; 
    
begin

    -- Instanciação do Dispositivo Sob Teste (DUT)
    DUT: as5600_pwm
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
            pwm_in   => pwm_in
        );

    -- Geração de Clock
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Geração de Reset
    rst_process : process
    begin
        rst <= '1';
        wait for 5 us; -- Reset por 5 ciclos de clock de 1us
        rst <= '0';
        wait;
    end process;

    -- Estímulo do sinal PWM de entrada (Frequência típica padrão do AS5600 = 115 Hz -> Período = 8,696 ms)
    pwm_process : process
    begin
        wait for 10 us; -- Espera o reset
        
        -- Ciclo 1: Período de 8.696 ms, Duty Cycle de 25% (2.174 ms em alto)
        pwm_in <= '1';
        wait for 2.174 ms;
        pwm_in <= '0';
        wait for 6.522 ms;
        
        -- Ciclo 2: Período de 8.696 ms, Duty Cycle de 75% (6.522 ms em alto)
        pwm_in <= '1';
        wait for 6.522 ms;
        pwm_in <= '0';
        wait for 2.174 ms;
        
        -- Mantém em 0 no final
        wait;
    end process;
    
    -- Simulação de Leitura pela CPU (Softcore RISC-V)
    cpu_process : process
    begin
        wait for 10 ms; -- Aguarda o primeiro ciclo de 8.7ms terminar
        
        -- CPU Lê Tempo em Alto (Offset 0 = x01A0)
        dcsel <= "10";
        d_rd <= '1';
        daddress <= x"000001A0";
        wait for 2 * clk_period;
        d_rd <= '0';
        dcsel <= "00";
        
        wait for 100 ns;
        
        -- CPU Lê Período Total (Offset 4 = x01A4)
        dcsel <= "10";
        d_rd <= '1';
        daddress <= x"000001A4";
        wait for 2 * clk_period;
        d_rd <= '0';
        dcsel <= "00";
        
        wait for 10 ms; -- Aguarda o segundo ciclo de PWM terminar
        
        -- CPU Lê Novo Tempo em Alto
        dcsel <= "10";
        d_rd <= '1';
        daddress <= x"000001A0";
        wait for 2 * clk_period;
        d_rd <= '0';
        dcsel <= "00";

        wait;
    end process;

end architecture sim;
