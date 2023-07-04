---------------------------------------------------------------------
--! @file
--! @brief DE10-Lite Simple binary to seven segment display decoder
--!        This hardware should be connected to RISC-V data bus           
--------------------------------------------------------------------

--! Use standard library
library ieee;
    --! Use standard logic elements
    use ieee.std_logic_1164.all;
    --! Use conversion functions
    use ieee.numeric_std.all;


-------------------------------------
entity temperatura is
    generic (
        --! Chip selec
        MY_CHIPSELECT : std_logic_vector(1 downto 0) := "10";   --! Chip select of this device
        MY_WORD_ADDRESS : unsigned(15 downto 0) := x"00E0";     --! Address of this device
        DADDRESS_BUS_SIZE : integer := 32                       --! Data bus size
    );
    port 
    (
        clk : in std_logic;
        rst : in std_logic;
        
        -- Core data bus signals
        -- ToDo: daddress shoud be unsgined
        daddress  : in  unsigned(DADDRESS_BUS_SIZE-1 downto 0);
        ddata_w   : in  std_logic_vector(31 downto 0);
        ddata_r   : out std_logic_vector(31 downto 0);
        d_we      : in std_logic;
        d_rd      : in std_logic;
        dcsel     : in std_logic_vector(1 downto 0);    --! Chip select 
        -- ToDo: Module should mask bytes (Word, half word and byte access)
        dmask     : in std_logic_vector(3 downto 0);    --! Byte enable mask
        
        -- hardware input/output signals
        hex0 : out std_logic_vector(7 downto 0);
        hex1 : out std_logic_vector(7 downto 0);
        hex2 : out std_logic_vector(7 downto 0);
        hex3 : out std_logic_vector(7 downto 0);
        hex4 : out std_logic_vector(7 downto 0);
        hex5 : out std_logic_vector(7 downto 0);
        hex6 : out std_logic_vector(7 downto 0);
        hex7 : out std_logic_vector(7 downto 0);
    
    chave : std_logic
        
        
       
    );
end entity temperatura;
------------------------------

architecture rtl of temperatura is
    
    function decode (data: std_logic_vector(3 downto 0)) return std_logic_vector is
        variable dec : std_logic_vector(7 downto 0);

    begin
        --! Data conversion function
        --! Could be done using RAM
        case data is
            when x"0"=> dec := "11000000";
            when x"1" => dec := "11111001";
            when x"2" => dec := "10100100";
            when x"3" => dec := "10110000";
            when x"4" => dec := "10011001";
            when x"5" => dec := "10010010";
            when x"6" => dec := "10000010";
            when x"7" => dec := "11111000";
            when x"8" => dec := "10000000";
            when others => dec := "10010000";
            
            
        end case;    

        return dec;
    end function;
    
    function decode_ponto (data: std_logic_vector(3 downto 0)) return std_logic_vector is
        variable dec : std_logic_vector(7 downto 0);

    begin
        --! Data conversion function
        --! Could be done using RAM
        case data is
            when x"0"=> dec := "01000000";
            when x"1" => dec := "01111001";
            when x"2" => dec := "00100100";
            when x"3" => dec := "00110000";
            when x"4" => dec := "00011001";
            when x"5" => dec := "00010010";
            when x"6" => dec := "00000010";
            when x"7" => dec := "01111000";
            when x"8" => dec := "00000000";
            when others => dec := "00010000";
            
            
        end case;    

        return dec;
    end function;
    
function decimal_converter (entrada: unsigned(31 downto 0)) return std_logic_vector is
    variable contador: integer := 0;
    variable temp : integer := 0;  -- Inicializa temp com o valor de entrada
    variable max_temp : integer := 150; --defina o numero maximo de vezes que o valor sera sub de 10
  
begin
    temp := to_integer(entrada);
    while contador < max_temp loop 
             temp := temp - 10;
            contador := contador + 1;
            if temp < 10 then
                exit;
               
   end if;
    end loop;
    
return std_logic_vector(to_unsigned(contador, 32));
    
end function decimal_converter;


function fahrenheit (entrada2: unsigned(31 downto 0)) return std_logic_vector is
  
    variable temp : integer := 0;  -- Inicializa temp com o valor de entrada
  
begin
    temp := to_integer(entrada2);
   temp := temp+temp +47;
    
return std_logic_vector(to_unsigned(temp, 32));
    
end function fahrenheit;
    
    
    
    signal raw_data : std_logic_vector(31 downto 0);
    signal sinal_decimal : std_logic_vector(31 downto 0);
    signal sinal_fahrenheit : std_logic_vector(31 downto 0);
begin
    
    -- Input register
    -- This register allows readings from the core
    -- raw_data is not converted to display format
    process(clk, rst)
    begin
        if rst = '1' then
            ddata_r <= (others => '0');            
        else
            if rising_edge(clk) then
                if (d_rd = '1') and (dcsel = MY_CHIPSELECT) then
                    if daddress(15 downto 0) = MY_WORD_ADDRESS then
                        ddata_r <= raw_data; 
                    end if;
                end if;
            end if;
        end if;
    end process;
        
    -- Output register
    process(clk, rst)
    begin       
        if rst = '1' then
            --! All displays resets to zero
            hex0 <= "11000000";
            hex1 <= "11000000"; 
            hex2 <= "11000000"; 
            hex3 <= "01000000"; 
            hex4 <= "11000000"; 
            hex5 <= "11000000"; 
            hex6 <= "11000000"; 
            hex7 <= "11000000"; 
            raw_data <= (others => '0');     
        else
            if rising_edge(clk) then
                if (d_we = '1') and (dcsel = MY_CHIPSELECT) then                
                    if (daddress(15 downto 0)) = MY_WORD_ADDRESS then
                        -- Save raw data to allow readings from CPU
                        raw_data <= ddata_w;
                        sinal_decimal <= decimal_converter(unsigned(ddata_w));
                        sinal_fahrenheit <= fahrenheit(unsigned(decimal_converter(unsigned(ddata_w))));
                    
 
            
                        if chave = '0' then
                        
                        hex0 <= "11000110";
                        hex1 <= "10011100";
                        hex2 <= decode(ddata_w(3 downto 0));
                        hex3 <= decode_ponto(sinal_decimal(3 downto 0));
                        hex4 <= decode(sinal_decimal(7 downto 4));
                        hex5 <= "11111111";
                        hex6 <= decode(sinal_decimal(15 downto 12));
                        hex7 <= decode(sinal_decimal(19 downto 16));
                        
                    else
                       
                        hex0 <= "10001110";
                        hex1 <= "10011100";
                        hex2 <= decode(ddata_w(3 downto 0));
                        hex3 <= decode_ponto(sinal_fahrenheit (3 downto 0));
                        hex4 <= decode(sinal_fahrenheit (7 downto 4));
                        hex5 <= "11111111";
                        hex6 <= decode(sinal_fahrenheit(15 downto 12));
                        hex7 <= decode(sinal_fahrenheit (19 downto 16));
                        
                        end if;
                    end if;
                end if;
            end if;
        end if;     
    end process;
end architecture rtl;
