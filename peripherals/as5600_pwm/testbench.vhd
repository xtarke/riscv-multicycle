library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_as5600_pwm is
end entity tb_as5600_pwm;

architecture sim of tb_as5600_pwm is

    -- Declaração do Componente
    component as5600_pwm is
        generic(
            MY_CHIPSELECT     : std_logic_vector(1 downto 0) := "10";
            MY_WORD_ADDRESS   : unsigned(15 downto 0)        := x"0160";
            DADDRESS_BUS_SIZE : integer := 32
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

    -- Período de 1us = 1 MHz (CPU_CLOCK definido no projeto)
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
        wait for 5 us;
        rst <= '0';
        wait;
    end process;

    -- Estímulo do sinal PWM de entrada
    -- Frequência típica do AS5600 PWM = ~115 Hz -> Período ~= 8.696 ms
    -- Frame total = 4351 clocks internos do AS5600
    -- Simulamos dois ângulos diferentes:
    --   Ciclo 1: ~90 graus  -> data = 1024 -> t_high_interno = 128+1024 = 1152
    --            duty = 1152/4351 = 26.5% -> t_high = 0.265 * 8696us = 2304 us
    --   Ciclo 2: ~270 graus -> data = 3072 -> t_high_interno = 128+3072 = 3200
    --            duty = 3200/4351 = 73.5% -> t_high = 0.735 * 8696us = 6392 us
    pwm_process : process
    begin
        wait for 10 us; -- Espera o reset
        
        -- Ciclo 1: ~90 graus
        pwm_in <= '1';
        wait for 2304 us;
        pwm_in <= '0';
        wait for 6392 us;
        
        -- Ciclo 2: ~270 graus
        pwm_in <= '1';
        wait for 6392 us;
        pwm_in <= '0';
        wait for 2304 us;
        
        -- Mantém em 0 no final
        wait;
    end process;
    
    -- Simulação de Leitura pela CPU (Softcore RISC-V)
    -- Endereços de WORD: t_high = x"0160", t_period = x"0161"
    cpu_process : process
    begin
        wait for 10 ms; -- Aguarda o primeiro ciclo PWM terminar
        
        -- CPU Lê t_high (MY_WORD_ADDRESS + 0 = x"0160")
        dcsel <= "10";
        d_rd <= '1';
        daddress <= x"00000160";
        wait for 2 * clk_period;
        d_rd <= '0';
        dcsel <= "00";
        
        wait for 5 us;
        
        -- CPU Lê t_period (MY_WORD_ADDRESS + 1 = x"0161")
        dcsel <= "10";
        d_rd <= '1';
        daddress <= x"00000161";
        wait for 2 * clk_period;
        d_rd <= '0';
        dcsel <= "00";
        
        wait for 10 ms; -- Aguarda o segundo ciclo de PWM terminar
        
        -- CPU Lê novo t_high após mudança de ângulo
        dcsel <= "10";
        d_rd <= '1';
        daddress <= x"00000160";
        wait for 2 * clk_period;
        d_rd <= '0';
        dcsel <= "00";
        
        wait for 5 us;
        
        -- CPU Lê novo t_period
        dcsel <= "10";
        d_rd <= '1';
        daddress <= x"00000161";
        wait for 2 * clk_period;
        d_rd <= '0';
        dcsel <= "00";

        wait;
    end process;

end architecture sim;
