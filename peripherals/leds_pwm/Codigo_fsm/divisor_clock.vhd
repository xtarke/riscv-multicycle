
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_arith.all;
	use ieee.std_logic_unsigned.all;

entity divisor_clock is
generic
(
	DIVISAO		: integer := 4
);
port 

(
	clock		:	in	std_logic;
	clock_div	:	out	std_logic
);
end divisor_clock;


architecture giovanna of divisor_clock is

	signal	cont	: integer := 0;

begin

	process(clock)
	begin
		if rising_edge(clock) then

			-- definição da frequencia.
			if cont < (DIVISAO - 1) then
				cont <= cont + 1;
			else
				cont <= 0;
			end if;

			-- definição do duty cycle.
			if cont < (DIVISAO / 2) then
				clock_div <= '1';
			else
				clock_div <= '0';
			end if;

		end if;

	end process;



end giovanna;
