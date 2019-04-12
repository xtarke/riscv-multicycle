library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.alu_types.all;

entity ULA is
	port(
		alu_data : in alu_data_t;		
		dataOut  : out signed(31 downto 0)
	);
end entity ULA;

architecture RTL of ULA is
	signal shamt : std_logic_vector(4 downto 0);
	signal comp_l  : std_logic_vector(0 downto 0);
	signal comp_lu  : std_logic_vector(0 downto 0);
	
	signal or_vector : std_logic_vector(31 downto 0);
	signal xor_vector : std_logic_vector(31 downto 0);
	signal and_vector : std_logic_vector(31 downto 0);
	
begin
	-- shamt <= std_logic_vector(to_signed(alu_data.b,5));  -- to_unsigned
	shamt <= std_logic_vector(alu_data.b(4 downto 0));  -- to_unsigned
	
	comp_l <= "1" when alu_data.a < alu_data.b else "0";
	--comp_lu <= "1" when (to_unsigned(alu_data.a,32)) < (to_unsigned(alu_data.a,32)) else
	--	      "0";
	comp_lu <= "1" when (unsigned(alu_data.a) < unsigned(alu_data.a)) else "0";
	
		      
	--or_vector <= std_logic_vector(to_signed(alu_data.a,32)) or std_logic_vector(to_signed(alu_data.b,32));
	or_vector <= std_logic_vector(alu_data.a or alu_data.b);
	-- xor_vector <= std_logic_vector(to_signed(alu_data.a,32)) xor std_logic_vector(to_signed(alu_data.b,32));
	xor_vector <= std_logic_vector(alu_data.a xor alu_data.b);
	-- and_vector <= std_logic_vector(to_signed(alu_data.a,32)) and std_logic_vector(to_signed(alu_data.b,32));
	and_vector <= std_logic_vector(alu_data.a and alu_data.b);
		      

	ula_op : with alu_data.code select
	dataOut <=	alu_data.a + alu_data.b when ALU_ADD,
				alu_data.a - alu_data.b when ALU_SUB,				
				alu_data.a sll to_integer(unsigned(shamt)) when ALU_SLL,
				signed(comp_l) when ALU_SLT,
				signed(comp_lu) when ALU_SLTU,				
				signed(xor_vector)  when ALU_XOR,
				alu_data.a srl to_integer(unsigned(shamt)) when ALU_SRL,
				alu_data.a srl to_integer(unsigned(shamt)) when ALU_SRA,
				signed(or_vector)  when ALU_OR,	
				signed(and_vector)  when ALU_AND,
		        (others => '0') when others;

end architecture RTL;
