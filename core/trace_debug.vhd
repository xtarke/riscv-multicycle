
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;

use work.decoder_types.all;
use work.txt_util.all;


entity trace_debug is
	generic (
		--! Num of 32-bits memory words 
		MEMORY_WORDS : integer := 1024	--!= 4K (1024 * 4) bytes
	);
	port(
		pc   : in integer range 0 to MEMORY_WORDS - 1;
		data : in std_logic_vector(31 downto 0);
		inst : out string(1 to 40)
	);
end entity trace_debug;

architecture RTL of trace_debug is
	
	function typeIstring (data: std_logic_vector;  opcode: string; pc, rd, rs1, immediate: integer) return string is
	begin		
		return str(pc*4 ,16) &  ": " & hstr(data)  & " : " & opcode & " x" & str(rd) & ", x" & str(rs1) & ", " & str(immediate);		
	end function;
	
	function typeUstring (data: std_logic_vector; opcode: string; pc, rd, immediate: integer) return string is
	begin		
		return str(pc*4 ,16) & ": " & hstr(data)  & " : " & opcode & " x" & str(rd) & ",  0x" & str(immediate, 16);		
	end function;
	
	function typeRstring (data: std_logic_vector; opcode: string; pc, rd, rs1, rs2: integer) return string is
	begin		
		return str(pc*4,16) & ": " & hstr(data)  & " : " & opcode & " x" & str(rd) & ", x" & str(rs1) & ", x" & str(rs2);		
	end function;
	
	function typeSstring (data: std_logic_vector; opcode: string; pc, rs1, rs2, immediate: integer) return string is
	begin		
		return str(pc*4,16) & ": " & hstr(data)  & " : " & opcode & " x" & str(rs2) & ", " & str(immediate) & "(x" & str(rs1) & ")";		
	end function;
	
	function typeJstring (data: std_logic_vector; opcode: string; pc, rd, immediate: integer) return string is
	begin		
		return str(pc*4,16) & ": " & hstr(data)  & " : " & opcode & " x" & str(rd) & ", " & str(immediate);		
	end function;
	
	function typeJRstring (data: std_logic_vector; opcode: string; pc, rd, rs1, immediate: integer) return string is
	begin		
		return str(pc*4,16) & ": " & hstr(data)  & " : " & opcode & " " &  "x" & str(rd) & ", " & str(immediate) & "(x" & str(rs1) & ")";		
	end function;
	
	function typeLstring (data: std_logic_vector;  opcode: string; pc, rd, rs1, immediate: integer) return string is
	begin		
		return str(pc*4 ,16) &  ": " & hstr(data)  & " : " & opcode & " x" & str(rd) & "," & str(immediate) & "(" & str(rs1) & ")";		
	end function;
	
	function typeBRstring (data: std_logic_vector;  opcode: string; pc, rs1, rs2, immediate: integer) return string is
	begin		
		return str(pc*4 ,16) &  ": " & hstr(data)  & " : " & opcode & " x" & str(rs1) & ", x" & str(rs2) & ", " & str(immediate);		
	end function;
	
	function str_pad(s : string; pad_char : character; len : integer) return string is
		variable ret : string(1 to len);
		variable j : integer := 0;
		variable rm : integer;
	begin
	  assert len >= s'length report "Specified length must be longer than the specified string" severity failure;
	  
	  -- Find last ':' character
	  for i in 1 to s'high loop
	  	if s(i) = ':' then
	  		rm := i;
	  	end if;	  	
	  end loop;
	  
	  -- remove extra espaces 
	  rm := rm + 2;	  
	  j := rm; 
	 
	  for i in 1 to s'high-rm + 1 loop
	    ret(i) := s(j);
	    j := j + 1;
	  end loop;
	 
	  for i in s'high-rm + 2 to len loop
	    ret(i) := pad_char;
	  end loop;
	 
	  return ret;
	end function str_pad;
	
				
