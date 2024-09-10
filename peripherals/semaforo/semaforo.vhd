-------------------------------------------------------------------
-- Name        : semaforo.vhd
-- Author      : Elvis Fernandes
-- Version     : 0.1
-- Copyright   : Departamento de Eletrônica, Florianópolis, IFSC
-- Description : Projeto Final: Semáforo
-- Date        : 30/08/2024
-------------------------------------------------------------------
--Esta tarefa envolve a criação de um semáforo em VHDL baseada em máquina de estados com os seguintes objetivos:
--Controle dos estados luzes de um semáforo (Red, Yellow e Green);
--Contagem do número de pedestres (apenas no estado Red);
--Contagem do número de carros (apenas nos estados Yellow e Green);
--Exibição das luzes do semáforo, da contagem dos pedestres e carros, do tempo de cada semáforo
-------------------------------------------------------------------
--Pinos de entrada
--clk: sinal de clock.
--rst: sinal de reset.
--start: sinal que sinaliza o início do semáforo. O semáforo é iniciado quando start é nível alto.
--pedestre: sinal que sinaliza o início da contagem de pedestres. O início da contagem é iniciado quando pedestre é nível alto. Se for nível baixo a contagem não deve ser iniciado/contabilizada.
--carro: sinal que sinaliza o início da contagem de carros. O início da contagem é iniciado quando pedestre é nível alto. Se for nível baixo a contagem não deve ser iniciado/contabilizada.
-------------------------------------------------------------------
--Pinos de saída
--r1: sinal que sinaliza o estado red do semáforo
--y1: sinal que sinaliza o estado yellow do semáforo
--g1: sinal que sinaliza o estado green do semáforo
--ped_count: dado de 8 bits que sinaliza a contagem de pedestres
--car_count: dado de 8 bits que sinaliza a contagem de carros
--time_display: dado de 8 bits que sinaliza o tempo do semáforo. A contagem vai de F até 0
--visual_display: dado de 8 bits que sinaliza os segmentos de tempo de cada semáforo. Para cada número do tempo de semáforo é apagado um segmento do display. Deve ter 1 display para  o tempo de F até 9, e um display de 8 até 0.
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY semaforo IS
    PORT(
        clk              : IN  std_logic;  -- Sinal de clock
        rst              : IN  std_logic;  -- Sinal de reset
        start            : IN  std_logic;  -- 
        pedestre         : IN  std_logic;  -- Chave para contagem de pedestres
        carro            : IN  std_logic;  -- Chave para contagem de carros
        r1               : OUT std_logic;  -- Sinal vermelho do semáforo
        y1               : OUT std_logic;  -- Sinal amarelo do semáforo
        g1               : OUT std_logic;  -- Sinal verde do semáforo
        ped_count        : OUT UNSIGNED(7 DOWNTO 0); -- Display para contagem de pedestres
        car_count        : OUT UNSIGNED(7 DOWNTO 0); -- Display para contagem de carros
        time_display     : OUT UNSIGNED(7 DOWNTO 0); -- Display para tempo de cada estado
        visual_display   : OUT UNSIGNED(7 DOWNTO 0)  -- Display para visualizar os segmentos do tempo de cada estado
    );
END ENTITY semaforo;

ARCHITECTURE state_machine OF semaforo IS

    TYPE state IS (STARTT, IDLE, RED, YELLOW, GREEN);
    SIGNAL pr_state, nx_state : state;
    SIGNAL count              : UNSIGNED(7 DOWNTO 0);
    SIGNAL count_limit        : UNSIGNED(7 DOWNTO 0);
    SIGNAL ped_count_sig, car_count_sig : UNSIGNED(7 DOWNTO 0);

