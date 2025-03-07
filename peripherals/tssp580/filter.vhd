library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity filter is
  generic(
    THRESHOLD : integer := 20  -- Número de ciclos consecutivos necessários para confirmar 0
  );
  port(
    clk             : in  std_logic;
    rst             : in  std_logic;
    sensor_in       : in  std_logic;  -- Entrada do sensor (com ruídos)
    sensor_filtered : out std_logic   -- Saída filtrada
  );
end filter;

architecture Behavioral of filter is
  signal counter : integer := 0;
  signal filtered_state : std_logic := '1'; 
begin
  process(clk, rst)
  begin
    if rst = '1' then
      counter         <= 0;
      sensor_filtered <= '1';  -- Estado normal: sensor inativo = '1'
    elsif rising_edge(clk) then
      if sensor_in /= filtered_state then
      
        if counter < THRESHOLD - 1 then 
          counter <= counter + 1;
        else
          filtered_state <= sensor_in;
          counter <= 0;
        end if;
      else  
        
        counter <= 0;
      end if;
      
      
      sensor_filtered <= filtered_state;
    end if;
  end process;
end Behavioral;
