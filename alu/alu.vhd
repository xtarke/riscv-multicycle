library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.alu_types.all;

entity ULA is
	port(
		alu_data : in alu_data_t;		
		dataOut  : out integer
	);
end entity ULA;

architecture RTL of ULA is
	signal shamt : std_logic_vector(4 downto 0);
begin
	shamt <= std_logic_vector(to_unsigned(alu_data.b,5));
	

	ula_op : with alu_data.code select
	dataOut <=	alu_data.a + alu_data.b when ALU_ADD,
				alu_data.a - alu_data.b when ALU_SUB,				
				to_integer(to_unsigned(alu_data.a,32) sll to_integer(unsigned(shamt))) when ALU_SLL,	
				
				
		       (0) when others;

end architecture RTL;
