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

begin

	ula_op : with alu_data.code select
	dataOut <=	alu_data.a + alu_data.b when ALU_ADD,	
		       (0) when others;

end architecture RTL;
