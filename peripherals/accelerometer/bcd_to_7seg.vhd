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
			case input is
				-- first bit is the point
				when x"0"   => seg7 <= not(num_signal) & "1000000";
				when x"1"   => seg7 <= not(num_signal) & "1111001";
				when x"2"   => seg7 <= not(num_signal) & "0100100";
				when x"3"   => seg7 <= not(num_signal) & "0110000";
				when x"4"   => seg7 <= not(num_signal) & "0011001";
				when x"5"   => seg7 <= not(num_signal) & "0010010";
				when x"6"   => seg7 <= not(num_signal) & "0000010";
				when x"7"   => seg7 <= not(num_signal) & "1111000";
				when x"8"   => seg7 <= not(num_signal) & "0000000";
				when x"9"   => seg7 <= not(num_signal) & "0011000";
				when x"a"   => seg7 <= not(num_signal) & "0001000";	
				when x"b"   => seg7 <= not(num_signal) & "0000011";
				when x"c"   => seg7 <= not(num_signal) & "0100111";
				when x"d"   => seg7 <= not(num_signal) & "0100001";
				when x"e"   => seg7 <= not(num_signal) & "0000110";
				when x"f"   => seg7 <= not(num_signal) & "0001110";    
				when others => seg7 <= not(num_signal) & "1111111";
			end case;      				
	end process;
	
end architecture rlt;
