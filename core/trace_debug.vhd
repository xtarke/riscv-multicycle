
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;

use work.decoder_types.all;
use work.txt_util.all;


entity trace_debug is
	generic (
		--! Num of 32-bits memory words
		MEMORY_WORDS : integer := 1024;	--!= 4K (1024 * 4) bytes
		IADDRESS_BUS_SIZE : integer := 16
	);
	port(
		pc   : in unsigned(IADDRESS_BUS_SIZE-1 downto 0);
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
	    opcodes.funct12 := data(31 downto 20);

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
						swrite(my_line, typeIstring(data, "addi", to_integer(pc), rd, rs1, imm_i));
						writeline(my_output, my_line);
						inst <= str_pad(typeIstring(data, "addi", to_integer(pc), rd, rs1, imm_i), ' ', 40);

					when TYPE_SLTI =>
						swrite(my_line, typeIstring(data, "slti", to_integer(pc), rd, rs1, imm_i));
						writeline(my_output, my_line);
						inst <= str_pad(typeIstring(data, "slti", to_integer(pc), rd, rs1, imm_i), ' ', 40);

					when TYPE_SLTIU =>
						swrite(my_line, typeIstring(data, "sltiu", to_integer(pc), rd, rs1, imm_i));
						writeline(my_output, my_line);
						inst <= str_pad(typeIstring(data, "sltiu", to_integer(pc), rd, rs1, imm_i), ' ', 40);

					when TYPE_XORI =>
						swrite(my_line, typeIstring(data, "xoir", to_integer(pc), rd, rs1, imm_i));
						writeline(my_output, my_line);
						inst <= str_pad(typeIstring(data, "xoir", to_integer(pc), rd, rs1, imm_i), ' ', 40);

					when TYPE_ORI =>
						swrite(my_line, typeIstring(data, "oir", to_integer(pc), rd, rs1, imm_i));
						writeline(my_output, my_line);
						inst <= str_pad(typeIstring(data, "oir", to_integer(pc), rd, rs1, imm_i), ' ', 40);

					when TYPE_ANDI =>
						swrite(my_line, typeIstring(data, "andi", to_integer(pc), rd, rs1, imm_i));
						writeline(my_output, my_line);
						inst <= str_pad(typeIstring(data, "andi", to_integer(pc), rd, rs1, imm_i), ' ', 40);

					when TYPE_SLLI =>
						swrite(my_line, typeIstring(data, "slli", to_integer(pc), rd, rs1, imm_i));
						writeline(my_output, my_line);
						inst <= str_pad(typeIstring(data, "slli", to_integer(pc), rd, rs1, imm_i), ' ', 40);

					when TYPE_SR =>
						case opcodes.funct7 is
						when TYPE_SRLI =>
								-- Shift ammount is rs2
								swrite(my_line, typeIstring(data, "srli", to_integer(pc), rd, rs1, rs2));
								writeline(my_output, my_line);
								inst <= str_pad(typeIstring(data, "srli", to_integer(pc), rd, rs1, rs2), ' ', 40);

							when TYPE_SRAI =>
								-- Shift ammount is rs2
								swrite(my_line, typeIstring(data, "srai", to_integer(pc), rd, rs1, rs2));
								writeline(my_output, my_line);
								inst <= str_pad(typeIstring(data, "srai", to_integer(pc), rd, rs1, rs2), ' ', 40);

							when others =>
						end case;


					when others =>

				end case;

			when TYPE_AUIPC =>
				swrite(my_line, typeUstring(data, "auipc", to_integer(pc), rd, imm_u));
				writeline(my_output, my_line);
				inst <= str_pad(typeUstring(data, "auipc", to_integer(pc), rd, imm_u), ' ', 40);

			when TYPE_LUI =>
				swrite(my_line, typeUstring(data, "lui", to_integer(pc), rd, imm_u));
				writeline(my_output, my_line);
				inst <= str_pad(typeUstring(data, "lui", to_integer(pc), rd, imm_u), ' ', 40);

			when TYPE_R =>
				if opcodes.funct7 = TYPE_MULDIV then
					case opcodes.funct3 is
						---------------------------------------------------------------------------
						when TYPE_MUL =>
							swrite(my_line, typeRstring(data, "mul", to_integer(pc), rd, rs1, rs2));
							writeline(my_output, my_line);
							inst <= str_pad(typeRstring(data, "mul", to_integer(pc), rd, rs1, rs2), ' ', 40);
						when TYPE_MULH =>
							swrite(my_line, typeRstring(data, "mulh", to_integer(pc), rd, rs1, rs2));
							writeline(my_output, my_line);
							inst <= str_pad(typeRstring(data, "mulh", to_integer(pc), rd, rs1, rs2), ' ', 40);
						when TYPE_MULHU =>
							swrite(my_line, typeRstring(data, "mulhu", to_integer(pc), rd, rs1, rs2));
							writeline(my_output, my_line);
							inst <= str_pad(typeRstring(data, "mulhu", to_integer(pc), rd, rs1, rs2), ' ', 40);
						when TYPE_MULHSU =>
							swrite(my_line, typeRstring(data, "mulhsu", to_integer(pc), rd, rs1, rs2));
							writeline(my_output, my_line);
							inst <= str_pad(typeRstring(data, "mulhsu", to_integer(pc), rd, rs1, rs2), ' ', 40);
						when TYPE_DIV =>
							swrite(my_line, typeRstring(data, "div", to_integer(pc), rd, rs1, rs2));
							writeline(my_output, my_line);
							inst <= str_pad(typeRstring(data, "div", to_integer(pc), rd, rs1, rs2), ' ', 40);
						when TYPE_DIVU =>
							swrite(my_line, typeRstring(data, "divu", to_integer(pc), rd, rs1, rs2));
							writeline(my_output, my_line);
							inst <= str_pad(typeRstring(data, "divu", to_integer(pc), rd, rs1, rs2), ' ', 40);
						when TYPE_REM =>
							swrite(my_line, typeRstring(data, "rem", to_integer(pc), rd, rs1, rs2));
							writeline(my_output, my_line);
							inst <= str_pad(typeRstring(data, "rem", to_integer(pc), rd, rs1, rs2), ' ', 40);
						when TYPE_REMU =>
							swrite(my_line, typeRstring(data, "remu", to_integer(pc), rd, rs1, rs2));
							writeline(my_output, my_line);
							inst <= str_pad(typeRstring(data, "remu", to_integer(pc), rd, rs1, rs2), ' ', 40);
						when others =>
							report "Not implemented" severity Failure;
					end case;
				else
					case opcodes.funct3 is
						when TYPE_ADD_SUB =>
							if opcodes.funct7 = TYPE_ADD then
								swrite(my_line, typeRstring(data, "add", to_integer(pc), rd, rs1, rs2));
								writeline(my_output, my_line);
								inst <= str_pad(typeRstring(data, "add", to_integer(pc), rd, rs1, rs2), ' ', 40);
							else
								swrite(my_line, typeRstring(data, "sub", to_integer(pc), rd, rs1, rs2));
								writeline(my_output, my_line);
								inst <= str_pad(typeRstring(data, "sub", to_integer(pc), rd, rs1, rs2), ' ', 40);
							end if;

						when TYPE_AND =>
							swrite(my_line, typeRstring(data, "and", to_integer(pc), rd, rs1, rs2));
							writeline(my_output, my_line);
							inst <= str_pad(typeRstring(data, "and", to_integer(pc), rd, rs1, rs2), ' ', 40);
						when TYPE_OR =>
							swrite(my_line, typeRstring(data,"or", to_integer(pc), rd, rs1, rs2));
							writeline(my_output, my_line);
							inst <= str_pad(typeRstring(data, "or", to_integer(pc), rd, rs1, rs2), ' ', 40);
						when TYPE_SLL =>
							swrite(my_line, typeRstring(data, "sll", to_integer(pc), rd, rs1, rs2));
							writeline(my_output, my_line);
							inst <= str_pad(typeRstring(data, "sll", to_integer(pc), rd, rs1, rs2), ' ', 40);
						------------------------------------------------------------------------------------
						--when TYPE_SLR =>
						--	swrite(my_line, typeRstring(data, "slr", to_integer(pc), rd, rs1, rs2));
						--	writeline(my_output, my_line);
						--	inst <= str_pad(typeRstring(data, "slr", to_integer(pc), rd, rs1, rs2), ' ', 40);
						when TYPE_SR =>

							case opcodes.funct7 is
								when TYPE_SRLI =>
									-- Shift ammount is rs2
									swrite(my_line, typeIstring(data, "srl", to_integer(pc), rd, rs1, rs2));
									writeline(my_output, my_line);
									inst <= str_pad(typeIstring(data, "srl", to_integer(pc), rd, rs1, rs2), ' ', 40);

								when TYPE_SRAI =>
									-- Shift ammount is rs2
									swrite(my_line, typeIstring(data, "sra", to_integer(pc), rd, rs1, rs2));
									writeline(my_output, my_line);
									inst <= str_pad(typeIstring(data, "sra", to_integer(pc), rd, rs1, rs2), ' ', 40);

								when others =>
									report "nao entrei aqui";
							end case;
						------------------------------------------------------------------------------------
						when TYPE_XOR =>
							swrite(my_line, typeRstring(data, "xor", to_integer(pc), rd, rs1, rs2));
							writeline(my_output, my_line);
							inst <= str_pad(typeRstring(data, "xor", to_integer(pc), rd, rs1, rs2), ' ', 40);
						when others =>
							report "Not implemented" severity Failure;
					end case;
				end if;

			when TYPE_S =>
				case opcodes.funct3 is
					when TYPE_SB =>
						swrite(my_line, typeSstring(data, "sb", to_integer(pc), rs1, rs2, imm_s));
						writeline(my_output, my_line);
						inst <= str_pad(typeSstring(data, "sb", to_integer(pc), rs1, rs2, imm_s), ' ', 40);
					when TYPE_SH =>
						swrite(my_line, typeSstring(data, "sh", to_integer(pc), rs1, rs2, imm_s));
						writeline(my_output, my_line);
						inst <= str_pad(typeSstring(data, "sh", to_integer(pc), rs1, rs2, imm_s), ' ', 40);
					when TYPE_SW =>
						swrite(my_line, typeSstring(data, "sw", to_integer(pc), rs1, rs2, imm_s));
						writeline(my_output, my_line);
						inst <= str_pad(typeSstring(data, "sw", to_integer(pc), rs1, rs2, imm_s), ' ', 40);
					when others =>
				end case;

			when TYPE_L =>
				case opcodes.funct3 is
					when TYPE_LB =>
						swrite(my_line, typeSstring(data, "lb", to_integer(pc), rs1, rd, imm_i));
						writeline(my_output, my_line);
						inst <= str_pad(typeSstring(data, "lb", to_integer(pc), rs1, rd, imm_i), ' ', 40);
					when TYPE_LBU =>
						swrite(my_line, typeSstring(data, "lbu", to_integer(pc), rs1, rd, imm_i));
						writeline(my_output, my_line);
						inst <= str_pad(typeSstring(data, "lbu", to_integer(pc), rs1, rd, imm_i), ' ', 40);
					when TYPE_LHU =>
						swrite(my_line, typeSstring(data, "lhu", to_integer(pc), rs1, rd, imm_i));
						writeline(my_output, my_line);
						inst <= str_pad(typeSstring(data, "lhu", to_integer(pc), rs1, rd, imm_i), ' ', 40);
					when TYPE_LH =>
						swrite(my_line, typeSstring(data, "lh", to_integer(pc), rs1, rd, imm_i));
						writeline(my_output, my_line);
						inst <= str_pad(typeSstring(data, "lh", to_integer(pc), rs1, rd, imm_i), ' ', 40);
					when TYPE_LW =>
						swrite(my_line, typeSstring(data, "lw", to_integer(pc), rs1, rd, imm_i));
						writeline(my_output, my_line);
						inst <= str_pad(typeSstring(data, "lw", to_integer(pc), rs1, rd, imm_i), ' ', 40);
					when others =>
						report "Not implemented" severity Failure;
				end case;

			when TYPE_JAL =>
				swrite(my_line, typeJstring(data, "jal", to_integer(pc), rd, imm_j));
				writeline(my_output, my_line);
				swrite(my_line, "");
				writeline(my_output, my_line);
				inst <= str_pad(typeJstring(data, "jal", to_integer(pc), rd, imm_j), ' ', 40);
			when TYPE_JALR =>
				swrite(my_line, typeJRstring(data, "jalr", to_integer(pc), rd,rs1 , imm_i));
				writeline(my_output, my_line);
				swrite(my_line, "");
				writeline(my_output, my_line);
				inst <= str_pad(typeJRstring(data, "jalr", to_integer(pc), rd,rs1 , imm_i), ' ', 40);
			when TYPE_BRANCH =>

				case opcodes.funct3 is
					when TYPE_BEQ =>
						swrite(my_line, typeBRstring(data, "beq", to_integer(pc), rs1, rs2, imm_b));
						writeline(my_output, my_line);
						swrite(my_line, "");
						writeline(my_output, my_line);
						inst <= str_pad(typeBRstring(data, "beq", to_integer(pc), rs1, rs2, imm_b), ' ', 40);
					when TYPE_BNE =>
						swrite(my_line, typeBRstring(data, "bne", to_integer(pc), rs1, rs2, imm_b));
						writeline(my_output, my_line);
						swrite(my_line, "");
						writeline(my_output, my_line);
						inst <= str_pad(typeBRstring(data, "bne", to_integer(pc), rs1, rs2, imm_b), ' ', 40);
					when TYPE_BLT =>
						swrite(my_line, typeBRstring(data, "blt", to_integer(pc), rs1, rs2, imm_b));
						writeline(my_output, my_line);
						swrite(my_line, "");
						writeline(my_output, my_line);
						inst <= str_pad(typeBRstring(data, "blt", to_integer(pc), rs1, rs2, imm_b), ' ', 40);
					when TYPE_BGE =>
						swrite(my_line, typeBRstring(data, "bge", to_integer(pc), rs1, rs2, imm_b));
						writeline(my_output, my_line);
						swrite(my_line, "");
						writeline(my_output, my_line);
						inst <= str_pad(typeBRstring(data, "bge", to_integer(pc), rs1, rs2, imm_b), ' ', 40);
					when TYPE_BLTU =>
						swrite(my_line, typeBRstring(data, "bltu", to_integer(pc), rs1, rs2, imm_b));
						writeline(my_output, my_line);
						swrite(my_line, "");
						writeline(my_output, my_line);
						inst <= str_pad(typeBRstring(data, "bltu", to_integer(pc), rs1, rs2, imm_b), ' ', 40);
					when TYPE_BGEU =>

					when others =>
				end case;

			when TYPE_ENV_BREAK_CSR =>
                case opcodes.funct12 is
                    when TYPE_MRET =>
                        swrite(my_line, "mret");
                        writeline(my_output, my_line);
                        swrite(my_line, "");
                        writeline(my_output, my_line);
                        inst <= str_pad("teste: mret", ' ', 40);
                    when others =>
                        case opcodes.funct3 is
                            when TYPE_EBREAK_ECALL =>
                                swrite(my_line, typeBRstring(data, "ebrake", to_integer(pc), rs1, rs2, imm_i));
                                writeline(my_output, my_line);
                                swrite(my_line, "");
                                writeline(my_output, my_line);
                                inst <= str_pad(typeBRstring(data, "ebrake", to_integer(pc), rs1, rs2, imm_i), ' ', 40);
                            when TYPE_CSRRW =>
                                swrite(my_line, typeBRstring(data, "csrrw", to_integer(pc), rs1, rs2, imm_i));
                                writeline(my_output, my_line);
                                swrite(my_line, "");
                                writeline(my_output, my_line);
                                inst <= str_pad(typeBRstring(data, "csrrw", to_integer(pc), rs1, rs2, imm_i), ' ', 40);
                            when TYPE_CSRRS =>
                                swrite(my_line, typeBRstring(data, "csrrs", to_integer(pc), rs1, rs2, imm_i));
                                writeline(my_output, my_line);
                                swrite(my_line, "");
                                writeline(my_output, my_line);
                                inst <= str_pad(typeBRstring(data, "csrrs", to_integer(pc), rs1, rs2, imm_i), ' ', 40);
                            when TYPE_CSRRC =>
                                swrite(my_line, typeBRstring(data, "csrrc", to_integer(pc), rs1, rs2, imm_i));
                                writeline(my_output, my_line);
                                swrite(my_line, "");
                                writeline(my_output, my_line);
                                inst <= str_pad(typeBRstring(data, "csrrc", to_integer(pc), rs1, rs2, imm_i), ' ', 40);
                            when TYPE_CSRRWI =>
                                swrite(my_line, typeBRstring(data, "csrrwi", to_integer(pc), rs1, rs2, imm_i));
                                writeline(my_output, my_line);
                                swrite(my_line, "");
                                writeline(my_output, my_line);
                                inst <= str_pad(typeBRstring(data, "csrrwi", to_integer(pc), rs1, rs2, imm_i), ' ', 40);
                            when TYPE_CSRRSI =>
                                swrite(my_line, typeBRstring(data, "csrrsi", to_integer(pc), rs1, rs2, imm_i));
                                writeline(my_output, my_line);
                                swrite(my_line, "");
                                writeline(my_output, my_line);
                                inst <= str_pad(typeBRstring(data, "csrrsi", to_integer(pc), rs1, rs2, imm_i), ' ', 40);
                            when TYPE_CSRRCI =>
                                swrite(my_line, typeBRstring(data, "csrrci", to_integer(pc), rs1, rs2, imm_i));
                                writeline(my_output, my_line);
                                swrite(my_line, "");
                                writeline(my_output, my_line);
                                inst <= str_pad(typeBRstring(data, "csrrci", to_integer(pc), rs1, rs2, imm_i), ' ', 40);
                            when others =>
                                swrite(my_line, typeBRstring(data, "TYPE_ENV_BREAK_CSR not reconized", to_integer(pc), rs1, rs2, imm_i));
                                writeline(my_output, my_line);
                                swrite(my_line, "");
                                writeline(my_output, my_line);
                                inst <= str_pad(typeBRstring(data, "TYPE_ENV_BREAK_CSR not reconized", to_integer(pc), rs1, rs2, imm_i), ' ', 40);
                        end case;
                end case;




			when others =>
		end case;
	end process;
end architecture RTL;
