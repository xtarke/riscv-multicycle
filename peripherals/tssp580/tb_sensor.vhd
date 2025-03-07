library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_sensor is
end tb_sensor;

architecture Behavioral of tb_sensor is
  -- Sinais para simulação
  signal clk        : std_logic := '0';
  signal rst        : std_logic := '0';
  signal led_out    : std_logic;  -- Saída do módulo led_tx (pulsos de 38 kHz durante o burst)
  signal sensor_out : std_logic := '1';  -- Saída simulada do sensor (normalmente '1')
  signal sensor_out_unit : std_logic := '1';  -- Saída simulada do sensor (normalmente '1')
  
  -- Constante: clock de 1 MHz (período de 1 µs)
  constant clk_p : time := 1 us;
  
begin

  -- Instância do DUT (led_tx) com parâmetros reduzidos para simulação:
  -- TOTAL_CYCLES = 100 µs; ACTIVE_CYCLES = 50 µs; IF_HALF_CYCLES = 5 (resultando em 100 kHz de portadora)
  dut: entity work.led_tx
    generic map(
      TOTAL_CYCLES     => 100,  -- Período total de 100 µs
      ACTIVE_CYCLES    => 50,   -- Burst ativo durante 50 µs
      IF_HALF_CYCLES => 5     -- Gera uma portadora com período de 10 µs (100 kHz)
    )
    port map(
      clk     => clk,
      rst     => rst,
      led_out => led_out
    );

  -- Geração do clock de 1 MHz
  clk_process: process
  begin
    clk <= '0';
    wait for clk_p/2;
    clk <= '1';
    wait for clk_p/2;
  end process;

  -- Processo de estímulo para o reset
  rst_process: process
  begin
    rst <= '1';
    wait for 20 us;
    rst <= '0';
    wait;
  end process;

  -- Processo de estímulo para o sensor
  sensor_process: process
  begin
    sensor_out <= '1';
    wait for 30 us;   
    loop
      sensor_out <= '0';
      wait for 40 us;   
      sensor_out <= '1';
      wait for 60 us;
    end loop;
  end process;

  -- Processo de estímulo para o sensor
  sensor_process_unit: process
  begin
    sensor_out_unit <= '1';
    wait for 130 us;   
    loop
      sensor_out_unit <= '0';
      wait for 40 us;   
      sensor_out_unit <= '1';
      wait;
    end loop;
  end process;
  
end Behavioral;
