library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2c_master is
	port(
		sda     : inout std_logic;
		scl     : out   std_logic;
		clk     : in    std_logic;
		clk_scl : in    std_logic;      -- defasado em 90º -- PLL
		rst     : in    std_logic;
		ena     : in    std_logic;
		rw      : in    std_logic;      -- 0 to write 1 to read
		addr    : in    std_logic_vector(6 downto 0);
		data_w  : in    std_logic_vector(7 downto 0);
		--		data_r  : out   std_logic_vector(7 downto 0);
		ack_err : out   std_logic       --;
		--		busy    : out   std_logic
	);
end entity i2c_master;

architecture RTL of i2c_master is
	type state_type is (ready, start, env_addr_cm, slv_ack_cm, rw_st, slv_ack_2, stop); -- faltam ainda os estados para leitura
	signal state     : state_type := ready;
	signal state_ant : state_type := ready;
	signal data_tx   : std_logic_vector(7 downto 0);
	signal cnt_sda   : integer    := 7;
	signal cnt_stop  : integer;
	signal scl_ena   : std_logic;
	signal rw_temp   : std_logic;
	--	signal data_rx : std_logic_vector(7 downto 0);
begin

	states_change : process(clk, rst) is
	begin
		if rst = '1' then
			state <= ready;
		--busy      <= '1';           --indicate not available
		--data_rd   <= "00000000";    --clear data read port

		elsif rising_edge(clk) then
			case state is
				when ready =>
					scl_ena <= '0';     --sets scl high impedance
					sda     <= 'Z';     --sets sda high impedance
					ack_err <= '0';     --clear acknowledge error flag

					if ena = '1' then
						state <= start;
						--busy <= '1';                   --flag busy
					end if;

				when start =>

					cnt_sda <= 7;
					data_tx <= addr & rw; -- 7 bits addr device + rw bit

					--start bit
					sda   <= '0';
					state <= env_addr_cm;

				when env_addr_cm =>
					-- verificar se funciona
					-- parte do start bit, scl sendo habilitado um ciclo atrasado
					-- se não funcionar, mudar para ativalo na borda de descida do ciclo anterior
					scl_ena <= '1';
					if cnt_sda >= 0 then -- enquanto variavel maior que zero vai enviando o endereco
						if data_tx(cnt_sda) = '0' then
							sda <= '0';
						else
							sda <= 'Z';
						end if;

						if cnt_sda = 0 then
							state <= slv_ack_cm;
						end if;

						cnt_sda <= cnt_sda - 1;

					end if;
				when slv_ack_cm =>
					-- intervalo onde o mestre libera sda e passa à ouvir
					-- sda é liberado na borda de subida do clock do mestre	
					sda <= 'Z';
					-- na próxima borda de subida do clock do slave

					cnt_sda <= 7;
					rw_temp <= rw;
					data_tx <= data_w;

					state_ant <= state;
					state     <= rw_st;

				when rw_st =>

					-- verifica o ack
					if sda /= '0' and state_ant = slv_ack_cm then --- se não recebe ack retorna p/ ready 
						ack_err <= '1';
						state   <= ready;
					else
						state_ant <= state;
					end if;

					-- escreve o dado
					if rw_temp = '0' then
						if cnt_sda >= 0 then -- enquanto variavel maior que zero vai enviando o registrador
							if data_tx(cnt_sda) = '0' then
								sda <= '0';
							else
								sda <= 'Z';
							end if;

							if cnt_sda = 0 then
								state <= slv_ack_2;
							end if;

							cnt_sda <= cnt_sda - 1;
						end if;

--					elsif rw_temp = '1' then
					end if;


				when slv_ack_2 =>

					-- intervalo onde o mestre libera sda e passa à ouvir
					-- sda é liberado na borda de subida do clock do mestre	
					sda <= 'Z';
					-- na próxima borda de subida do clock do slave

					state_ant <= state;
					
					if ena = '0' then
						cnt_stop <= 1;
						state     <= stop;
			--		elsif rw /= rw_temp then
			--			state     <= start;  -- ainda não preparado para receber um rw diferente, por ca
											 -- por causa da implementação do ack
					else					
						cnt_sda <= 7;
						rw_temp <= rw;
						data_tx <= data_w;
						
						state     <= rw_st;
					end if; 
	
				-- sda pra baixo e desabilita o scl antes de entrar no stop
			when stop =>
				
				if sda /= '0' and state_ant = slv_ack_2 then --- se não recebe ack retorna p/ ready 
						ack_err <= '1';
						state   <= ready;
				else
					
					state   <= stop;
					
					-- bit de parada part 1/2
-- enable muda quando scl está em baixo, isto pode gerar uma borda de subida fora de hr
-- analisar se há consequencias disso
					scl_ena <= '0'; 
					sda <= '0'; -- sda no stop bit precisa ir de baixo para alto
								-- aqui estamos garantindo o a posição do pino após o ack				
				
					-- bit de parada part 2/2
					if cnt_stop = 0 then
						sda <= 'Z'; -- stop bit	
						state   <= ready;
					end if;
				
					cnt_stop <= cnt_stop - 1;
				
				end if;
				
				when others =>
					state <= ready;
			end case;
		end if;
	end process;

	-- quando habilitado scl recebe o clock de uma pll
	scl <= '0' WHEN (scl_ena = '1' AND clk_scl = '0') ELSE 'Z';

end architecture RTL;
