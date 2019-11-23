library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm is
	port(
		clk : in std_logic;
		rst : in std_logic
	);
end entity fsm;

architecture RTL of fsm is
	type state_type is (ready, start, env_dev_addr, wait_ack_0, env_reg_addr, wait_ack_1, env_data, wait_ack_env, stop); -- faltam ainda os estados para leitura
begin

	process(clk, rst) is
		variable state : state_type := state0;
	begin
		if rst = '1' then
			state := state0;
		elsif rising_edge(clk) then
			case state is
				when state0 =>
					state := state1;
				when state1 =>
					state := state2;
				when state2 =>
					state := state0;
			end case;
		end if;
	end process;

end architecture RTL;
