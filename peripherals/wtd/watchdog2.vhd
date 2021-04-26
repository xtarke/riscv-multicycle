library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity watchdog2 is
	generic(
		prescaler_size : integer := 16;
		WTD_BASE_ADDRESS : unsigned(15 downto 0)	:= x"0090"
	);
	port(
		clock       : in  std_logic;
		reset       : in  std_logic;
		
		wtd_reset 	: in  std_logic;
		wtd_mode  	: in  unsigned(1 downto 0);
		prescaler   : in  unsigned(prescaler_size - 1 downto 0);
		top_counter : in  unsigned(prescaler_size - 1 downto 0);
		
		wtd_clear			: in  std_logic;	-- Enviado pelo core para indicar que já pode desativar a contagem, não precisa de reset
		wtd_interrupt_clr 	: in  std_logic;	-- Serve pra interrupção limpar a flag de IRQ, "wtd_collapse"
		wtd_hold			: in  std_logic;	-- Segura a contagem do clock interno no processo P1
		wtd_interrupt		: out std_logic;	-- Sinal do WTD de que a contagem estourou
		wtd_out				: out std_logic		-- Deve ser ligado ao reset do sistema, utilizado no estouro do WTD
		
	);
end entity watchdog2;

architecture RTL of watchdog2 is
	signal counter					: unsigned(prescaler_size - 1 downto 0) := (others => '0');
	signal internal_clock			: std_logic := '1';
	
begin

	p1 : process(clock, reset) is       -- @suppress "Incomplete sensitivity list. Missing signals: internal_clock, prescaler"
		variable temp_counter : unsigned(prescaler_size - 1 downto 0) := (others => '0');
	begin
		if reset = '0' then
			if wtd_hold  = '0' then
				if prescaler = x"0001" then
					internal_clock <= clock;
				elsif rising_edge(clock) then
					temp_counter := temp_counter + 1;
					if temp_counter >= prescaler - 1 then
						internal_clock <= not (internal_clock);
						temp_counter   := (others => '0');
					end if;
				end if;
			end if;						
		else
			temp_counter := (others => '0');
		end if;
	end process p1;

	p2 : process(internal_clock, reset) is
		
		-- Variáveis internas do processo do WATCHDOG
		variable internal_wtd_interrupt	: std_logic	:= '0';
		variable internal_wtd_out		: std_logic	:= '0';
		
	begin
		if reset = '0' then

			if rising_edge(internal_clock) then
				if wtd_reset = '1' then
					
					internal_wtd_interrupt	:= '0';
					internal_wtd_out		:= '0';
					counter           		<= (others => '0');
					
				else
					
					case wtd_mode is
						
						when "01" =>    -- One-Shot Mode
						
							if counter >= top_counter-1 then
								
								-- Já travou, reseta!
								internal_wtd_interrupt := '1';
								internal_wtd_out := '1';
						
							else
								
								-- Ainda não travou, continua!
								counter <= counter + 1;
								
							end if;
						
						when others =>  -- none / error
							internal_wtd_interrupt	:= '0';
							internal_wtd_out		:= '0';
							counter           		<= (others => '0');
					end case;
					
					if wtd_interrupt_clr = '1' then 
						internal_wtd_out 		:= '0';
						internal_wtd_interrupt	:= '0';
					end if;	
					
				end if;
			end if;
			wtd_interrupt 	<= internal_wtd_interrupt;
			wtd_out 		<= internal_wtd_out;
		else
			internal_wtd_interrupt	:= '0';
			internal_wtd_out		:= '0';
			
			wtd_interrupt 	<= internal_wtd_interrupt;
			wtd_out 		<= internal_wtd_out;
		end if;

	end process p2;

end architecture RTL;