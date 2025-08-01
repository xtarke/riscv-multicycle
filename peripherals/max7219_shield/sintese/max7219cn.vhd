library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use work.enum;
--- Modos:
-- No-op
-- Digitos
-- Decoder
-- Intensidade
-- Escanear
-- Desliga
-- Teste Display

    
entity max7219cn is
    port(
        clk     : in  std_logic;                        -- clock com período minimo de 100ns (freq menor que 10MHz)
        rst     : in  std_logic;                        -- reset dos leds do display
        data    : in  std_logic_vector(7 downto 0);     -- dados a serem gravados (os dados no registrador do 7219 ocupam 8 bits D7-D0, MSB-LSB)
        modo    : in  std_logic_vector(7 downto 0);     -- modo do display -> No-op (0000), Digitos (endereço de 0b0001 a 0b1000), Decode (1001),Intensidade (1010), Escanear (1011), Desliga (1100), Teste Display (1111)
        program : in  std_logic;                        -- entrada que sinaliza uma escrita no registrador da max
        din     : out std_logic;                        -- saída para o periférico
        clk_out : out std_logic;                        -- saída do clock para o periférico
        cs      : out  std_logic                        -- chip select ou load 
    );
end entity max7219cn;



architecture RTL of max7219cn is

--type modo_digitos    is (Digitos_contar, Digitos_)
type modo_de_display is (No_op, Digitos, Decoder, Intensidade, Escanear, Desligar, Teste_display, Desliga_todos);
signal estado_display : modo_de_display;
-- maquina de estados

-- contador
signal aclr_n : std_logic;
signal count : std_logic_vector(7 downto 0);
-- contador

-- sinal de término de escrita
signal termino : std_logic := '0';
--

--
signal programa_comeca: std_logic := '0';
--

signal escrita_unica   : std_logic :='1'; 

begin
    counter_8bits: entity work.counter   
    generic map(
        n_bits => 8
    )
    port map(
        aclr_n => aclr_n,
        clk    => clk,
        count  => count
    );

    estados : process (clk) is
    begin
        if rst = '1' then
            estado_display <= No_op;
        elsif rising_edge(clk) then        
            case estado_display is
                when Desliga_todos =>
                    if (Unsigned(modo) = x"01" and Unsigned(count) = x"00") then
                        estado_display <= Digitos;
                    end if;
                when No_op =>
                    if (modo = x"01" and count = x"00") then
                        estado_display <= Digitos;
                        --programa_comeca <= '1';
                    end if;
                when Digitos =>
                    if (termino = '1') then
                        estado_display <= No_op;
                        --programa_comeca <= '0';
                    end if;
                when Decoder =>
                    null;
                when Intensidade =>
                    null;
                when Escanear =>
                    null;
                when Desligar =>
                    null;
                when Teste_display =>
                    null;
            end case;
        end if;
    end process estados;
       

    saidas : process(clk,program) is
    variable reg_din         : std_logic_vector(15 downto 0) := x"0000";            -- utilizado para armazenar o dado escrito na entrada
    variable clock_out_var   : std_logic;                                           -- variável deixa os clocks sincronizados no tempo
    --variable escrita_unica   : std_logic;                                           -- variável que habilita a escrita uma única vez no registrador de dígitos da max7219cn a cada pulso da entrada 'program'                                      
    variable habilita_reg    : std_logic := '1';                                    -- sinal que habilita a escrita no registrador
    begin
        --SAIDAS
        din <= '0';
        cs <= '1';            -- liga em zero;
        clk_out <= '0';
        
        --CONTROLE DO CONTADOR
        aclr_n <= '0';
        
        --VARIVEIS
        habilita_reg    := '1';
        clock_out_var   :='0';
        --escrita_unica   := '0';   

        --SINAL DE SINALIZACAO DE TERMINO
        termino <= '0';

        case estado_display is
            when Desliga_todos =>
                null;
            when No_op =>
                termino <= '0';
            when Digitos =>
                if escrita_unica = '1' then
                    if habilita_reg = '1' then
                        reg_din := modo & data;
                    end if;

                    clock_out_var := not clk;
                    habilita_reg := '0';
                    aclr_n <= '1';
                    cs <= '0';  
                    clk_out <= clock_out_var;
                
                    din <= reg_din(15 - To_integer(Unsigned(count)));

                    if (Unsigned(count) >= x"0F") then
                        habilita_reg := '1';
                        --escrita_unica := '0';
                        aclr_n <= '0';
                        cs <= '1';
                        termino <= '1';
                    end if;
                end if;   
            when Decoder =>
                null;
            when Intensidade =>
                null;
            when Escanear =>
                null;
            when Desligar =>
                null;
            when Teste_display =>
                null;
        end case;
    end process saidas; 

 --   if rising_edge(program)   then
    --    escrita_unica = '1';
  --  end if;

end architecture RTL;
