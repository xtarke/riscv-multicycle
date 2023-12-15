--! Use standard library
library ieee;

use ieee.std_logic_1164.all;

use ieee.numeric_std.all;
use work.MorseCode_Package.all;


entity MorseCodeBuzzer is
    Port (
        clk : in std_logic;        -- Clock input
        rst : in std_logic;        -- Reset input
        entrada: in integer;        --entrada do numero/letra/caracter especial
        buzzer : out std_logic;     -- Buzzer output
        ledt : out std_logic;-- led acionado com o tempo T (ponto)
        ledf : out std_logic;-- led acionado com o fim da palavra
        led3t: out std_logic-- led acionado com o tempo 3T (traço)
    );

end MorseCodeBuzzer;

architecture Behavioral of MorseCodeBuzzer is
    constant T: integer :=225;--225 para a placa; para os testbench 10      muda a frequencia de operação
    constant Tbase: integer :=5555;--5555 para a placa; para os testbench 1    muda a frequencia do tom
    signal count_T,count_3T,count_7T, count_within_char, count_between_letters : integer:=0;  -- contadores de cada tempo
    signal count_T_TC, count_3T_TC,count_7T_TC, count_within_char_TC, count_between_letters_TC: std_logic:='0';-- sinal de contagem completa
    signal counter : integer := 0;-- contador da palavra
    signal temp: bit:='1';--qual o bit atual
    signal count_pulse: integer range 0 to Tbase-1 := 0;  -- Contador para a geração da freq do buzzer
    signal tone: std_logic := '0';  -- Sinal de saida do buzzer modulado pela frequencia
    signal morse_code : bit_vector (4 downto 0);-- vetor que é recebido pelo arquivo package (onde entra o número inteiro e sai o vetor de bits)
    type MorseStates is (IDLE, TIME_T, TIME_3T, TIME_7T,NEXT_CARACTER, TIME_WITHIN_LETTER, TIME_BETWEEN_LETTERS);-- maquina de estados
    signal STATE : MorseStates := IDLE;-- estado inicial

begin
    process (clk, rst)
    begin

        if rst = '1' then  -- não esquecer de resetar tudo
            STATE <= IDLE;
            counter <= 0;
            temp<='0';
            morse_code<="00000";
            buzzer <= '1';
            ledt<='0';
            ledf<='0';
            led3t<='0';
        elsif rising_edge(clk) then  -- no limiar de subida do clock

            if count_pulse <= 0 then
                -- Se o contador atingir 0, inverta o sinal do buzzer para gerar a frequencia
                tone <= not tone;
                count_pulse <= Tbase - 1;  -- Reinicia o contador
            else
                count_pulse <= count_pulse - 1;  -- Decrementa o contador
            end if;
            ledt<='0';
            case STATE is
                when IDLE =>
                    if entrada >= 0 and entrada <= 9 then --limitar o numero entre 0 a 9
                        morse_code <= Morse_codes(entrada);-- entra com a entrada na tabela e recebe o vetor de bit
                        temp<= morse_code(counter);-- seleciona o bit em relação ao contador (faz a varredura)
                        ledf<='0';-- desliga o led de quando acaba a palavra
                        if temp = '0' then -- caso seja ponto
                            count_T <=T;    -- o valor de count passa a ser a constante definida anteriormente 
                            STATE<= TIME_T;-- vai para o estado de T
                        elsif temp = '1' then --caso seja traco
                            count_3T <=3*T; -- o valor de count passa a ser a 3*constante definida anteriormente
                            STATE<= TIME_3T;-- vai para o estado de 3T
                        else
                            --  STATE<= IDLE;
                            --morse_code <= Morse_codes(entrada);
                            -- counter<= (morse_code'length)-1;
                            --temp<= morse_code(counter);
                            null;
                        end if;
                    end if;
                when TIME_T =>-- ponto
                    buzzer<=tone;-- saida recebe o tom
                    ledt<='1'; -- led do T acende
                    count_within_char_TC<='0';
                    if count_T=0 then
                        count_T_TC<='1'; -- flag de fim da contagem de T
                    else
                        count_T<=count_T-1;
                    end if;

                    if count_T_TC = '1' then-- caso tenha terminado T
                        count_within_char<=3*T; -- define o contador do intervalo entre bit
                        STATE<= TIME_WITHIN_LETTER; -- vai para o intervalo entre bit
                    end if;

                when TIME_3T =>-- traco
                    buzzer<=tone;
                    led3t<='1';
                    count_within_char_TC<='0';
                    if count_3T=0 then
                        count_3T_TC<='1';
                    else
                        count_3T<=count_3T-1;
                    end if;
                    if count_3T_TC='1' then
                        count_within_char<=3*T;
                        STATE<=TIME_WITHIN_LETTER;
                    end if;

                when TIME_7T => -- intervalo entre palavra
                    buzzer<=tone;
                    if count_7T=0 then
                        count_7T_TC<='1';
                    else
                        count_7T<=count_7T-1;
                    end if;

                    if count_7T_TC='1' then

                        STATE<=IDLE;
                    end if;
                when NEXT_CARACTER =>-- proxima bit
                    counter<= counter+1; -- aumenta o contador da bit
                    temp<=morse_code(counter);-- seleciona o prox bit da bit
                    if counter = 4 then-- como foi feito apenas com numeros e o seu numero max é 5 (lembra do 0)
                        morse_code <= Morse_codes(entrada);
                        temp<= morse_code(counter);
                        counter<= 0;
                        count_between_letters<=3*T;
                        STATE<= TIME_BETWEEN_LETTERS;-- intervalo entre palavras/numeros/fim do caracter atual
                        ledf<='1';
                    else
                        -- recomeça o processo com o proximo bit
                        if temp = '0' then -- caso seja ponto
                            count_T <=T;
                            STATE<= TIME_T;
                        elsif temp = '1' then --caso seja traco
                            count_3T <=3*T;
                            STATE<= TIME_3T;
                        end if;
                    end if;

                when TIME_WITHIN_LETTER =>-- "silencio" entre os bits
                    count_T_TC<='0'; -- reseta a flag do T
                    count_3T_TC<='0'; -- reseta a flag do 3T
                    buzzer<='1'; -- silencia a saida 
                    ledt<='0';
                    led3t<='0';
                    if count_within_char=0 then
                        count_within_char_TC<='1';
                    else
                        count_within_char<=count_within_char-1;
                    end if;

                    if count_within_char_TC = '1' then
                        STATE<= NEXT_CARACTER;-- vai para o proximo bit
                    end if;

                when TIME_BETWEEN_LETTERS =>-- intervalo entre palavras/numeros/fim do caracter atual
                    buzzer<='1';
                    if count_between_letters=0 then
                        count_between_letters_TC<='1';
                    else
                        count_between_letters<=count_between_letters-1;
                    end if;
                    if count_between_letters_TC='1' then
                        STATE<=IDLE;
                    end if;

            end case;
        end if;
    end process;
end Behavioral;


