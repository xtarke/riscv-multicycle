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
		rw      : in    std_logic;
		addr    : in    std_logic_vector(6 downto 0);
		data_w  : in    std_logic_vector(7 downto 0)--;
--		data_r  : out   std_logic_vector(7 downto 0);
--		ack_err : out   std_logic;
--		busy    : out   std_logic
	);
end entity i2c_master;

architecture RTL of i2c_master is
	type state_type is (ready, start, env_addr_cm, slv_ack_cm, env_data, slv_ack_w, stop); -- faltam ainda os estados para leitura
	signal state   : state_type := ready;
	signal data_tx : std_logic_vector(7 downto 0);
--	signal data_rx : std_logic_vector(7 downto 0);
	signal cnt_sda : integer    := 7;
	signal scl_ena : std_logic;
begin

	states_change : process(clk, rst) is
	begin
		if rst = '1' then
			state 	<= ready;
			
--busy      <= '1';           --indicate not available
--sda_int   <= '1';           --sets sda high impedance
--ack_error <= '0';           --clear acknowledge error flag
--data_rd   <= "00000000";    --clear data read port

		elsif rising_edge(clk) then
			case state is
				when ready =>			
					scl_ena <= '0';   	--sets scl high impedance
					sda		<= 'Z'; 	--sets sda high impedance
			
					if ena = '1' then
						state <= start;
  --busy <= '1';                   --flag busy
					end if;

				when start =>

					cnt_sda <= 7;
					data_tx <= addr & rw;	-- 7 bits addr device + rw bit

--start bit
					sda     <= '0';
				--	scl_ena <= '1';
			
					state   <= env_addr_cm;

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
		sda <= 'Z';
		state <= slv_ack_cm;
	end if;
	
						cnt_sda <= cnt_sda - 1;

						
					end if;

				when slv_ack_cm =>
					
					if sda = '0' then --- se ack ok chama proximo estado
							cnt_sda <= 7;
							
							state   <= env_data;
						else
							state <= ready; -- se der erro volta pro inicio
						end if;
					
				when env_data =>
					scl_ena <= '1';
					if cnt_sda >= 0 then -- enquanto variavel maior que zero vai enviando o registrador
						if data_tx(cnt_sda) = '0' then
							sda <= '0';
						else
							sda <= 'Z';
						end if;

						cnt_sda <= cnt_sda - 1;

						if cnt_sda = 0 then
							sda     <= 'Z';
							state <= slv_ack_w;
						end if;

					end if;

				when slv_ack_w =>
					
					if sda = '0' then --- se ack ok chama proximo estado

						-- bit de parada
						scl_ena <= '0';
						state   <= ready;
						
					else
						state <= ready; -- se der erro volta pro inicio
						
						
						
						
					end if;
					
					
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
			when env_addr_cm =>
			when slv_ack_cm =>
			when env_data =>
			when slv_ack_w =>
			when stop =>
			when others =>
		end case;

	end process;

	-- quando habilitado scl recebe o clock de uma pll
	scl <= '0' WHEN (scl_ena = '1' AND clk_scl = '0') ELSE 'Z';

end architecture RTL;
