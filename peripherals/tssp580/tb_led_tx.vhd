library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_led_tx is
end tb_led_tx;

architecture Behavioral of tb_led_tx is
  signal clk     : std_logic := '0';
  signal rst     : std_logic := '0';
  signal led_out : std_logic;
  
  constant clk_p : time := 1 us;  -- clock de 1 MHz (1 us de período)
  
begin

  -- Instancia o DUT (Device Under Behavioral) com parâmetros reduzidos para simulação
  dut: entity work.led_tx
    generic map(
      TOTAL_CYCLES     => 100, -- período total de 100 ciclos (100 µs)
      ACTIVE_CYCLES    => 50,  -- 50% ativo (50 µs ligado, 50 µs desligado)
      IF_HALF_CYCLES => 5    -- gera uma portadora com período de 10 ciclos (100 kHz)
    )
    port map(
      clk     => clk,
      rst     => rst,
      led_out => led_out
    );

  -- Geração do clock
  clk_process: process
  begin
    clk <= '0';
    wait for clk_p/2;
    clk <= '1';
    wait for clk_p/2;
  end process;
  
  -- Processo de estímulo
  rst_process: process
  begin
    -- Aplica reset
    rst <= '1';
    wait for 20 us;
    rst <= '0';
    
    -- Aguarda tempo suficiente para observar alguns ciclos da modulação
    wait for 500 us;
    
    -- Encerra a simulação
  end process;

end Behavioral;
