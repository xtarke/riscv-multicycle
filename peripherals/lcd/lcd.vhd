library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lcd is
	port(
		clk : in std_logic; -- 100 kHz
		reset : in std_logic;
		
		char : in std_logic_vector(7 downto 0);
        
		rst : out std_logic;
		ce : out std_logic;
		dc : out std_logic;
		din : out std_logic;
		serial_clk : out std_logic;
		light : out std_logic
	);
end entity lcd;

architecture RTL of lcd is
	TYPE lcd_state_type IS(POWER_UP, SET_CMD_TYPE, SET_CONTRAST, SET_TEMP_COEFF, SET_BIAS_MODE, SEND_0X20, SET_CONTROL_MODE, CLEAR_DISPLAY, SEND_DATA, FIM);
	
	SIGNAL lcd_state : lcd_state_type;
	
	SIGNAL serial_clk_en : std_logic;
	SIGNAL clk_count : integer range 0 to 100;
	SIGNAL i : integer range 0 to 8;
	SIGNAL byte : integer range 0 to 504;
	SIGNAL data : std_logic_vector(0 to 7);
	SIGNAL data_LCD : std_logic_vector(0 to 4031);
begin
	
	process(clk, serial_clk_en, reset) is
		begin
			if reset = '0' then
				serial_clk <= '0';
			elsif(serial_clk_en = '1') then
				serial_clk <= NOT clk;
			else
				serial_clk <= '0';
			end if;
	end process;
	
	process(clk, reset) is
	begin
		if reset = '0' then
			lcd_state <= POWER_UP;
			serial_clk_en <= '0';
			clk_count <= 0;
			i <= 0;
			byte <= 0;
		elsif rising_edge(clk) then
			CASE lcd_state IS
				when POWER_UP =>
					if(clk_count <= 100) then    -- wait 100 us
						clk_count <= clk_count + 1;
						lcd_state <= POWER_UP;
					else
						clk_count <= 0; 	
						data <= x"21";
						lcd_state <= SET_CMD_TYPE;
						serial_clk_en <= '1';
					end if;	
							
					when SET_CMD_TYPE =>		
						if i < 8 then
							i <= i + 1;
							lcd_state <= SET_CMD_TYPE;
						else	
							i <= 0;
							data <= x"B0";
							lcd_state <= SET_CONTRAST;
							serial_clk_en <= '1';							
						end if;

					when SET_CONTRAST =>		
						if i < 8 then
							i <= i + 1;
							lcd_state <= SET_CONTRAST;
						else
							i <= 0;
							data <= x"04";
							lcd_state <= SET_TEMP_COEFF;						
							serial_clk_en <= '1';
						end if;
						
					when SET_TEMP_COEFF =>		
						if i < 8 then
							i <= i + 1;
							lcd_state <= SET_TEMP_COEFF;
						else
							i <= 0;
							data <= x"14";
							lcd_state <= SET_BIAS_MODE;						
							serial_clk_en <= '1';
						end if;
						
					when SET_BIAS_MODE =>		
						if i < 8 then
							i <= i + 1;
							lcd_state <= SET_BIAS_MODE;
						else
							i <= 0;
							data <= x"20";
							lcd_state <= SEND_0X20;						
							serial_clk_en <= '1';
						end if;					

					when SEND_0X20 =>		
						if i < 8 then
							i <= i + 1;
							lcd_state <= SEND_0X20;
						else
							i <= 0;
							data <= x"0C";
							lcd_state <= SET_CONTROL_MODE;						
							serial_clk_en <= '1';
						end if;					

					when SET_CONTROL_MODE =>		
						if i < 8 then
							i <= i + 1;
							lcd_state <= SET_CONTROL_MODE;
						else
							i <= 0;		
							data_LCD <= (others => '0');
							lcd_state <= CLEAR_DISPLAY;			
							serial_clk_en <= '1';
						end if;					

					when CLEAR_DISPLAY =>		
						if byte < 504 then
							if i < 8 then
								i <= i + 1;
							else
								byte <= byte + 1;	
								i <= 0;
							end if;	
							lcd_state <= CLEAR_DISPLAY;		
						else
							if char = x"41"  then							
								data_LCD(0 to 7) <= x"7e";
								data_LCD(8 to 15) <= x"11";
								data_LCD(16 to 23) <= x"11";
								data_LCD(24 to 31) <= x"11";
								data_LCD(32 to 39) <= x"7e";
							elsif char = x"42" then
								data_LCD(0 to 7) <= x"7f";
								data_LCD(8 to 15) <= x"49";
								data_LCD(16 to 23) <= x"49";
								data_LCD(24 to 31) <= x"49";
								data_LCD(32 to 39) <= x"36";
							elsif char = x"43" then
								data_LCD(0 to 7) <= x"3e";
								data_LCD(8 to 15) <= x"41";
								data_LCD(16 to 23) <= x"41";
								data_LCD(24 to 31) <= x"41";
								data_LCD(32 to 39) <= x"22";								
							else
								data_LCD(0 to 7) <= x"FF";
								data_LCD(8 to 15) <= x"FF";
								data_LCD(16 to 23) <= x"FF";
								data_LCD(24 to 31) <= x"FF";
								data_LCD(32 to 39) <= x"FF";																										
							end if;					
							i <= 0;		
							byte <= 0;
							lcd_state <= SEND_DATA;			
							serial_clk_en <= '1';																													
						end if;							
						
					when SEND_DATA =>		
						if byte < 504 then						
							if i < 8 then
								i <= i + 1;
							else
								byte <= byte + 1;	
								i <= 0;
							end if;	
						lcd_state <= SEND_DATA;																								
						else
							i <= 0;		
							byte <= 0;	
							serial_clk_en <= '0';
							lcd_state <= FIM;		
						end if;
										
					when FIM =>
				
				end case;		
		end if;

	end process;
	process(lcd_state, clk_count, i, byte, data, data_LCD) is
	begin
		rst <= '1';
		ce <= '1';
		dc <= '1';
		din <= '0';
		light <= '1';
		
		case lcd_state IS
		when POWER_UP =>
			rst <= '0';
			if(clk_count > 100) then
				rst <= '1';
			end if;

		when SET_CMD_TYPE =>
			dc <= '0';
			ce <= '0';	
			if i < 8 then
				if data(i) = '1' then
					din <= '1';
				end if;
			else
				ce <= '1';
			end if;

		when SET_CONTRAST =>	
			dc <= '0';
			ce <= '0';	
			if i < 8 then
				if data(i) = '1' then
					din <= '1';
				end if;
			else
				ce <= '1';
			end if;
		
		when SET_TEMP_COEFF =>	
			dc <= '0';
			ce <= '0';	
			if i < 8 then
				if data(i) = '1' then
					din <= '1';
				end if;
			else
				ce <= '1';
			end if;
			
		when SET_BIAS_MODE =>	
			dc <= '0';
			ce <= '0';	
			if i < 8 then
				if data(i) = '1' then
					din <= '1';
				end if;
			else
				ce <= '1';
			end if;
			
		when SEND_0X20 =>	
			dc <= '0';
			ce <= '0';	
			if i < 8 then
				if data(i) = '1' then
					din <= '1';
				end if;
			else
				ce <= '1';
			end if;
			
		when SET_CONTROL_MODE =>	
			dc <= '0';
			ce <= '0';	
			if i < 8 then
				if data(i) = '1' then
					din <= '1';
				end if;
			else
				ce <= '1';
			end if;
			
		when CLEAR_DISPLAY =>	
			dc <= '1';
			ce <= '0';	
			if (i < 8) AND (byte < 504) then
				if data_LCD(i + 8*byte) = '1' then
					din <= '1';
				end if;
			else
				ce <= '1';
			end if;
	
		when SEND_DATA =>	
			dc <= '1';
			ce <= '0';	
			if (i < 8) AND (byte < 504) then
				if data_LCD(i + 8*byte) = '1' then
					din <= '1';
				end if;
			else
				ce <= '1';			
			end if;
			
		when FIM =>
		end case;	
	end process;	
end architecture RTL;
