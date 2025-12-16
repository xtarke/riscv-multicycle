
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_arith.all;
	use ieee.std_logic_unsigned.all;

entity pwm_gen is
port
(
	clock	:	in	std_logic;
	pwm_10	:	out	std_logic;
	pwm_30	:	out	std_logic;
	pwm_60	:	out	std_logic;
	pwm_90	:	out	std_logic
);
end pwm_gen;


architecture giovanna of pwm_gen is

	signal	cont	: integer := 0;

begin

	process(clock)
	begin
		if rising_edge(clock) then
			if cont < 99 then
				cont <= cont + 1;
			else
				cont <= 0;
			end if;

			-- geração do PWM de 10% DC.  
			if cont < 10 then
				pwm_10 <= '1';
			else
				pwm_10 <= '0';
			end if;


			-- geração do PWM de 30% DC.   
			if cont < 30 then
				pwm_30 <= '1';
			else
				pwm_30 <= '0';
			end if;

			-- geração do PWM de 60% DC.    
			if cont < 60 then
				pwm_60 <= '1';
			else
				pwm_60 <= '0';
			end if;

			-- geração do PWM de 90% DC. 
			if cont < 90 then
				pwm_90 <= '1';
			else
				pwm_90 <= '0';
			end if;

		end if;
	end process;


end giovanna;

