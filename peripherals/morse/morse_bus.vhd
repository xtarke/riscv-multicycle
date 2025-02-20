-- morse_bus

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity morse_bus is
  generic (
    -- chip select
    MY_CHIPSELECT   : std_logic_vector(1 downto 0) := "10"; -- Input/Output generic address space
    MY_WORD_ADDRESS : unsigned(15 downto 0) := x"0140" -- 
  );
  port (
    -- core data bus signals
    daddress : in unsigned(31 downto 0);
    ddata_w  : in  std_logic_vector(31 downto 0);
    ddata_r  : out std_logic_vector(31 downto 0);
    d_we     : in std_logic;
    d_rd     : in std_logic;
    dcsel    : in std_logic_vector(1 downto 0);
    dmask    : in std_logic_vector(3 downto 0);
  
      -- buzzer
    clk : in std_logic;        -- Clock input
    rst : in std_logic;        -- Reset input
    --entrada: in integer;        --entrada do numero/letra/caracter especial
    buzzer : out std_logic;     -- Buzzer output
    ledt : out std_logic;-- led acionado com o tempo T (ponto)
    ledf : out std_logic;-- led acionado com o fim da palavra
    led3t: out std_logic-- led acionado com o tempo 3T (traço)
    );
end morse_bus;



architecture rtl of morse_bus is
	signal entrada : integer;
   
  begin


  MorseCodeBuzzer_inst : entity work.MorseCodeBuzzer
    port map(
      clk     => clk,
      rst     => rst,
      entrada => entrada,
      buzzer  => buzzer,
      ledt    => ledt,
      ledf    => ledf,
      led3t   => led3t
    );
  

  -- insert the values ​​on the core bus
  process (clk, rst)
    begin
    if rst = '1' then
      entrada <= 0;
    else		
      if rising_edge(clk) then
	      -- implementar verificação de fim de caracter para poder escrever caracteres em sequência
			if (d_we = '1') and (dcsel = MY_CHIPSELECT) then
        -- #define MORSE_BASE_ADDRESS (*(_IO32 *) (PERIPH_BASE + 18*16*4))
        -- 20*16 = 320 (decimal) -> 0x0140 (hexadecimal)
				if    daddress(15 downto 0) = (MY_WORD_ADDRESS) then
					entrada <= to_integer(unsigned(ddata_w));
				end if;
			end if;
      end if;
    end if;
  end process;
   
end rtl;