BEGIN

    -- Processo de transição de estados e contagem
    PROCESS(rst, clk)
    BEGIN
	
        IF rst = '1' THEN
            pr_state <= STARTT;
            count    <= (others => '0');
            ped_count_sig <= (others => '0');
            car_count_sig <= (others => '0');
           
			
        ELSIF rising_edge(clk) THEN
		
            IF count > 0 THEN
                IF start = '1' THEN
                    count <= count - 1;
                ELSE
                    count <= count;
                END IF;
            ELSE
                IF start = '1' THEN
                    pr_state <= nx_state;
                END IF;
                count <= count_limit;
            END IF;

            IF start = '1' THEN
                -- Contagem de pedestres apenas no estado RED
                IF pr_state = RED AND pedestre = '1' THEN
                    ped_count_sig <= ped_count_sig + 1;
                    car_count_sig <= (others => '0');
                END IF;

                -- Contagem de carros apenas nos estados YELLOW e GREEN
                IF (pr_state = YELLOW OR pr_state = GREEN) AND carro = '1' THEN
                    car_count_sig <= car_count_sig + 1;
                    ped_count_sig <= (others => '0');
                END IF;
            ELSE
                ped_count_sig <= ped_count_sig;
                car_count_sig <= car_count_sig;
            END IF;
        END IF;
    END PROCESS;

    -- Lógica de transição de estado, contagem de pedestres e carros
    PROCESS(pr_state, start, pedestre, carro)
    BEGIN
        CASE pr_state IS
			
			--Estado STARTT criado com valor 0, para que ele vá para o estado IDLE imediatamente, garantindo com que o estado RED assuma o valor do estado IDLE
            WHEN STARTT =>
                count_limit <= "00000000";  -- Exemplo: 0 ciclos de clock para o estado STARTT
                IF start = '1' THEN
                    nx_state <= IDLE;
                ELSE
                    nx_state <= STARTT;
                END IF;
            
			--Estado IDLE para garantir a contagem total do estado RED.
			--Sem o estado IDLE, o estado RED estava utilizando a mesma contagem de tempo IDLE
            WHEN IDLE =>
                count_limit <= "00001111";  -- Exemplo: 15 ciclos de clock para garantir o tempo do estado RED
                IF start = '1' THEN
                    nx_state <= RED;
                ELSE
                    nx_state <= IDLE;
                END IF;

            WHEN RED =>
                count_limit <= "00001111";  -- Exemplo: 15 ciclos de clock para o estado RED
                IF start = '1' THEN
                    nx_state <= YELLOW;
                ELSE
                    nx_state <= RED;
                END IF;

            WHEN YELLOW =>
                count_limit <= "00001111";  -- Exemplo: 15 ciclos de clock para o estado YELLOW
                IF start = '1' THEN
                    nx_state <= GREEN;
                ELSE
                    nx_state <= YELLOW;
                END IF;

            WHEN GREEN =>
                count_limit <= "00001111";  -- Exemplo: 15 ciclos de clock para o estado GREEN
                IF start = '1' THEN
                    nx_state <= RED;
                ELSE
                    nx_state <= GREEN;
                END IF;
        END CASE;
    END PROCESS;

    ped_count <= ped_count_sig;
    car_count <= car_count_sig;
    time_display <= count;  -- Display mostra o tempo restante do estado atual
    

    -- Controle das luzes do semáforo baseado no estado atual
    PROCESS(pr_state)
    BEGIN
        CASE pr_state IS
            WHEN STARTT =>
                r1 <= '0';
                y1 <= '0';
                g1 <= '0';
            WHEN IDLE =>
                r1 <= '1';
                y1 <= '1';
                g1 <= '1';
            WHEN RED =>
                r1 <= '1';
                y1 <= '0';
                g1 <= '0';
            WHEN YELLOW =>
                r1 <= '0';
                y1 <= '1';
                g1 <= '0';
            WHEN GREEN =>
                r1 <= '0';
                y1 <= '0';
                g1 <= '1';
        END CASE;
    END PROCESS;

END ARCHITECTURE state_machine;
