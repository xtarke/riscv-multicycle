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
	signal state             : state_type := ready;
	signal scl_state_machine : state_type := ready;
	signal data_tx           : std_logic_vector(7 downto 0);
	signal cnt_sda           : integer    := 7;
	signal cnt_ack 			 : integer;
	signal cnt_stop          : integer;
	signal scl_ena           : std_logic_vector(1 downto 0);
	signal sda_ena           : std_logic;
	signal rw_temp           : std_logic;
	--	signal data_rx : std_logic_vector(7 downto 0);
begin

	states_change : process(clk, rst) is
	begin
		if rst = '1' then
			state <= ready;

		elsif rising_edge(clk) then
			scl_state_machine <= state; -- maquina de estados baseada no rising edge de s

			case state is
				when ready =>
					if ena = '1' then
						state <= start;
						ack_err <= '0';     --clear acknowledge error flag		
						--busy <= '1';                   --flag busy
					end if;

				when start =>
					cnt_sda <= 7;
					state   <= env_addr_cm;

				when env_addr_cm =>
					if cnt_sda >= 0 then -- enquanto variavel maior que zero vai enviando o endereco
						
						if cnt_sda = 0 then
							state <= slv_ack_cm;
							cnt_ack <= 1;
						else
							cnt_sda <= cnt_sda - 1;
						end if;
						
					end if;
					
				when slv_ack_cm =>
					-- intervalo onde o mestre libera sda e passa à ouvir
					-- sda é liberado na borda de subida do clock do mestre	
					--sda_ena <= 'Z'		
				
					if cnt_ack = 0 then
						
						cnt_ack <= 2;
						if  sda = '0' then 					-- verifica o ack
							state <= rw_st;		-- futuramente: if rw = 0 vai p/ escrita = 1 vai para leitura
							cnt_sda <= 7;
						else
							ack_err <= '1';
							state <= stop;
						end if;
					else
						cnt_ack <= cnt_ack - 1;
					end if;

				when rw_st =>

					-- escreve o dado
				--	if rw_temp = '0' then--					elsif rw_temp = '1' then
					if cnt_sda >= 0 then -- enquanto variavel maior que zero vai enviando o registrador		
						
						
						if cnt_sda = 0 then
							state <= slv_ack_2;
							cnt_ack <= 1;
						else
							cnt_sda <= cnt_sda - 1;
						end if;

					end if;

				when slv_ack_2 =>

					-- intervalo onde o mestre libera sda e passa à ouvir
					-- sda é liberado na borda de subida do clock do mestre	
					--sda_ena <= 'Z';
					-- na próxima borda de subida do clock do slave


					if cnt_ack = 0 then
						if  sda = '0' then 					-- verifica o ack
							if ena = '1' then
								state <= rw_st;		-- futuramente: if rw = 0 vai p/ escrita = 1 vai para leitura
								cnt_sda <= 7;
							else
								state <= stop;
								cnt_stop <= 1;
							end if;
						else
							ack_err <= '1';
							state <= stop;
							cnt_stop <= 1;
						end if;
					else
						cnt_ack <= cnt_ack - 1;
					end if;

				when stop =>
-- sda pra baixo e desabilita o scl antes de entrar no stop
					if cnt_stop = 0 then	
						state   <= ready;
					else
						cnt_stop <= cnt_stop - 1;
					end if;


				when others =>
					state <= ready;
			end case;
		end if;
	end process;

	moore : process(clk) is
	begin
		if rising_edge(clk) then
			case state is
			when ready =>
--scl_ena <= "00";    --sets scl high impedance
					sda <= 'Z';         --sets sda high impedance					
					--busy    <= '1';           --indicate not available
					--data_rd <= "00000000";    --clear data read port

				when start =>

					data_tx <= addr & rw; -- 7 bits addr device + rw bit
					sda     <= '0';     --start bit

				when env_addr_cm =>
					

					if data_tx(cnt_sda) = '0' then
						sda <= '0';
					else
						sda <= 'Z';
					end if;
				when slv_ack_cm =>
					if cnt_ack = 1 then
						sda <= 'Z';
					end if;
					rw_temp <= rw;
					data_tx <= data_w;
				when rw_st =>
					if data_tx(cnt_sda) = '0' then
						sda_ena <= '0';
					else
						sda_ena <= 'Z';
					end if;
				when slv_ack_2 =>
					if cnt_ack = 1 then
						sda_ena <= 'Z';
					end if;
				when stop =>
				when others =>
					sda <= 'Z';         --sets sda high impedance
			end case;
		end if;
	end process;

	scl_cntrl : process(clk_scl) is
	begin
		if rising_edge(clk_scl) then
			case scl_state_machine is
				when ready =>
					scl_ena <= "00";    --sets scl high impedance

				when start =>
					scl_ena <= "01";    --sets scl zero
				when env_addr_cm =>
					-- verificar se funciona
					-- parte do start bit, scl sendo habilitado um ciclo atrasado
					-- se não funcionar, mudar para ativalo na borda de descida do ciclo anterior
					scl_ena <= "11";
				when slv_ack_cm =>
					if cnt_ack = 2	then
						scl_ena <= "01";    --sets scl zero
					end if;
				when rw_st =>
					scl_ena <= "11";
				when slv_ack_2 =>
				when stop =>
					scl_ena <= "11";
				when others =>

			end case;
		end if;
	end process;

	-- quando habilitado scl recebe o clock de uma pll
	with scl_ena select scl <=
					clk_scl when "11",
						'0' when "01",
				 	 	'Z' 	when others;

end architecture RTL;
