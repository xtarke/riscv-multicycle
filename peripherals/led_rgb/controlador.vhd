library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controlador is
    port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        start : in STD_LOGIC;
        restart: in STD_LOGIC;
        din : in STD_LOGIC_VECTOR(23 downto 0);
        dout : out STD_LOGIC
    );
end entity controlador;

architecture rtl of controlador is
    type STATE_TYPE is (IDLE, SEND_DATA_HIGH, SEND_DATA_LOW, END_SEND_DATA);
    signal state : STATE_TYPE := IDLE;
    signal counter : INTEGER range 0 to 10000 := 0;
    signal bit_counter : INTEGER range 0 to 24 := 0; -- Contador de bits
    signal shift_reg : STD_LOGIC_VECTOR(23 downto 0); -- Registrador de deslocamento
    signal clock_counter : INTEGER range 0 to 40 := 1; -- Contador de ciclos para gerar pulsos NZR

    -- Constantes para definir o tempo do pulso para o sinal NZR
    constant T0H_TIME : INTEGER := 20;  -- 400ns - 400ns
    constant T0L_TIME : INTEGER := 42;  -- 850ns - 840ns
                                        --          soma = 1240ns

    constant T1H_TIME : INTEGER := 40;  -- 800ns - 700ns
    constant T1L_TIME : INTEGER := 23;  -- 450ns - 540ns
                                        --          soma = 1240ns

begin
    process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            bit_counter <= 0;
            shift_reg <= (others => '0');
            dout <= '0';
            clock_counter <= 1;
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    dout <= '0';
                    clock_counter <= 1;
                    if start = '1' then
                        -- Inicia a transmissão
                        state <= SEND_DATA_HIGH;
                        shift_reg <= din; -- Carrega o dado no registrador de deslocamento
                        bit_counter <= 0;
                    end if;

                when SEND_DATA_HIGH =>
                    if shift_reg(23) = '1' then -- Caso o bit a ser enviado seja 1
                        dout <= '1';
                        if clock_counter >= T1H_TIME then
                            state <= SEND_DATA_LOW;
                            clock_counter <= 1;
                        else
                            clock_counter <= clock_counter + 1;
                        end if;
                    else --Caso o bit a ser enviado seja 0
                        dout <= '1';
                        if clock_counter >= T0H_TIME then
                            state <= SEND_DATA_LOW;
                            clock_counter <= 1;
                        else
                            clock_counter <= clock_counter + 1;
                        end if;
                    end if;

                when SEND_DATA_LOW =>
                    dout <= '0';
                    if shift_reg(23) = '1' then -- Caso o bit a ser enviado seja 1
                        if clock_counter >= T1L_TIME then
                            -- Move para o próximo bit
                            shift_reg <= shift_reg(22 downto 0) & '0'; -- Desloca à esquerda
                            bit_counter <= bit_counter + 1;
                            clock_counter <= 1;
                            if bit_counter = 23 then
                                state <= END_SEND_DATA; -- Volta ao estado IDLE após enviar todos os bits
                                bit_counter <= 0;
                            else
                                state <= SEND_DATA_HIGH;
                            end if;
                        else
                            clock_counter <= clock_counter + 1;
                        end if;
                    else -- Caso o bit a ser enviado seja 0
                        if clock_counter >= T0L_TIME then
                            -- Move para o próximo bit
                            shift_reg <= shift_reg(22 downto 0) & '0'; -- Desloca à esquerda
                            bit_counter <= bit_counter + 1;
                            clock_counter <= 1;
                            if bit_counter = 23 then
                                state <= END_SEND_DATA; -- Volta ao estado IDLE após enviar todos os bits
                                bit_counter <= 0;
                            else
                                state <= SEND_DATA_HIGH;
                            end if;
                        else
                            clock_counter <= clock_counter + 1;
                        end if;
                    end if;
                when END_SEND_DATA =>
                    counter <= counter+1;
                    if counter >= 10000 then
                        state <= IDLE;
                        counter <= 0;
                    end if;
            end case;
        end if;
    end process;
end architecture rtl;
