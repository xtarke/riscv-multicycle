library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm is
	port(
		clk 	: in  std_logic;
		sda	    : inout  std_logic;
		scl		: in  std_logic;
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
	signal state : state_type := ready;
	signal data_tx : std_logic_vector(7 downto 0);
	signal cnt_sda	: integer := 7;
	signal scl_ena : std_logic;
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
					
					cnt_sda<=7;
					data_tx <= addr & rw;
					sda <= '0';
					state <= env_dev_addr;
				
				when env_dev_addr =>
					scl_ena <='1';
					if cnt_sda >= 0 then -- enquanto variavel maior que zero vai enviando o endereco
						if data_tx(cnt_sda)='0' then
							sda<='0';
						else
							sda<='Z';
						end if;
				
						cnt_sda 	<= cnt_sda - 1;

					else
						
						
						if sda='0' then--- se ack ok chama proximo estado
--verificar tempo de resposta do dispositivo
							scl_ena <='0';
							state <= env_reg_addr;
							cnt_sda<=7;
						else
							state <= ready;-- se der erro volta pro inicio
						end if;
					end if;
					
					
					state <= wait_ack_0;
				when wait_ack_0 =>
					
				when env_reg_addr =>
					scl_ena <='1';
					if cnt_sda >= 0 then -- enquanto variavel maior que zero vai enviando o registrador
						if data_r(cnt_sda)='0' then
							sda<='0';
						else
							sda<='Z';
						end if;
				
						cnt_sda 	<= cnt_sda - 1;

					else
						
						
						if sda='0' then--- se ack ok chama proximo estado
--verificar tempo de resposta do dispositivo
							state <= env_data;
							cnt_sda<=7;
							scl_ena <='0';
						else
							state <= ready;-- se der erro volta pro inicio
						end if;
					end if;
					
					
				when wait_ack_1 =>
					
				when env_data =>
					scl_ena <='1';
					if cnt_sda >= 0 then -- enquanto variavel maior que zero vai enviando o registrador
						if data_r(cnt_sda)='0' then
							sda<='0';
						else
							sda<='Z';
						end if;
				
						cnt_sda 	<= cnt_sda - 1;

					else
						
						
						if sda='0' then--- se ack ok chama proximo estado
--verificar tempo de resposta do dispositivo
-- bit de parada
						scl_ena <='0';
						state <= ready;
						sda <= 'Z';
						else
							state <= ready;-- se der erro volta pro inicio
						end if;
					end if;
					
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
				sda <= 'Z';
				
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
