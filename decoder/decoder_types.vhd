LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;

package decoder_types is

	--! Record for instruction decoding
	type opcodes_t is record
		opcode : std_logic_vector(6 downto 0);	--! Instruction opcode
		funct3 : std_logic_vector(2 downto 0);	--! Instruction function: 7 bits
		funct7 : std_logic_vector(6 downto 0);	--! Instruction function: 3 bits
	end record opcodes_t;
	
	--! Record for memory controller
	type mem_ctrl_t is record
		read : std_logic;		--! Memory read signal
		write: std_logic;		--! Memory write signal
		bus_lag : std_logic; 	--! Active when another cycle is needle for bus transaction (reada DATA f
		word_size : std_logic_vector(1 downto 0);	--! "00": word, "01": half word, "11" byte
	end record mem_ctrl_t;
	
	--! Record for control flow instructions
	type jumps_ctrl_t is record
		inc : std_logic;	--! Memory read signal
		load: std_logic;	--! Memory write signal
		load_from : std_logic_vector(1 downto 0);	--! "00": pc + j_imm
	end record jumps_ctrl_t;			 

	--! Record for cpu state
	type cpu_state_t is record
		halted : std_logic;	--! CPU is halted (execution of ebreak) 
		error  : std_logic;	--! There is an error
	end record cpu_state_t;		

	--! Arithmetic type R opcode
	constant TYPE_R	: std_logic_vector(6 downto 0) := "0110011";
		--! Func3 opcodes
		constant TYPE_ADD_SUB	: std_logic_vector(2 downto 0) := "000";
			--! Func7 opcodes
			constant TYPE_ADD	: std_logic_vector(6 downto 0) := "0000000";
			constant TYPE_SUB	: std_logic_vector(6 downto 0) := "0100000";
		constant TYPE_SLL		: std_logic_vector(2 downto 0) := "001";
		constant TYPE_SLT		: std_logic_vector(2 downto 0) := "010";
		constant TYPE_SLU		: std_logic_vector(2 downto 0) := "011";
		constant TYPE_XOR		: std_logic_vector(2 downto 0) := "100";
		-- constant TYPE_SR: Uses same logic of TYPE_I
		constant TYPE_OR		: std_logic_vector(2 downto 0) := "110";
		constant TYPE_AND		: std_logic_vector(2 downto 0) := "111";
		
		
			
	--! Arithmetic type I opcode
	constant TYPE_I	: std_logic_vector(6 downto 0) := "0010011";
		--! Func3 opcodes
		constant TYPE_ADDI	: std_logic_vector(2 downto 0) := "000";
		constant TYPE_SLTI	: std_logic_vector(2 downto 0) := "010";
		constant TYPE_SLTIU	: std_logic_vector(2 downto 0) := "011";
		constant TYPE_XORI	: std_logic_vector(2 downto 0) := "100";
		constant TYPE_ORI	: std_logic_vector(2 downto 0) := "110";
		constant TYPE_ANDI	: std_logic_vector(2 downto 0) := "111";
		constant TYPE_SLLI	: std_logic_vector(2 downto 0) := "001";
		constant TYPE_SR	: std_logic_vector(2 downto 0) := "101";
			--! Func7 opcodes
			constant TYPE_SRLI	: std_logic_vector(6 downto 0) := "0000000";
			constant TYPE_SRAI	: std_logic_vector(6 downto 0) := "0100000";
		
	--! Branch opcodes
	constant TYPE_BRANCH : std_logic_vector(6 downto 0) := "1100011";
		--! Func3 opcodes
		constant TYPE_BEQ	: std_logic_vector(2 downto 0) := "000";
		constant TYPE_BNE	: std_logic_vector(2 downto 0) := "001";
		constant TYPE_BLT	: std_logic_vector(2 downto 0) := "100";
		constant TYPE_BGE	: std_logic_vector(2 downto 0) := "101";
		constant TYPE_BLTU	: std_logic_vector(2 downto 0) := "110";
		constant TYPE_BGEU	: std_logic_vector(2 downto 0) := "111";
	
	--! Memory type S opcode
	constant TYPE_S	: std_logic_vector(6 downto 0) := "0100011";
		--! Func3 opcodes
		constant TYPE_SB	: std_logic_vector(2 downto 0) := "000";
		constant TYPE_SH	: std_logic_vector(2 downto 0) := "001";
		constant TYPE_SW	: std_logic_vector(2 downto 0) := "010";
	
	--! Memory type L opcode
	constant TYPE_L	: std_logic_vector(6 downto 0) := "0000011";
		--! Func3 opcodes
		constant TYPE_LB	: std_logic_vector(2 downto 0) := "000";
		constant TYPE_LH	: std_logic_vector(2 downto 0) := "001";
		constant TYPE_LW	: std_logic_vector(2 downto 0) := "010";
		constant TYPE_LBU	: std_logic_vector(2 downto 0) := "100";
		constant TYPE_LHU	: std_logic_vector(2 downto 0) := "101";	
	
	--! Jumps opcode
	constant TYPE_JAL	: std_logic_vector(6 downto 0) := "1101111";
	constant TYPE_JALR	: std_logic_vector(6 downto 0) := "1100111";
	
	--! Special type U opcode
	constant TYPE_LUI	: std_logic_vector(6 downto 0) := "0110111";
	constant TYPE_AUIPC	: std_logic_vector(6 downto 0) := "0010111";
	
	--!  Environment Call and Breakpoints
	constant TYPE_ENV_BREAK :  std_logic_vector(6 downto 0) := "1110011";
		--! Func3 opcodes
		constant TYPE_EBREAK_ECALL	: std_logic_vector(2 downto 0) := "000";
			--! Func7 opcodes
			constant TYPE_EBREAK	: std_logic_vector(6 downto 0) := "0000001";
	
--	constant PLUS_ULA	: std_logic_vector(2 downto 0) := "000";
--	constant MUL_ULA 	: std_logic_vector(2 downto 0) := "001";
--	constant AND_ULA 	: std_logic_vector(2 downto 0) := "010";
--	constant OR_ULA 	: std_logic_vector(2 downto 0) := "011";
--	constant XOR_ULA 	: std_logic_vector(2 downto 0) := "100";
--	constant NOT_ULA 	: std_logic_vector(2 downto 0) := "101";
--	constant SLL_ULA 	: std_logic_vector(2 downto 0) := "110";
--	constant SRL_ULA 	: std_logic_vector(2 downto 0) := "111";
--	
--	constant MUX_ULA_R		: std_logic_vector(1 downto 0) := "00";
--	constant MUX_ULA_I  	: std_logic_vector(1 downto 0) := "01";
--	constant MUX_ULA_Shift 	: std_logic_vector(1 downto 0) := "10";
--	constant MUX_ULA_BRANCH : std_logic_vector(1 downto 0) := "11";
--	
--	constant MUX_BR_ULA		: std_logic := '0';
--	constant MUX_BR_RAM		: std_logic := '1';
--	
--	constant MUX_COMP_0		: std_logic := '0';
--	constant MUX_COMP_EQUAL	: std_logic := '1';
--	
--	constant PC_DT_PSEUDO 	: std_logic := '0';
--	constant PC_DT_BRANCH	: std_logic := '1';	
--	
--	constant LED_IO_REG : std_logic_vector(7 downto 0) := "10000000";
--	constant SW_IO_REG  : std_logic_vector(7 downto 0) := "10000001";
--	constant SEG7_IO_REG: std_logic_vector(7 downto 0) := "10000010";	
		
end package decoder_types;

package body decoder_types is
	
end package body decoder_types;
