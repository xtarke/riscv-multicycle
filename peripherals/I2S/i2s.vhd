-------------------------------------------------------------------
-- Name        : i2s.vhd
-- Author      : Emmanuel Reitz Guesser
-- Version     : 0.1
-- Copyright   : Departamento de Eletrônica, Florianópolis, IFSC
-- Description : Este projeto descreve o funcionamento da comunicação i2s entre a FPGA e um microfone.
-------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity I2S is

    Port (
        clk : in std_logic;    
        sck : out std_logic;
        rst : in std_logic;
        ws : out std_logic;
        sd : in std_logic;
        enable : in std_logic;
        left_channel : out std_logic_vector(31 downto 0) := (others => '0');
        right_channel : out std_logic_vector(31 downto 0) := (others => '0')
    );
end I2S;

architecture RTL of I2S is
    type state_type is (IDLE, LEFT, RIGHT);
    signal state : state_type := IDLE;  
    signal bit_count : integer range 0 to 31 := 0;
    signal right_data : std_logic_vector(31 downto 0);
    signal left_data : std_logic_vector(31 downto 0);
    
begin

    -- Processo que realiza a transição de estados da maquina e um contador que sera usado
    -- para direcionar os bits de entrada no bufer, ele é sincronizado por borda 
    -- de descida porque envio do dado do mic é em borda de descida.
    state_transition : process(clk, rst)
    begin
        if rst = '1' then
            state <= IDLE;
            bit_count <= 31;

        elsif falling_edge(clk) then
            case state is
                when IDLE =>
                    if enable = '1' then
                        state <= LEFT;
                    end if;

                when LEFT => 
                    if enable = '0' then
                        state <= IDLE;                   
                    elsif bit_count = 0 then
                        bit_count <= 31;
                        state <= RIGHT;
                    else
                        bit_count <= bit_count - 1;
                    end if;

                when RIGHT =>     
                    if enable = '0' then
                        state <= IDLE;           
                    elsif bit_count = 0 then
                        bit_count <= 31;
                        state <= LEFT;
                    else
                        bit_count <= bit_count - 1;
                    end if;
            end case;
        end if;
    end process state_transition;

    -- Processo que envia a sinal de "word select" e o clock que sincroniza o envio de dados do mic. 
    outs : process(state, clk) is
    begin
        case state is 
            when IDLE =>
                ws <= '0';
                sck <= '1';
            when LEFT =>
                ws <= '0';
                sck <= clk;
            when RIGHT =>
                ws <= '1';
                sck <= clk;
        end case;
    end process outs;
    
    -- Processo que armazena o dado enviado pelo mic em um bufer. Rescebendo os 32 bits, ele armazena os dados do bufer,  como a resolução
    -- do mic usado é 24 bits os ultimos 8 bits enviados são lixo, então ele descarta e completa o registrador de 32 bits com o MSB enviado
    -- para manter a sinalização do dado. Devido ao atraso do envio de 1 ciclo apos o sinal de ws ignorasse o primeiro bit do buffer. 
    -- A leitura é sincroniza por borda de subida, para que haja menos interferencia da transição de bit.
    ready : process (clk, rst) is
    begin
        if rst = '1' then
            right_data <= (others => '0');
            left_data <= (others => '0');
            left_channel <= (others => '0');
            right_channel <= (others => '0');

        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    left_data <= (others => '0');
                    right_data <= (others => '0');

                when LEFT =>
                    left_data(bit_count) <= sd;   
                    if bit_count = 0 then
                        left_channel(23 downto 0) <= left_data(30 downto 7);
                        if left_data(30) = '1' then
                            left_channel(31 downto 24) <= (others => '1');
                        else
                            left_channel(31 downto 24) <= (others => '0'); 
                        end if; 
                        right_data <= (others => '0');
                    end if;

                when RIGHT =>   
                    right_data(bit_count) <= sd;             
                    if bit_count = 0 then
                        right_channel(23 downto 0) <= right_data(30 downto 7);
                        if right_data(30) = '1' then
                            right_channel(31 downto 24) <= (others => '1');
                        else
                            right_channel(31 downto 24) <= (others => '0'); 
                        end if;
                        left_data <= (others => '0');
                    end if;
            end case;     
        end if;
    end process ready;

end RTL;