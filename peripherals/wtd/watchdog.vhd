library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity watchdog is
	generic(
		prescaler_size : integer := 16;
		WTD_BASE_ADDRESS : unsigned(15 downto 0)	:= x"0090"
	);
	port(
		clock       : in  std_logic;
		reset       : in  std_logic;
        daddress    : in  natural;
        ddata_w     : in  std_logic_vector(31 downto 0);
        ddata_r     : out std_logic_vector(31 downto 0);
        d_we        : in  std_logic;
        d_rd        : in  std_logic;
        dcsel       : in  std_logic_vector(1 downto 0);
        dmask       : in  std_logic_vector(3 downto 0);
        wtd_out 	: out std_logic
	);
end entity watchdog;

architecture RTL of watchdog is
		
	-- Sinais usados até agora:
	signal counter				: unsigned(15 downto 0) := (others => '0');	--(prescaler_size - 1 downto 0)
	signal internal_clock		: std_logic := '1';
	
    signal wtd_reset 			: std_logic;
	signal wtd_mode  			: unsigned(1 downto 0);
	signal prescaler   			: unsigned(15 downto 0);
	signal top_counter 			: unsigned(15 downto 0);
		
	signal wtd_clear			: std_logic;	-- Será enviado pelo core para indicar que já pode reiniciar a contagem no modo repetitivo (ainda não implementado)
	signal wtd_interrupt_clr	: std_logic;	-- Irá servir pra interrupção limpar a flag de IRQ, "wtd_interrupt"
	
	signal wtd_hold				: std_logic;	-- Segura a contagem do clock interno no processo P1
	signal wtd_interrupt		: std_logic;	-- Sinal do WTD de que a contagem estourou
		
    -- Sinais "wtd_clear" e "wtd_interrupt_clr":
    -- poderão ser utilizados na expansão do watchdog
    -- para uso com modos repetitivos
       
begin

    -- Output register
	process(clock, reset)
    begin
    	if reset = '1' then
            wtd_reset<='0';
            wtd_mode <="00";
			prescaler  <= (others => '0');
            top_counter<= (others => '0');
            
            wtd_clear			<= '0';
            wtd_hold			<= '0';
            wtd_interrupt_clr	<= '0';
            
        else
        	if rising_edge(clock) then
            	if (d_we = '1') and (dcsel = "10") then
                    -- ToDo: Simplify compartors
                    -- ToDo: Maybe use byte addressing?  
                    --       x"01" (word addressing) is x"04" (byte addressing)
                    
                    if to_unsigned(daddress, 32)(15 downto 0) =(WTD_BASE_ADDRESS + x"0000") then
                        wtd_reset <= ddata_w(0);
                    elsif to_unsigned(daddress, 32)(15 downto 0) =(WTD_BASE_ADDRESS + x"0001") then
                        wtd_mode <= unsigned(ddata_w(1 downto 0));
                    elsif to_unsigned(daddress, 32)(15 downto 0) =(WTD_BASE_ADDRESS + x"0002") then
                        prescaler <= unsigned(ddata_w(15 downto 0));
                    elsif to_unsigned(daddress, 32)(15 downto 0) =(WTD_BASE_ADDRESS + x"0003") then
                    	top_counter <= unsigned(ddata_w(15 downto 0));
                	elsif to_unsigned(daddress, 32)(15 downto 0) =(WTD_BASE_ADDRESS + x"0004") then
                    	wtd_clear <= ddata_w(0);
                	elsif to_unsigned(daddress, 32)(15 downto 0) =(WTD_BASE_ADDRESS + x"0005") then
                    	wtd_hold <= ddata_w(0);
                	elsif to_unsigned(daddress, 32)(15 downto 0) =(WTD_BASE_ADDRESS + x"0006") then
                    	wtd_interrupt_clr <= ddata_w(0);
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Input register
    process(clock, reset)
    begin
        if reset = '1' then
            ddata_r <= (others => '0');
        else

            if rising_edge(clock) then
				         ddata_r <= (others => '0');
                if (d_rd = '1') and (dcsel = "10") then
                    if to_unsigned(daddress, 32)(15 downto 0) =(WTD_BASE_ADDRESS + x"0007") then
                        ddata_r(0) <= wtd_interrupt;
                    end if;
                end if;
            end if;
        end if;
    end process;

	p1 : process(clock, reset) is       -- @suppress "Incomplete sensitivity list. Missing signals: internal_clock, prescaler"
		variable temp_counter : unsigned(prescaler_size - 1 downto 0) := (others => '0');
	begin
		if reset = '0' then
			if wtd_hold  = '0' then
				if prescaler = x"0001" then
					internal_clock <= clock;
				elsif rising_edge(clock) then
					temp_counter := temp_counter + 1;
					if temp_counter >= prescaler - 1 then
						internal_clock <= not (internal_clock);
						temp_counter   := (others => '0');
					end if;
				end if;
			end if;						
		else
			temp_counter := (others => '0');
		end if;
	end process p1;

	p2 : process(internal_clock, reset) is
		
		-- Variáveis internas do processo do Watchdog
		variable internal_wtd_interrupt	: std_logic	:= '0';
		variable internal_wtd_out		: std_logic	:= '0';
		
	begin
		if reset = '0' then

			if rising_edge(internal_clock) then
				if wtd_reset = '1' then
					
					internal_wtd_interrupt	:= '0';
					internal_wtd_out		:= '0';
					counter           		<= (others => '0');
					
				else
					
					case wtd_mode is
						
						when "01" =>    -- One-Shot Mode
						
							if counter >= top_counter-1 then
								
								-- Já travou, reseta!
								internal_wtd_interrupt := '1';
								internal_wtd_out := '1';
						
							else
								
								-- Ainda não travou, continua!
								counter <= counter + 1;
								
							end if;
						
						when others =>  -- none / error
							internal_wtd_interrupt	:= '0';
							internal_wtd_out		:= '0';
							counter           			<= (others => '0');
					end case;
					
					if wtd_interrupt_clr = '1' then 
						internal_wtd_out 		:= '0';
						internal_wtd_interrupt	:= '0';
					end if;	
					
				end if;
			end if;

			wtd_interrupt 	<= internal_wtd_interrupt;
			wtd_out 		<= internal_wtd_out;
		else
			internal_wtd_interrupt	:= '0';
			internal_wtd_out		:= '0';
			
			wtd_interrupt 	<= internal_wtd_interrupt;
			wtd_out 		<= internal_wtd_out;
		end if;

	end process p2;

end architecture RTL;