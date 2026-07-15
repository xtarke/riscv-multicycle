-------------------------------------------------------
--Componente : Space Vector PWM
--Autor : Eduardo Francisco Pereira
--Data : 16/06/2026
--Versão : 1.0

-------------------------------------------------------

-------------------------------------------------------
--SVPWM - Space Vector Pulse Width Modulation

--Space Vector PWM é uma técnica de modulação utilizada em sistemas de controle de motores elétricos, especialmente em inversores de frequência. 
--ela permite gerar sinais PWM que controlam a tensão aplicada aos motores de forma eficiente, melhorando o desempenho e a eficiência do sistema.

--Passos para implementar o Space Vector PWM:

--parametros do sistema:
--Vbar = 100        # tensão do barramento DC
--f_sw = 10000      # frequencia de comutação (Hz)
--Ts = 1/f_sw       # periodo de comutação (s)

--1- Gerar os Vetores reais: 

--          [S1, S3, VA,    VB,    VAB]
--vetor_0 = [0,   0,  0.0,  0.0,   0.0]
--vetor_1 = [1,   0,  Vbar, 0.0,   Vbar]
--vetor_2 = [0,   1,  0.0,  Vbar, -Vbar]
--vetor_3 = [1,   1,  Vbar, Vbar,  0.0]

--2- Normalizar os Vetores:

--            [S1,  S3, VA,   VB,    VAB]
--vetor_0_n = [0,   0,  0.0,  0.0,   0.0]
--vetor_1_n = [1,   0,  1.0,  0.0,   1.0]
--vetor_2_n = [0,   1,  0.0,  1.0,  -1.0]
--vetor_3_n = [1,   1,  1.0,  1.0,   0.0]

--3- Escolher a tensão media de saída desejada (u_cmd) e normaliza-lo (u_cmd_l)
--u_cmd = +6                             # tensão a ser produzida pelo inversor
--u_cmd_L = u_cmd / Vbar                 # Tensão normalizada

---4- Determinar o setor do vetor ativo a ser utilizado com base no valor de u_cmd_L

-- se u_cmd_L >= 0, então setor = 1 e vetor ativo = vetor_1_n
-- se u_cmd_L < 0, então setor = 2 e vetor ativo = vetor_2_n

-- 5- calcular os tempos de duração dos vetores ativos e nulos com base na tensão normalizada (u_cmd_L) e na frequência de comutação (Ts)

--v1= vec_ativo_n[4]  
--M1 = 1 / v1
--delta_t1 = Ts * M1 * u_cmd_L
--t_nulo_total = Ts - delta_t1

--t_v_at_metade = delta_t1 / 2
--t_v3 = t_nulo_total / 2
--t_v0 = t_v3 / 2 --#Pois aparece dois TV0 logo 2xtv0 = tv3

-- 6- Determinar a sequência de comutação simétrica com base no setor e nos tempos calculados

--if setor == 1:
   -- seq_labels = ["v0", "v1", "v3", "v1", "v0"]
    --seq_vecs = [vetor_0_n, vetor_1_n, vetor_3_n, vetor_1_n, vetor_0_n]
--else:
    --seq_labels = ["v0", "v2", "v3", "v2", "v0"]
    --seq_vecs = [vetor_0_n, vetor_2_n, vetor_3_n, vetor_2_n, vetor_0_n]

--duracoes = [t_v0, t_v_at_metade, t_v3, t_v_at_metade, t_v0]

------------------------------------------:


------------------------------------------
--Como funciona o codigo:



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity space_vector_pwm is
    generic (
        INPUT_CLK_FREQ  : natural := 50000000;  -- 50 MHz
        F_SW            : natural := 10000;     -- 10 kHz
        DEADTIME_CYCLES : natural := 50         -- Tempo morto em ciclos de clock (dt= 1/INPUT_CLK_FREQ * 50 = 1 us)
    );
    port (
        clock   : in std_logic;
        reset   : in std_logic;
        
        -- Sinais de Controle
        v_bar   : in unsigned(15 downto 0) := to_unsigned(100, 16); -- Tensão do barramento DC
        u_cmd   : in signed(15 downto 0)   := to_signed(50, 16);   -- Tensão de saída desejada 
        
        -- Sinais de Hardware (Ponte H)
        gate_s1 : out std_logic;
        gate_s2 : out std_logic;
        gate_s3 : out std_logic;
        gate_s4 : out std_logic
    );
