-- -- bibliotecas -- -- 
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
-- -- interfaces (entradas, saidas) -- --
entity bcd_to_7seg is
	port( input : in  unsigned(3 downto 0);
		  num_signal : in  std_logic;
		  seg7  : out std_logic_vector(7 downto 0) );
end entity bcd_to_7seg;
-- -- interligacoes (entidade e componentes) -- --
architecture rlt of bcd_to_7seg is
	begin
	process(input, num_signal)
		begin
	    if num_signal = '0' then
			case input is
				-- first bit is the point
				when x"0"   => seg7 <= "11000000";
				when x"1"   => seg7 <= "11111001";
				when x"2"   => seg7 <= "10100100";
				when x"3"   => seg7 <= "10110000";
				when x"4"   => seg7 <= "10011001";
				when x"5"   => seg7 <= "10010010";
				when x"6"   => seg7 <= "10000010";
				when x"7"   => seg7 <= "11111000";
				when x"8"   => seg7 <= "10000000";
				when x"9"   => seg7 <= "10011000";			
				when others => seg7 <= "11111111";
			end case;	      
	    else
			case input is
				-- first bit is the point
				when x"0"   => seg7 <= "01000000";
				when x"1"   => seg7 <= "01111001";
				when x"2"   => seg7 <= "00100100";
				when x"3"   => seg7 <= "00110000";
				when x"4"   => seg7 <= "00011001";
				when x"5"   => seg7 <= "00010010";
				when x"6"   => seg7 <= "00000010";
				when x"7"   => seg7 <= "01111000";
				when x"8"   => seg7 <= "00000000";
				when x"9"   => seg7 <= "00011000";			
				when others => seg7 <= "01111111";
			end case;	      
	    end if;
	    				
	end process;
	
end architecture rlt;
