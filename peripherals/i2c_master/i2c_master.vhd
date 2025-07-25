--! @file i2c_master.vhdl
--! @author Emanuel Staub Araldi & ?
--! @brief i2c Master, Implementa protocolo i2c como mestre do canal
--! @date 2025-07-14

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2c_master is
	port(
		sda     : inout std_logic;
		scl     : inout std_logic;
		clk     : in    std_logic;
		clk_32x : in	std_logic; 		-- Dummy clock signal for fast multiplication
		clk_scl : in    std_logic;      -- defasado em 90� -- PLL
		rst     : in    std_logic;
		ena     : in    std_logic;
		rw      : in    std_logic;      -- 0 to write 1 to read
		addr    : in    std_logic_vector(6 downto 0);
		data_wr : in    std_logic_vector(7 downto 0);
		data_rd : out   std_logic_vector(7 downto 0);
		ack_err : out   std_logic       --;
		--		busy    : out   std_logic
	);
end entity i2c_master;

architecture RTL of i2c_master is
	type state_type is (ready, start, Address_RW, slv_ack_cm, Write, Read, slv_ack_2, Master_Ack, stop); -- faltam ainda os estados para leitura
	signal state             : state_type := ready;
	signal scl_state_machine : state_type := ready;
	signal data_tx           : std_logic_vector(7 downto 0);
	signal cnt_sda           : integer    := 7;
	signal cnt_ack 			 : integer;
	signal cnt_stop          : integer := 5;
	signal scl_ena           : std_logic_vector(1 downto 0);
	signal scl_clk_sig		 : std_logic;
	signal ack_received		 : std_logic;
	--signal sda_ena           : std_logic;
	--signal rw_temp           : std_logic;
	signal addr_rw			 : std_logic_vector(7 downto 0);
	signal data_rx : std_logic_vector(7 downto 0);
	signal sda_sig			 : std_logic; -- Armazena '1' ou '0' para sda='Z' ou '0'
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
					state   <= Address_RW;

				when Address_RW =>
					if cnt_sda >= 0 then -- enquanto variavel maior que zero vai enviando o endereco
						
						if cnt_sda = 0 then
							state <= slv_ack_cm;
							cnt_ack <= 1;
						else
							cnt_sda <= cnt_sda - 1;
						end if;
						
					end if;
					
				when slv_ack_cm =>
					-- intervalo onde o mestre libera sda e passa � ouvir
					-- sda � liberado na borda de subida do clock do mestre	
					--sda_ena <= 'Z'		
				
					if cnt_ack = 0 then
						
						cnt_ack <= 2;
						if  ack_received = '1' then 					-- verifica o ack
							if rw = '0' then
								state <= Write;
							else
								state <= Read;
							end if;
							cnt_sda <= 7;
						else
							ack_err <= '1';
							cnt_stop <= 1;
							state <= stop;
						end if;
					else
						cnt_ack <= cnt_ack - 1;
					end if;

				when Write =>
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
				
				when Read =>
					-- Lê dado
					data_rx(cnt_sda) <= sda_sig;
					if cnt_sda = 0 then -- Quando chegar no último bit	
						-- SDA controlado no processo Moore
						cnt_sda <= 7;
						state <= Master_Ack;
					else
						cnt_sda <= cnt_sda - 1;
						state <= Read;			-- Continua lendo
					end if;
				when slv_ack_2 =>

					-- intervalo onde o mestre libera sda e passa � ouvir
					-- sda � liberado na borda de subida do clock do mestre	
					--sda_ena <= 'Z';
					-- na pr�xima borda de subida do clock do slave


					if cnt_ack = 0 then
						
						cnt_ack <= 2;
						if  ack_received = '1' then 				-- verifica o ack
							if ena = '1' then
								state <= Write;
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
				when Master_Ack =>
					if ena = '1' then
						if (addr_rw = addr & rw) then
							state <= Read;
						else
							state <= start;
						end if;
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

--! =========================================================================== !--

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
					addr_rw <= addr & rw;
					data_tx <= addr & rw; -- 7 bits addr device + rw bit
					sda     <= '0';     --start bit
				when Address_RW =>
					if data_tx(cnt_sda) = '0' then
						sda <= '0';
					else
						sda <= 'Z';
					end if;
				when slv_ack_cm =>
					if cnt_ack = 1 then
						sda <= 'Z';
					end if;
					--	rw_temp <= rw;
					data_tx <= data_wr;
				when Write =>
					if data_tx(cnt_sda) = '0' then
						sda <= '0';
					else
						sda <= 'Z';
					end if;
				when Read =>
					if ena = '1' then
						if cnt_sda = 0 then	-- Terminou leitura
							sda <= '0';			-- Send Ack
						else
							sda <= 'Z';
						end if;
					end if;
				when slv_ack_2 =>
					if cnt_ack = 1 then
						sda <= 'Z';
					end if;
					--	rw_temp <= rw;
					data_tx <= data_wr;
				when Master_Ack =>
					if ena = '1' then
						addr_rw <= addr & rw;
						data_rd <= data_rx;
						if (addr_rw = addr & rw) then
							sda <= 'Z';
						end if;
					end if;
				when stop =>
					sda <= 'Z';
					if cnt_stop = 1 then
						sda <= '0';
					end if;
				when others =>
					sda <= 'Z';         --sets sda high impedance
			end case;
		end if;
	end process;

--! =========================================================================== !--

	scl_cntrl : process(clk_scl) is
	begin
		if rising_edge(clk_scl) then
			case scl_state_machine is
				when ready =>
					scl_ena <= "00";    -- Sets scl high impedance
				when start =>
					scl_ena <= "01";    -- Sets scl '0'
				when Address_RW =>
					scl_ena <= "11";	-- Receives from PLL
				when slv_ack_cm =>

					if sda = '0' then
						ack_received <= '1';
					end if;
				
					if cnt_ack = 2	then
						scl_ena <= "01";    -- Sets scl '0'
					end if;
					
				when Write =>
					ack_received <= '0';
					scl_ena <= "11";
				when slv_ack_2 =>
				
					if sda = '0' then
							ack_received <= '1';
					end if;
					
					if cnt_ack = 2	then
						scl_ena <= "01";    -- Sets scl '0'
					end if;
				when Read =>
					scl_ena <= "11";	-- Set scl to PLL
				when Master_Ack =>
					scl_ena <= "01";	-- Set scl to '0'
				when stop =>
					ack_received <= '0';
					scl_ena <= "00";
				when others =>
			end case;
		end if;
	end process;

	get_sda : process(sda)
	begin
		if sda ='Z' then
			sda_sig <= '1';
		else
			sda_sig <= '0';
		end if;
	end process;

	-- quando habilitado scl recebe o clock de uma pll
	
	scl_clk_sig <= '0' when clk_scl ='0' else '1';
	
	with scl_ena select scl <=
						scl_clk_sig when "11",
						'0' when "01",
				 	 	'Z' 	when others;

end architecture RTL;
--teste
