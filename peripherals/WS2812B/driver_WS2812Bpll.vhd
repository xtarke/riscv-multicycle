-------------------------------------------------------
-- Dispositivos Lógico-Programáveis
-- Aluno: Luciano Caminha Junior
-- Professor: Renan Starke
-- Data: Março de 2022
-- Description : Addressable RGB LED controller WS2812B
-- Datasheet   : cdn-shop.adafruit.com/datasheets/WS2812B.pdf 
-------------------------------------------------------

-- Bibliotecas utilizadas
library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

        
entity driver_WS2812pll is
    generic (
        --! Chip selec
        MY_CHIPSELECT : std_logic_vector(1 downto 0) := "10";
        MY_WORD_ADDRESS : unsigned(7 downto 0) := x"10"
    );

    port(
        clk  : in std_logic; -- Este periférico foi projetado para operar sobre um clock master de 20MHz
        rst : in std_logic;
        
        
        -- Core data bus signals
        -- ToDo: daddress shoud be unsgined
        --daddress  : in  natural;
        --ddata_w   : in  std_logic_vector(31 downto 0);
        --ddata_r   : out std_logic_vector(31 downto 0);
        --d_we      : in std_logic;
        --d_rd      : in std_logic;
        --dcsel     : in std_logic_vector(1 downto 0);    --! Chip select 
        -- ToDo: Module should mask bytes (Word, half word and byte access)
        --dmask     : in std_logic_vector(3 downto 0);    --! Byte enable mask

        -- hardware input/output signals
        clk0 : in std_logic;     -- O clock de bit 0 deve possuir 800KHz e Duty Cycle de 32% 
        clk1 : in std_logic;     -- O clock de bit 1 deve possuir 800KHz e Duty Cycle de 68%
        data_in  : in unsigned(23 downto 0); -- Sequência de 3 cores, com 8bits cada, no formato GRB
        data_out : out std_logic -- Saída para controlar o LED
    );
end entity driver_WS2812pll;

architecture rtl of driver_WS2812pll is

    signal current_bit: std_logic;
    signal write_bit: std_logic;
    signal read_bit: std_logic;
    signal start_reset: std_logic;
    
    -- Data Structure
    -- _______    
    --|  T0H  |______T0L_____| -- bit 0 T0H - 0,4us e T0L - 0,85us
    -- ______________
    --|       T1H    |__T1L__| -- bit 1 T1H - 0,85us e T1L - 0,4us
    --
    --constant clk_freq: integer:= 20000000; -- 20MHz período 0.00000005s -- 50ns
     
    --constant T0H : integer :=  8; -- bit 0: deve ficar 0,4us em estado alto. 8 períodos de clock. 
    --constant T0L : integer := 17; -- bit 0: deve ficar 0,85us em estado baixo. 17 períodos de clock. 
    --constant T1H : integer := 17; -- bit 1: deve ficar 0,85us em estado alto. 17 períodos de clock. 
    --constant T1L : integer :=  8; -- bit 1: deve ficar 0,4us em estado baixo. 8 períodos de clock.   
    --constant RES : integer := 1000; -- estado deve ficar baixo por pelo menos 50us para reset. 1000 períodos de clock.   
    
begin
    
    state_transition: process(clk, rst) is
    variable i: integer range -1 to 24 := -1;
    variable rst_counter: integer range -1 to 1000 := -1;
    begin
        if (rst = '1') then
            data_out <= '0';
            read_bit <= '1';
            write_bit <= '0';
            start_reset <= '1';
        elsif (rising_edge(clk)) then
            if(start_reset = '1')then
                if (rst_counter < 1000) then
                    rst_counter := rst_counter + 1;
                elsif (rst_counter=1000) then
                    start_reset <= '0';
                    rst_counter := 0;
                end if;
            elsif(read_bit = '1') then
                if (i < 23) then
                    i := i + 1;
                elsif (i=23) then
                    i := 0;
                end if;
                current_bit <= data_in(i);
                data_out <= '1';
                read_bit <= '0';
            end if;
            case current_bit is
                when '0' => if(clk0 = '0') then
                                write_bit <= '1';
                                data_out <= '0';
                            else
                                if(write_bit = '1') then
                                    read_bit <= '1';
                                    data_out <= '1';
                                    write_bit <= '0';
                                end if;
                            end if;
                when '1' => if(clk1 = '0') then
                                write_bit <= '1';
                                data_out <= '0';
                            else
                                if(write_bit = '1') then
                                    read_bit <= '1';
                                    data_out <= '1';
                                    write_bit <= '0';
                                end if;
                            end if;
                when OTHERS =>  data_out <= '0';
            end case;
        end if;
    end process;
    
end architecture rtl;