-- tb_filter.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_filter is
end tb_filter;

architecture Behavioral of tb_filter is
  signal clk             : std_logic := '0';
  signal rst             : std_logic := '0';
  signal led_out          : std_logic;  -- Saída do módulo led_tx (pulsos do LED)
  signal sensor_in       : std_logic := '1';
  signal sensor_filtered : std_logic;
  
  constant clk_p : time := 1 us;  -- Clock de 1 MHz
begin
----------------------------------------------------------------
 
  dut_led: entity work.led_tx
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


----------------------------------------------------------------
  dut_filter: entity work.filter
    generic map(
      THRESHOLD => 10
    )
    port map(
      clk             => clk,
      rst             => rst,
      sensor_in       => sensor_in,
      sensor_filtered => sensor_filtered
    );
  
  ----------------------------------------------------------------
  -- clock de 1 MHz
  ----------------------------------------------------------------
  clk_process: process
  begin
    clk <= '0';
    wait for clk_p/2;
    clk <= '1';
    wait for clk_p/2;
  end process;
  
  ----------------------------------------------------------------
  -- Processo de estímulo para aplicar os casos de Behaviorale
  ----------------------------------------------------------------
  rst_process: process
  begin
    rst <= '1';
    wait for 10 us;
    rst <= '0';
    wait for 10 us;
    -- A partir deste ponto, a simulação segue
    wait;
  end process;
    

  sensor_process: process
  begin
    sensor_in <= '1';
    wait for 20 us;  -- Aguarda antes do primeiro burst simulado

    ----------------------------------------------------------------
    -- Caso 1: sensor_in em '0' por 5 us (abaixo do threshold)
    ----------------------------------------------------------------
    sensor_in <= '0';
    wait for 5 us;
    sensor_in <= '1';
    wait for 95 us;  -- tempo para observar a resposta
    
    ----------------------------------------------------------------
    -- Caso 2: sensor_in em '0' por 25 us (acima do threshold)
    ----------------------------------------------------------------
    sensor_in <= '0';
    wait for 25 us;
    sensor_in <= '1';
    wait for 2 us;
    sensor_in <= '0';
    wait for 13 us;
    sensor_in <= '1';
    wait for 60 us;

    ----------------------------------------------------------------
    -- Caso 3: sensor_in em '0' por 15 us, depois '1' por 5 us, depois '0' por 10 us
    -- O tempo total em 0 não é consecutivo, logo o filtro não deve confirmar o estado baixo.
    ----------------------------------------------------------------
    sensor_in <= '0';
    wait for 15 us;
    sensor_in <= '1';
    wait for 5 us;
    sensor_in <= '0';
    wait for 15 us;
    sensor_in <= '1';
    wait for 65 us;
    
    ----------------------------------------------------------------
    -- Caso 4: sensor_in em '0' por 20 us (ou mais) consecutivos
    -- O filtro deve confirmar a condição e sensor_filtered deverá ser '0'.
    ----------------------------------------------------------------
    sensor_in <= '0';
    wait for 40 us;
    sensor_in <= '1';
    wait for 60 us;

    ----------------------------------------------------------------
    -- Caso 5:
    --
    ----------------------------------------------------------------
    sensor_in <= '0';
    wait for 5 us;
    sensor_in <= '1';
    wait for 6 us;
    sensor_in <= '0';
    wait for 7 us;
    sensor_in <= '1';
    wait for 8 us;
    sensor_in <= '0';
    wait for 9 us;
    sensor_in <= '1';
    
    
    -- Fim dos Behaviorales: aguarda indefinidamente
    wait;
  end process;
  
end Behavioral;