begin
	
	debug: process(data)
		
		variable opcodes : opcodes_t;	--! Instruction decoding information. See decoder_types.vhd		
		
		variable rd  : integer range 0 to 31;		--! Register address destination
		variable rs1 : integer range 0 to 31;		--! Register address source operand 1
		variable rs2 : integer range 0 to 31;		--! Register address source operand 2
			
		variable imm_i : integer;	--! Immediate for I-type instruction
		variable imm_s : integer;	--! Immediate for S-type instruction
		variable imm_b : integer;	--! Immediate for B-type instruction		
		variable imm_u : integer;	--! Immediate for U-type instruction
		variable imm_j : integer;	--! Immediate for J-type instruction

		
		-- variable disassembly : string(32 downto 1);
		variable my_line : line; 
		
        file my_output : TEXT open WRITE_MODE is "sim.s";		 
		alias swrite is write [line, string, side, width];
	begin
		
		opcodes.opcode := data (6 downto 0);				
		opcodes.funct3 := data(14 downto 12);
		opcodes.funct7 := data(31 downto 25);
	
		rd  := to_integer(unsigned(data(11 downto 7)));
		rs1 := to_integer(unsigned(data(19 downto 15)));
		rs2 := to_integer(unsigned(data(24 downto 20)));

		imm_i := to_integer(signed(data(31 downto 20)));
		imm_s := to_integer(signed(data(31 downto 25) & data(11 downto 7)));			
		imm_b := to_integer(signed(data(31) & data(7) & data(30 downto 25) & data(11 downto 8) & '0'));				
		imm_u := to_integer(signed(data(31 downto 12) & "000000000000"));
		imm_j := to_integer(signed(data(31) &  data(19 downto 12) & data(20) & data(30 downto 21) & '0'));

		inst <= (others => ' ');
	
		case opcodes.opcode is				
			
			when TYPE_I => 
			
				case opcodes.funct3 is
					when TYPE_ADDI =>
						swrite(my_line, typeIstring(data, "addi", pc, rd, rs1, imm_i));
						writeline(my_output, my_line);
						inst <= str_pad(typeIstring(data, "addi", pc, rd, rs1, imm_i), ' ', 40);
										
					when TYPE_SLTI =>
						swrite(my_line, typeIstring(data, "slti", pc, rd, rs1, imm_i));
						writeline(my_output, my_line);
						inst <= str_pad(typeIstring(data, "slti", pc, rd, rs1, imm_i), ' ', 40);
	
					when TYPE_SLTIU =>
						swrite(my_line, typeIstring(data, "sltiu", pc, rd, rs1, imm_i));
						writeline(my_output, my_line);
						inst <= str_pad(typeIstring(data, "sltiu", pc, rd, rs1, imm_i), ' ', 40);

					when TYPE_XORI =>
						swrite(my_line, typeIstring(data, "xoir", pc, rd, rs1, imm_i));
						writeline(my_output, my_line);
						inst <= str_pad(typeIstring(data, "xoir", pc, rd, rs1, imm_i), ' ', 40);

					when TYPE_ORI =>	
						swrite(my_line, typeIstring(data, "oir", pc, rd, rs1, imm_i));
						writeline(my_output, my_line);
						inst <= str_pad(typeIstring(data, "oir", pc, rd, rs1, imm_i), ' ', 40);
					
					when TYPE_ANDI =>
						swrite(my_line, typeIstring(data, "andi", pc, rd, rs1, imm_i));
						writeline(my_output, my_line);
						inst <= str_pad(typeIstring(data, "andi", pc, rd, rs1, imm_i), ' ', 40);
					
					when TYPE_SLLI =>
						swrite(my_line, typeIstring(data, "slli", pc, rd, rs1, imm_i));
						writeline(my_output, my_line);
						inst <= str_pad(typeIstring(data, "slli", pc, rd, rs1, imm_i), ' ', 40);
						
					when TYPE_SR =>
						case opcodes.funct7 is
						when TYPE_SRLI =>
								-- Shift ammount is rs2
								swrite(my_line, typeIstring(data, "srli", pc, rd, rs1, rs2));
								writeline(my_output, my_line);
								inst <= str_pad(typeIstring(data, "srli", pc, rd, rs1, rs2), ' ', 40);
											
							when TYPE_SRAI =>
								-- Shift ammount is rs2
								swrite(my_line, typeIstring(data, "srai", pc, rd, rs1, rs2));
								writeline(my_output, my_line);
								inst <= str_pad(typeIstring(data, "srai", pc, rd, rs1, rs2), ' ', 40);
														
							when others =>
						end case;
						
											
					when others =>
							
				end case;		
			
			when TYPE_AUIPC =>
				swrite(my_line, typeUstring(data, "auipc", pc, rd, imm_u));
				writeline(my_output, my_line);
				inst <= str_pad(typeUstring(data, "auipc", pc, rd, imm_u), ' ', 40);
				 
			when TYPE_LUI =>
				swrite(my_line, typeUstring(data, "lui", pc, rd, imm_u));
				writeline(my_output, my_line);
				inst <= str_pad(typeUstring(data, "lui", pc, rd, imm_u), ' ', 40);
				
			when TYPE_R => 
				if opcodes.funct7 = TYPE_MULDIV then
					case opcodes.funct3 is
						---------------------------------------------------------------------------
						when TYPE_MUL =>
							swrite(my_line, typeRstring(data, "mul", pc, rd, rs1, rs2));
							writeline(my_output, my_line);
							inst <= str_pad(typeRstring(data, "mul", pc, rd, rs1, rs2), ' ', 40);
						when TYPE_MULH =>
							swrite(my_line, typeRstring(data, "mulh", pc, rd, rs1, rs2));
							writeline(my_output, my_line);
							inst <= str_pad(typeRstring(data, "mulh", pc, rd, rs1, rs2), ' ', 40);
						when TYPE_MULHU =>
							swrite(my_line, typeRstring(data, "mulhu", pc, rd, rs1, rs2));
							writeline(my_output, my_line);
							inst <= str_pad(typeRstring(data, "mulhu", pc, rd, rs1, rs2), ' ', 40);
						when TYPE_MULHSU =>
							swrite(my_line, typeRstring(data, "mulhsu", pc, rd, rs1, rs2));
							writeline(my_output, my_line);
							inst <= str_pad(typeRstring(data, "mulhsu", pc, rd, rs1, rs2), ' ', 40);
						when TYPE_DIV =>
							swrite(my_line, typeRstring(data, "div", pc, rd, rs1, rs2));
							writeline(my_output, my_line);
							inst <= str_pad(typeRstring(data, "div", pc, rd, rs1, rs2), ' ', 40);
						when TYPE_DIVU =>
							swrite(my_line, typeRstring(data, "divu", pc, rd, rs1, rs2));
							writeline(my_output, my_line);
							inst <= str_pad(typeRstring(data, "divu", pc, rd, rs1, rs2), ' ', 40);
						when TYPE_REM =>
							swrite(my_line, typeRstring(data, "rem", pc, rd, rs1, rs2));
							writeline(my_output, my_line);
							inst <= str_pad(typeRstring(data, "rem", pc, rd, rs1, rs2), ' ', 40);
						when TYPE_REMU =>
							swrite(my_line, typeRstring(data, "remu", pc, rd, rs1, rs2));
							writeline(my_output, my_line);
							inst <= str_pad(typeRstring(data, "remu", pc, rd, rs1, rs2), ' ', 40);										
						when others =>		
							report "Not implemented" severity Failure;				
					end case;
				else
					case opcodes.funct3 is
						when TYPE_ADD_SUB =>					
							if opcodes.funct7 = TYPE_ADD then
								swrite(my_line, typeRstring(data, "add", pc, rd, rs1, rs2));
								writeline(my_output, my_line);
								inst <= str_pad(typeRstring(data, "add", pc, rd, rs1, rs2), ' ', 40);							 
							else
								swrite(my_line, typeRstring(data, "sub", pc, rd, rs1, rs2));
								writeline(my_output, my_line);
								inst <= str_pad(typeRstring(data, "sub", pc, rd, rs1, rs2), ' ', 40);	 
							end if;
							
						when TYPE_AND =>
							swrite(my_line, typeRstring(data, "and", pc, rd, rs1, rs2));
							writeline(my_output, my_line);
							inst <= str_pad(typeRstring(data, "and", pc, rd, rs1, rs2), ' ', 40);	
						when TYPE_OR =>
							swrite(my_line, typeRstring(data,"or", pc, rd, rs1, rs2));
							writeline(my_output, my_line);
							inst <= str_pad(typeRstring(data, "or", pc, rd, rs1, rs2), ' ', 40);											
						when TYPE_SLL =>
							swrite(my_line, typeRstring(data, "sll", pc, rd, rs1, rs2));
							writeline(my_output, my_line);
							inst <= str_pad(typeRstring(data, "sll", pc, rd, rs1, rs2), ' ', 40);	
						------------------------------------------------------------------------------------
						--when TYPE_SLR =>
						--	swrite(my_line, typeRstring(data, "slr", pc, rd, rs1, rs2));
						--	writeline(my_output, my_line);
						--	inst <= str_pad(typeRstring(data, "slr", pc, rd, rs1, rs2), ' ', 40);
						when TYPE_SR =>
							
							case opcodes.funct7 is
								when TYPE_SRLI =>									
									-- Shift ammount is rs2
									swrite(my_line, typeIstring(data, "srl", pc, rd, rs1, rs2));
									writeline(my_output, my_line);
									inst <= str_pad(typeIstring(data, "srl", pc, rd, rs1, rs2), ' ', 40);
												
								when TYPE_SRAI =>									
									-- Shift ammount is rs2
									swrite(my_line, typeIstring(data, "sra", pc, rd, rs1, rs2));
									writeline(my_output, my_line);
									inst <= str_pad(typeIstring(data, "sra", pc, rd, rs1, rs2), ' ', 40);
															
								when others =>
									report "nao entrei aqui";
							end case;
						------------------------------------------------------------------------------------													
						when TYPE_XOR =>
							swrite(my_line, typeRstring(data, "xor", pc, rd, rs1, rs2));
							writeline(my_output, my_line);
							inst <= str_pad(typeRstring(data, "xor", pc, rd, rs1, rs2), ' ', 40);					
						when others =>		
							report "Not implemented" severity Failure;				
					end case;
				end if;

				case opcodes.funct3 is
					when TYPE_ADD_SUB =>					
						if opcodes.funct7 = TYPE_ADD then
							swrite(my_line, typeRstring(data, "add", pc, rd, rs1, rs2));
							writeline(my_output, my_line);
							inst <= str_pad(typeRstring(data, "add", pc, rd, rs1, rs2), ' ', 40);							 
						else
							swrite(my_line, typeRstring(data, "sub", pc, rd, rs1, rs2));
							writeline(my_output, my_line);
							inst <= str_pad(typeRstring(data, "sub", pc, rd, rs1, rs2), ' ', 40);	 
						end if;
						
					when TYPE_AND =>
						swrite(my_line, typeRstring(data, "and", pc, rd, rs1, rs2));
						writeline(my_output, my_line);
						inst <= str_pad(typeRstring(data, "and", pc, rd, rs1, rs2), ' ', 40);										
					when TYPE_SLL =>
						swrite(my_line, typeRstring(data, "sll", pc, rd, rs1, rs2));
						writeline(my_output, my_line);
						inst <= str_pad(typeRstring(data, "sll", pc, rd, rs1, rs2), ' ', 40);					
					when TYPE_XOR =>
						swrite(my_line, typeRstring(data, "xor", pc, rd, rs1, rs2));
						writeline(my_output, my_line);
						inst <= str_pad(typeRstring(data, "xor", pc, rd, rs1, rs2), ' ', 40);
										
					when others =>		
						report "Not implemented" severity Failure;				
				end case;
								
			when TYPE_S =>  				
				case opcodes.funct3 is
					when TYPE_SB =>
						swrite(my_line, typeSstring(data, "sb", pc, rs1, rs2, imm_s));
						writeline(my_output, my_line);
						inst <= str_pad(typeSstring(data, "sb", pc, rs1, rs2, imm_s), ' ', 40);						
					when TYPE_SH =>
						swrite(my_line, typeSstring(data, "sh", pc, rs1, rs2, imm_s));
						writeline(my_output, my_line);
						inst <= str_pad(typeSstring(data, "sh", pc, rs1, rs2, imm_s), ' ', 40);						
					when TYPE_SW =>
						swrite(my_line, typeSstring(data, "sw", pc, rs1, rs2, imm_s));
						writeline(my_output, my_line);
						inst <= str_pad(typeSstring(data, "sw", pc, rs1, rs2, imm_s), ' ', 40);						
					when others =>	
				end case;	
				
			when TYPE_L =>  				
				case opcodes.funct3 is
					when TYPE_LB =>
						swrite(my_line, typeSstring(data, "lb", pc, rd, rs1, imm_i));
						writeline(my_output, my_line);
						inst <= str_pad(typeSstring(data, "lb", pc, rd, rs1, imm_i), ' ', 40);
					when TYPE_LBU =>
						swrite(my_line, typeSstring(data, "lbu", pc, rd, rs1, imm_i));
						writeline(my_output, my_line);
						inst <= str_pad(typeSstring(data, "lbu", pc, rd, rs1, imm_i), ' ', 40);
					when TYPE_LH =>
						swrite(my_line, typeSstring(data, "lh", pc, rd, rs1, imm_i));
						writeline(my_output, my_line);
						inst <= str_pad(typeSstring(data, "lh", pc, rd, rs1, imm_i), ' ', 40);
					when TYPE_LW =>
						swrite(my_line, typeSstring(data, "lw", pc, rd, rs1, imm_i));
						writeline(my_output, my_line);
						inst <= str_pad(typeSstring(data, "lw", pc, rd, rs1, imm_i), ' ', 40);
					when others =>
						report "Not implemented" severity Failure;	
				end case;
				
			when TYPE_JAL =>				
				swrite(my_line, typeJstring(data, "jal", pc, rd, imm_j));
				writeline(my_output, my_line);
				swrite(my_line, "");
				writeline(my_output, my_line);
				inst <= str_pad(typeJstring(data, "jal", pc, rd, imm_j), ' ', 40);
			when TYPE_JALR => 
				swrite(my_line, typeJRstring(data, "jalr", pc, rd,rs1 , imm_i));
				writeline(my_output, my_line);
				swrite(my_line, "");
				writeline(my_output, my_line);
				inst <= str_pad(typeJRstring(data, "jalr", pc, rd,rs1 , imm_i), ' ', 40);
			when TYPE_BRANCH => 
				
				case opcodes.funct3 is
					when TYPE_BEQ =>
						swrite(my_line, typeBRstring(data, "beq", pc, rs1, rs2, imm_b));
						writeline(my_output, my_line);
						swrite(my_line, "");
						writeline(my_output, my_line);
						inst <= str_pad(typeBRstring(data, "beq", pc, rs1, rs2, imm_b), ' ', 40);
					when TYPE_BNE => 
						swrite(my_line, typeBRstring(data, "bne", pc, rs1, rs2, imm_b));
						writeline(my_output, my_line);
						swrite(my_line, "");
						writeline(my_output, my_line);
						inst <= str_pad(typeBRstring(data, "bne", pc, rs1, rs2, imm_b), ' ', 40);
					when TYPE_BLT => 
						swrite(my_line, typeBRstring(data, "blt", pc, rs1, rs2, imm_b));
						writeline(my_output, my_line);
						swrite(my_line, "");
						writeline(my_output, my_line);
						inst <= str_pad(typeBRstring(data, "blt", pc, rs1, rs2, imm_b), ' ', 40);
					when TYPE_BGE => 
						swrite(my_line, typeBRstring(data, "bge", pc, rs1, rs2, imm_b));
						writeline(my_output, my_line);
						swrite(my_line, "");
						writeline(my_output, my_line);
						inst <= str_pad(typeBRstring(data, "bge", pc, rs1, rs2, imm_b), ' ', 40);
					when TYPE_BLTU =>						
						swrite(my_line, typeBRstring(data, "bltu", pc, rs1, rs2, imm_b));
						writeline(my_output, my_line);
						swrite(my_line, "");
						writeline(my_output, my_line);
						inst <= str_pad(typeBRstring(data, "bltu", pc, rs1, rs2, imm_b), ' ', 40);					
					when TYPE_BGEU =>						
						swrite(my_line, typeBRstring(data, "bgeu", pc, rs1, rs2, imm_b));
						writeline(my_output, my_line);
						swrite(my_line, "");
						writeline(my_output, my_line);
						inst <= str_pad(typeBRstring(data, "bgeu", pc, rs1, rs2, imm_b), ' ', 40);		
					when others =>
				end case;		
				
			when TYPE_ENV_BREAK =>
				swrite(my_line, "halt!");
				writeline(my_output, my_line);
							
			when others => 
		end case;
	end process;
end architecture RTL;
