-------------------------------------------------------
--! @file
--! @brief Este codigo descreve o funcionamento de um sistema capaz de identificar a tecla pressionada
-- 		  em um teclado matricial e exibi-la no display de 7 segmentos da FPGA
--         
--! 
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.decod7.all;


entity key is
	generic (
		--! Chip selec
		MY_CHIPSELECT : std_logic_vector(1 downto 0) := "10";
		MY_WORD_ADDRESS : unsigned(15 downto 0) := x"00e0"; 
		DADDRESS_BUS_SIZE : integer := 32
	);
	
	port(
		clk : in std_logic;
		rst : in std_logic;
		
		-- Core data bus signals
		daddress  : in  unsigned(DADDRESS_BUS_SIZE-1 downto 0);
		ddata_w	  : in 	std_logic_vector(31 downto 0);
		ddata_r   : out	std_logic_vector(31 downto 0);
		d_we      : in std_logic;
		d_rd	  : in std_logic;
		dcsel	  : in std_logic_vector(1 downto 0);	--! Chip select 
		-- ToDo: Module should mask bytes (Word, half word and byte access)
		dmask     : in std_logic_vector(3 downto 0);	--! Byte enable mask
		
		-- hardware input/output signals
		-- interrupções desabilitadas
		colunas : in std_logic_vector(3 downto 0);
		linhas  : out std_logic_vector(3 downto 0);
		tecla_decod : out unsigned(7 downto 0)
		
	);
end entity key;

architecture RTL of key is
   
    signal tecla : unsigned(4 downto 0);
    type state_type is (Init, L1, L2,L3, L4);
    signal state : state_type;
    signal buf : unsigned(4 downto 0);
    
begin
    
	-- Input register
	-- processo responsavel por ler o dados do hardware
    process(clk, rst)
    begin
        if rst = '1' then
            ddata_r <= (others => '0');
        else
            if rising_edge(clk) then
                if (d_rd = '1') and (dcsel = MY_CHIPSELECT) then
                    ddata_r <= (others => '0');
                    if daddress(15 downto 0) = MY_WORD_ADDRESS then
                        ddata_r(4 downto 0) <= std_logic_vector(buf);
                        tecla_decod <= decodifica(buf(3 downto 0));
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    
    --! processo responsavel pela transição de estados
    state_transiction :process(rst,clk) is
       
    begin
    
        if (rst = '1') then
            state <= Init;
            
        elsif(rising_edge(clk)) then
            case state is
                when Init=>
                    state <= L1;                    
                    
                when L1 =>
                    state <= L2;
                    
                when L2 =>
                   state <= L3;
                    
                when L3 =>
                    state <= L4;
                
                when L4 =>
                    state <= L1;
                                      
           end case;         
        end if;
    end process;
    
     -- Saída(s) tipo Mealy:.
     -- coloca de forma sequencial cada linha em nivel logico baixo e observa se alguma coluna esta
	  -- em estado logico baixo, o que representa que que uma tecla da coluna foi pressionada
	  -- comparando a coluna em nivel baixo e a linha que esta em nivel baixo e possivel saber qual
	  -- tecla foi pressionada
    mealy : process(state,colunas)
        
    begin     
        
        linhas <= "1111";
        tecla <= "10000";
        
        case state is
            when Init =>
                linhas <= "1111";
                
            when L1 =>
                linhas <= "0111";
                                
                if colunas = "0111" then
                    tecla <= "00001"; -- 1
                    
                elsif colunas = "1011" then
                    tecla <= "00010"; -- 2 
                    
                elsif colunas = "1101" then
                    tecla <= "00011"; -- 3
                    
                elsif colunas = "1110" then
                    tecla <= "01010"; -- A
                else
                    tecla <= "10000";
                end if;
                
            when L2 =>
                linhas <= "1011";
                
                if colunas = "0111" then
                    tecla <= "00100"; -- 4
                    
                elsif colunas = "1011" then
                    tecla <= "00101"; -- 5 
                    
                elsif colunas = "1101" then
                    tecla <= "00110"; -- 6
                    
                elsif colunas = "1110" then
                    tecla <= "01011"; -- B
                else
                    tecla <= "10000";
                end if;
                
            when L3 =>
                linhas <= "1101";
                
                if colunas = "0111" then
                    tecla <= "00111"; -- 7
                    
                elsif colunas = "1011" then
                    tecla <= "01000"; -- 8 
                    
                elsif colunas = "1101" then
                    tecla <= "01001"; -- 9
                    
                elsif colunas = "1110" then
                    tecla <= "01100"; -- C
                else
                    tecla <= "10000";
                end if;
            
            when L4 =>
                linhas <= "1110";
                
                if colunas = "0111" then
                    tecla <= "01111"; -- * 
                    
                elsif colunas = "1011" then
                    tecla <= "00000"; -- 0 
                    
                elsif colunas = "1101" then
                    tecla <= "01110"; -- #
                    
                elsif colunas = "1110" then
                    tecla <= "01101"; -- D
                else
                    tecla <= "10000";

                end if;
            
        end case;        
    end process;
    
	 
	-- processo responsavel por manter o valor da ultima tecla pressionada e envia-la para ser lida
	verifica_tecla : process (clk,tecla)
   begin
		if rst = '1' then
			buf <= "10000";
      else
			if rising_edge(clk) then
				if tecla /= "10000" then
					buf <= tecla;
				end if;	
			end if;
		end if;
	
	end process;
    
end architecture RTL;

