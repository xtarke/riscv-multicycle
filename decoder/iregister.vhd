-------------------------------------------------------
--! @file
--! @brief RISCV Instruction decoder
-------------------------------------------------------

--! Use standard library
library ieee;
	--! Use standard logic elements
	use ieee.std_logic_1164.all;
	--! Use conversion functions
	use ieee.numeric_std.all;


--! iregister decodes (bit slicing) a instruction word into
--! several parameters (register addresses, call addresses,
--! immediates). See RV32I instruction format
entity iregister is
	port(
		clk : in std_logic;	--! Clock input
		rst : in std_logic;	--! Asynchronous reset
		
		opcode : out std_logic_vector(7 downto 0);	--! Instruction opcode
		funct3 : out std_logic_vector(2 downto 0);	--! Instruction function: 7 bits
		funct7 : out std_logic_vector(6 downto 0);	--! Instruction function: 3 bits
		
		rd  : out integer range 0 to 31;		--! Register address destination
		rs1 : out integer range 0 to 31;		--! Register address source operand 1
		rs2 : out integer range 0 to 31;		--! Register address source operand 2
		
		imm_i : out integer;	--! Immediate for I-type instruction
		imm_s : out integer;	--! Immediate for S-type instruction
		imm_u : out integer		--! Immediate for U-type instruction		
	);
end entity iregister;

architecture RTL of iregister is
	
begin

end architecture RTL;
