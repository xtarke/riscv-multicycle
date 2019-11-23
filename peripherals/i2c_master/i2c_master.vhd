library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm is
	port(
		clk 	: in  std_logic;
		rst	 	: in  std_logic;
		ena 	: in  std_logic;
		rw  	: in  std_logic;
		addr 	: in  std_logic_vector(6 downto 0);
		data_w 	: in  std_logic_vector(7 downto 0);
		data_r 	: out std_logic_vector(7 downto 0);
		ack_err : out std_logic;
		busy	: out std_logic
	);
end entity fsm;

architecture RTL of fsm is
	type state_type is (ready, start, env_dev_addr, wait_ack_0, env_reg_addr, wait_ack_1, env_data, wait_ack_env, stop); -- faltam ainda os estados para leitura
	signal state : state_type := state0;
begin

	states_change: process(clk, rst) is
		
	begin
		if rst = '1' then
			state <= ready;
		elsif rising_edge(clk) then
			case state is
				when ready =>
					if ena = '1' then
						state <= start;
					end if;
				when start =>
					
					state <= env_dev_addr;
				when env_dev_addr =>
					state <= wait_ack_0;
				when wait_ack_0 =>
				when env_reg_addr =>
				when wait_ack_1 =>
				when env_data =>
				when wait_ack_env =>
				when stop =>
				when others =>
			end case;
		end if;
	end process;

	moore : process(state) is	
	begin
		case state is
			when ready =>
			when start =>
			when env_dev_addr =>
			when wait_ack_0 =>
			when env_reg_addr =>
			when wait_ack_1 =>
			when env_data =>
			when wait_ack_env =>
			when stop =>
			when others =>
		end case;
 
	end process;

	mearly : process(state) is	
	begin
		case state is
			when ready =>
			when start =>
			when env_dev_addr =>
			when wait_ack_0 =>
			when env_reg_addr =>
			when wait_ack_1 =>
			when env_data =>
			when wait_ack_env =>
			when stop =>
			when others =>
		end case;
 
	end process;


end architecture RTL;
