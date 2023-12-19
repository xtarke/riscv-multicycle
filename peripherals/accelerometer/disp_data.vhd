-- -- bibliotecas -- -- 
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	
-- -- interfaces (entradas, saidas) -- --
entity disp_data is
	port(
		     data_in : in  std_logic_vector(15 downto 0);
			 HEX_0 : out std_logic_vector(7 downto 0);
			 HEX_1 : out std_logic_vector(7 downto 0);
		     HEX_2 : out std_logic_vector(7 downto 0)
		);
end entity disp_data;

-- -- interligacoes (entidade e componentes) -- --
architecture rlt of disp_data is

	signal data_bcd : unsigned(15 downto 0);

	begin

	bcd : entity work.bin_to_bcd    
		port map(
			num_bin    => "0000000" & data_in(8 downto 2) & "00",
			num_signal => data_in(15),
			num_bcd    => data_bcd
		);  					

	seg7_hex1 : entity work.bcd_to_7seg 
	port map( input => data_bcd( 3 downto  0), num_signal => '0'        , seg7 => HEX_0 );  
	seg7_hex2 : entity work.bcd_to_7seg 
	port map( input => data_bcd( 7 downto  4), num_signal => '0'        , seg7 => HEX_1 );
	seg7_hex3 : entity work.bcd_to_7seg 
	port map( input => data_bcd(11 downto  8), num_signal => data_in(15), seg7 => HEX_2 );	  
    
end architecture rlt;
