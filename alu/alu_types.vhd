LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package alu_types is

	--! Record for instruction decoding
	type alu_data_t is record
		a : signed(31 downto 0);	--! Source operand A
		b : signed(31 downto 0);	--! Source operand B
		code  : std_logic_vector(3 downto 0);	--! Alu operation code
	end record alu_data_t;
	
	constant ALU_ADD	: std_logic_vector(3 downto 0) := "0000";
	constant ALU_SUB	: std_logic_vector(3 downto 0) := "0001";
	
	constant ALU_SLL	: std_logic_vector(3 downto 0) := "0010";
	constant ALU_SRL	: std_logic_vector(3 downto 0) := "0011";
	constant ALU_SRA	: std_logic_vector(3 downto 0) := "0100";
	
	constant ALU_SLT	: std_logic_vector(3 downto 0) := "0101";
	constant ALU_SLTU	: std_logic_vector(3 downto 0) := "0111";
	
	constant ALU_XOR	: std_logic_vector(3 downto 0) := "1000";
	constant ALU_OR  	: std_logic_vector(3 downto 0) := "1001";
	constant ALU_AND  	: std_logic_vector(3 downto 0) := "1010";
		
	constant MUL_ULA 	: std_logic_vector(2 downto 0) := "001";
	constant AND_ULA 	: std_logic_vector(2 downto 0) := "010";
	constant OR_ULA 	: std_logic_vector(2 downto 0) := "011";
	constant XOR_ULA 	: std_logic_vector(2 downto 0) := "100";
	constant NOT_ULA 	: std_logic_vector(2 downto 0) := "101";
	constant SLL_ULA 	: std_logic_vector(2 downto 0) := "110";
	constant SRL_ULA 	: std_logic_vector(2 downto 0) := "111";
	
	constant MUX_ULA_R		: std_logic_vector(1 downto 0) := "00";
	constant MUX_ULA_I  	: std_logic_vector(1 downto 0) := "01";
	constant MUX_ULA_Shift 	: std_logic_vector(1 downto 0) := "10";
	constant MUX_ULA_BRANCH : std_logic_vector(1 downto 0) := "11";
	
	constant MUX_BR_ULA		: std_logic := '0';
	constant MUX_BR_RAM		: std_logic := '1';
	
	constant MUX_COMP_0		: std_logic := '0';
	constant MUX_COMP_EQUAL	: std_logic := '1';
	
	constant PC_DT_PSEUDO 	: std_logic := '0';
	constant PC_DT_BRANCH	: std_logic := '1';	
	
	constant LED_IO_REG : std_logic_vector(7 downto 0) := "10000000";
	constant SW_IO_REG  : std_logic_vector(7 downto 0) := "10000001";
	constant SEG7_IO_REG: std_logic_vector(7 downto 0) := "10000010";	
		
end package alu_types;

package body alu_types is
	
end package body alu_types;