end entity space_vector_pwm;

architecture RTL of space_vector_pwm is

    -- Definição dos Estados da Máquina baseada no fluxograma
    type state_type is (
        ST_CALCULATE,  ST_S2_S4_ON_1, ST_DEADTIME_1,
        ST_S1_S4_ON,   ST_S2_S3_ON_1, ST_DEADTIME_2,
        ST_S1_S3_ON,   ST_DEADTIME_3, ST_S1_S4_ON_2, 
        ST_S2_S3_ON_2, ST_DEADTIME_4, ST_S2_S4_ON_2, 
        ST_DEADTIME_5
    );
    
    signal current_state, next_state : state_type;

    -- Sinais do Timer
    signal timer_count  : natural := 0;
    signal timer_target : natural := 0;
    signal timer_tick   : std_logic := '0';
    signal timer_en     : std_logic := '0';

    -- Registradores de tempo calculados (em ciclos de clock)
    signal t_v0_reg          : natural  := 0;
    signal t_v_at_metade_reg : natural := 0;
    signal t_v3_reg          : natural := 0;
    
    -- Flag de polaridade da tensão
    signal vout_is_positive  : boolean := true;

    -- Constantes de período
    constant TS_CYCLES : natural := INPUT_CLK_FREQ / F_SW;

begin

    -------------------------------------------------------------------
    -- PROCESSO 1: Cálculos dos Tempos
    -------------------------------------------------------------------
    -- Este processo é puramente combinacional/síncrono focado na matemática.
    -- Calcula as durações baseado em u_cmd e v_bar.
    process(clock, reset)
        variable u_cmd_abs : integer;
        variable delta_t1  : integer;
        variable t_nulo    : integer;
    begin
        if reset = '1' then
            t_v0_reg          <= 0;
            t_v_at_metade_reg <= 0;
            t_v3_reg          <= 0;
            vout_is_positive  <= true;
        elsif rising_edge(clock) then
            -- Verifica a polaridade para direcionar a máquina de estados
            if u_cmd >= 0 then
                vout_is_positive <= true;
                u_cmd_abs := to_integer(u_cmd);
            else
                vout_is_positive <= false;
                u_cmd_abs := to_integer(abs(u_cmd));
            end if;

            -- Cálculo simplificado proporcional (pode precisar de IP DSP dependendo da síntese)
            -- delta_t1 = Ts * (u_cmd / Vbar)
            if to_integer(v_bar) /= 0 then
                delta_t1 := (TS_CYCLES * u_cmd_abs) / to_integer(v_bar);
            else
                delta_t1 := 0;
            end if;
            
            t_nulo := TS_CYCLES - delta_t1;

            -- Armazena os tempos calculados nos registradores 
            t_v_at_metade_reg <= delta_t1 / 2;
            t_v3_reg          <= t_nulo / 2;
            t_v0_reg          <= (t_nulo / 2) / 2;
        end if;
    end process;

    -------------------------------------------------------------------
    -- PROCESSO 2: Timer Baseado nos Tempos Calculados
    -------------------------------------------------------------------
    -- Gera a interrupção (timer_tick) quando o tempo do estado atual se esgota.
    process(clock, reset)
    begin
        if reset = '1' then
            timer_count <= 0;
            timer_tick  <= '0';
        elsif rising_edge(clock) then
            if timer_en = '1' then
                if timer_count >= timer_target - 1 then
                    timer_tick  <= '1';
                    timer_count <= 0;
                else
                    timer_tick  <= '0';
                    timer_count <= timer_count + 1;
                end if;
            else
                timer_count <= 0;
                timer_tick  <= '0';
            end if;
        end if;
    end process;

    -------------------------------------------------------------------
    -- PROCESSO 3: Máquina de Estados (FSM)
    -------------------------------------------------------------------
    -- Transição de Estados
    process(clock, reset)
    begin
        if reset = '1' then
            current_state <= ST_CALCULATE;
        elsif rising_edge(clock) then
            current_state <= next_state;
        end if;
    end process;

    -- Lógica Combinacional da Máquina de Estados (Baseada no fluxograma)
    process(current_state, timer_tick, vout_is_positive, t_v0_reg, t_v_at_metade_reg, t_v3_reg)
    begin
        -- Valores Default
        gate_s1 <= '0';
        gate_s2 <= '0';
        gate_s3 <= '0';
        gate_s4 <= '0';
        timer_en <= '1';
        timer_target <= 1;
        next_state <= current_state;

        case current_state is
            
            when ST_CALCULATE =>
                -- Estado inicial para garantir que os cálculos estejam prontos
                timer_en <= '0';
                next_state <= ST_S2_S4_ON_1;
                

            ---------------------------------------------------------------
            -- INÍCIO DA SEQUÊNCIA (Comum aos dois caminhos)
            ---------------------------------------------------------------
            when ST_S2_S4_ON_1 =>
                gate_s2 <= '1'; gate_s4 <= '1';
                timer_target <= t_v0_reg;
                if timer_tick = '1' then
                    next_state <= ST_DEADTIME_1;
                end if;

            when ST_DEADTIME_1 =>
                timer_target <= DEADTIME_CYCLES;
                if timer_tick = '1' then
                    if vout_is_positive then
                        next_state <= ST_S1_S4_ON;    -- VOUT > 0
                    else
                        next_state <= ST_S2_S3_ON_1;  -- VOUT <= 0
                    end if;
                end if;

            ---------------------------------------------------------------
            -- BIFURCAÇÃO: CAMINHO VOUT > 0
            ---------------------------------------------------------------
            when ST_S1_S4_ON =>
                gate_s1 <= '1'; gate_s4 <= '1';
                timer_target <= t_v_at_metade_reg;
                if timer_tick = '1' then next_state <= ST_DEADTIME_2; end if;

            ---------------------------------------------------------------
            -- BIFURCAÇÃO: CAMINHO VOUT <= 0
            ---------------------------------------------------------------
            when ST_S2_S3_ON_1 =>
                gate_s2 <= '1'; gate_s3 <= '1';
                timer_target <= t_v_at_metade_reg;
                if timer_tick = '1' then next_state <= ST_DEADTIME_2; end if;

            ---------------------------------------------------------------
            -- MEIO DA SEQUÊNCIA (Comum)
            ---------------------------------------------------------------
            when ST_DEADTIME_2 =>
                timer_target <= DEADTIME_CYCLES;
                if timer_tick = '1' then next_state <= ST_S1_S3_ON; end if;

            when ST_S1_S3_ON =>
                gate_s1 <= '1'; gate_s3 <= '1';
                timer_target <= t_v3_reg;
                if timer_tick = '1' then next_state <= ST_DEADTIME_3; end if;

            when ST_DEADTIME_3 =>
                timer_target <= DEADTIME_CYCLES;
                if timer_tick = '1' then
                    if vout_is_positive then
                        next_state <= ST_S1_S4_ON_2;
                    else
                        next_state <= ST_S2_S3_ON_2;
                    end if;
                end if;

            ---------------------------------------------------------------
            -- RETORNO DO VETOR: CAMINHO VOUT > 0
            ---------------------------------------------------------------
            when ST_S1_S4_ON_2 =>
                gate_s1 <= '1'; gate_s4 <= '1';
                timer_target <= t_v_at_metade_reg;
                if timer_tick = '1' then next_state <= ST_DEADTIME_4; end if;

            ---------------------------------------------------------------
            -- RETORNO DO VETOR: CAMINHO VOUT <= 0
            ---------------------------------------------------------------
            when ST_S2_S3_ON_2 =>
                gate_s2 <= '1'; gate_s3 <= '1';
                timer_target <= t_v_at_metade_reg;
                if timer_tick = '1' then next_state <= ST_DEADTIME_4; end if;

            ---------------------------------------------------------------
            -- FIM DA SEQUÊNCIA (Comum)
            ---------------------------------------------------------------
            when ST_DEADTIME_4 =>
                timer_target <= DEADTIME_CYCLES;
                if timer_tick = '1' then next_state <= ST_S2_S4_ON_2; end if;

            when ST_S2_S4_ON_2 =>
                gate_s2 <= '1'; gate_s4 <= '1';
                timer_target <= t_v0_reg;
                if timer_tick = '1' then next_state <= ST_DEADTIME_5; end if;

            when ST_DEADTIME_5 =>
                timer_target <= DEADTIME_CYCLES;
                if timer_tick = '1' then 
                    next_state <= ST_S2_S4_ON_1; -- Retorna ao início do ciclo
                end if;

        end case;
    end process;

end architecture RTL;