library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity led_tx is
  generic(
    TOTAL_CYCLES     : integer := 1000000; -- Período total do modulador em ciclos (1 s com clock de 1 MHz)
    ACTIVE_CYCLES    : integer := 500000;  -- Tempo em que o modulador fica ativo (500 ms)
    IF_HALF_CYCLES : integer := 13       -- Ciclos para metade do período do sinal de 38 kHz (13+13=26 ciclos)
  );
  port(
    clk     : in  std_logic;
    rst     : in  std_logic;
    led_out : out std_logic
  );
end led_tx;

architecture Behavioral of led_tx is
  -- Sinal gerador da portadora de IR (38 kHz aproximadamente)
  constant IR_COUNTER_MAX : integer := IF_HALF_CYCLES - 1;
  signal ir_counter : integer range 0 to IR_COUNTER_MAX := 0;
  signal ir_signal  : std_logic := '0';
  
  -- Contador para o modulador (ativa/desativa a portadora)
  constant MODULATOR_COUNT : integer := TOTAL_CYCLES - 1;
  signal modulator_counter : integer range 0 to MODULATOR_COUNT := 0;
  signal modulator_enable  : std_logic := '0';
  
begin

  -- Processo que gera a portadora de IR (38 kHz aproximadamente)
  process(clk, rst)
  begin
    if rst = '1' then
      ir_counter <= 0;
      ir_signal  <= '0';
    elsif rising_edge(clk) then
      if ir_counter = IR_COUNTER_MAX then
        ir_counter <= 0;
        ir_signal  <= not ir_signal;  -- alterna a cada metade do período
      else
        ir_counter <= ir_counter + 1;
      end if;
    end if;
  end process;
  
  -- Processo que gera o modulador (sinal de “burst” para acionar a portadora)
  process(clk, rst)
  begin
    if rst = '1' then
      modulator_counter <= 0;
      modulator_enable  <= '0';
    elsif rising_edge(clk) then
      if modulator_counter = MODULATOR_COUNT then
        modulator_counter <= 0;
      else
        modulator_counter <= modulator_counter + 1;
      end if;
      
      -- Durante os primeiros ACTIVE_CYCLES ciclos o modulador está ativo (nível '1')
      if modulator_counter < ACTIVE_CYCLES then
        modulator_enable <= '1';
      else
        modulator_enable <= '0';
      end if;
    end if;
  end process;
  
  -- A saída do LED é a portadora (ir_signal) somente quando o modulador está ativo; caso contrário, o LED fica desligado ('0')
  led_out <= ir_signal when modulator_enable = '1' else '0';

end Behavioral;
