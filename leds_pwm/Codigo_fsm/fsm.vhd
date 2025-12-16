
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_arith.all;
	use ieee.std_logic_unsigned.all;

entity fsm is
port
(
	clock		:	in	std_logic;
	reset		:	in	std_logic;
	enable		:	in	std_logic; 	-- habilitado = 1 / desabilitado = 0.
	progr_regr	: 	in 	std_logic;	-- progressao = 0 / regressao = 1.
	leds		: 	out	std_logic_vector(3 downto 0);
	debug		:	out	std_logic
);
end fsm;

architecture giovanna of fsm is

	type estados_da_maquina is (IDLE, A, B, C, D, E);
	
	signal est_atual 	: estados_da_maquina := IDLE;
	signal est_futuro	: estados_da_maquina := IDLE;

	signal clock_1hz	: std_logic := '0';	

	signal pwm_10		: std_logic;
	signal pwm_30		: std_logic;
	signal pwm_60		: std_logic;
	signal pwm_90		: std_logic;

begin


	debug	<= clock_1hz;


	divisor_clock: entity work.divisor_clock
	generic map
	(
		DIVISAO		=> 100_000
	)
	port map

	(
		clock		=> clock,
		clock_div	=> clock_1hz
	);


	pwm_gen: entity work.pwm_gen
	port map
	(
		clock	=> clock,
		pwm_25	=> pwm_10,
		pwm_50	=> pwm_30,
		pwm_60	=> pwm_60,
		pwm_90	=> pwm_90
	);





	dec_saida: process(est_atual, pwm_10, pwm_30, pwm_60, pwm_90)
	begin
		case est_atual is
			when A =>
				leds <= "0000";
			when B =>
				leds <= "000" & pwm_10;
			when C =>
				leds <= "00" & pwm_30 & pwm_10;
			when D => 
				leds <= '0' & pwm_60 & pwm_30 & pwm_10;
			when E => 
				leds <= pwm_90 & pwm_60 & pwm_30 & pwm_10;
			when others =>
				leds <= "0000";

		end case;
	end process dec_saida;



	-- flip flops da FSM.
	process(clock_1hz, reset)
	begin
		if reset = '1' then
			est_atual <= IDLE;
		else
			if rising_edge(clock_1hz) then
				if enable = '1' then
					est_atual <= est_futuro;
				end if;
			end if;
		end if;
	end process;


	-- decodificação do estado futuro.
	process(est_atual, progr_regr)
	begin
		case est_atual is
			when IDLE =>
				est_futuro <= A;
				
			when A =>
				if progr_regr = '1' then
					est_futuro <= E;
				else
					est_futuro <= B;				
				end if;

			when B =>
				if progr_regr = '1' then
					est_futuro <= A;
				else
					est_futuro <= C;				
				end if;

			when C =>
				if progr_regr = '1' then
					est_futuro <= B;
				else
					est_futuro <= D;				
				end if;

			when D =>
				if progr_regr = '1' then
					est_futuro <= C;
				else
					est_futuro <= E;				
				end if;			

			when E =>
				if progr_regr = '1' then
					est_futuro <= D;
				else
					est_futuro <= A;				
				end if;
							
			when others => 
				est_futuro <= IDLE;
		end case;
	
	end process;



end giovanna;
