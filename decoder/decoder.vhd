library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

use work.alu_types.all;
use work.decoder_types.all;

entity decoder is
	port(
		clk : in std_logic;
		rst : in std_logic;
		
		-- RAM signals
		dmemory : out mem_ctrl_t;
			
		-- IR signals
		opcodes : in opcodes_t;		--! Instruction decoding information. See decoder_types.vhd	
		
		-- bus lag
		bus_lag : in std_logic;
		
		-- Jump and branches signals
		jumps : out jumps_ctrl_t;	
		
		-- ULA signals
		ulaMuxData  : out std_logic_vector(1 downto 0);
		ulaCod		: out std_logic_vector(3 downto 0);
		
		--! Write back contrl		
		writeBackMux: out std_logic_vector(2 downto 0);
		reg_write	: out std_logic;
		
		cpu_state	  : out cpu_state_t 
		
		-- Comparator signals
--		compResult	: in std_logic;
--		compMux		: out std_logic
				


	);
end entity decoder;

architecture RTL of decoder is
	type state_type is (READ, FETCH, DECODE, EXE_ALU, ST_TYPE_JAL, 
		ST_TYPE_AUIPC, ST_TYPE_I, ST_TYPE_U, ST_TYPE_S, ST_BRANCH, ST_TYPE_JALR, ST_TYPE_L, 
		WRITEBACK, WRITEBACK_MEM, ERROR, HALT
	);
	signal state : state_type := READ;

	
begin
	
	--! State transition process: instruction decoding. 
	states: process(clk, rst) is		
	begin
		if rst = '1' then
			state <= READ;
		elsif rising_edge(clk) then
			case state is
				when READ =>
					state <= FETCH;
				when FETCH =>
					state <= DECODE;
				when DECODE =>
					case opcodes.opcode is
						when TYPE_I => state <= ST_TYPE_I;			
						when TYPE_AUIPC => state <= ST_TYPE_AUIPC;
						when TYPE_LUI => state <= ST_TYPE_U;						
						when TYPE_R => state <= EXE_ALU;
						when TYPE_S =>  state <= ST_TYPE_S;		
						when TYPE_L =>  state <= ST_TYPE_L;
						when TYPE_JAL => state <= ST_TYPE_JAL;
						when TYPE_JALR => state <= ST_TYPE_JALR;
						when TYPE_BRANCH => state <= ST_BRANCH;
						when TYPE_ENV_BREAK => state <= HALT;						
						when others => state <= ERROR;
					end case;
			
				when ST_TYPE_JAL =>
					state <= WRITEBACK;
				when ST_TYPE_AUIPC =>
					state <= WRITEBACK;
				when ST_TYPE_I =>
					state <= WRITEBACK;				
				when EXE_ALU =>					
					state <= WRITEBACK;				
				when ST_TYPE_U =>
					state <= WRITEBACK;
				when ST_TYPE_S =>
					state <= WRITEBACK;
				when ST_BRANCH =>
					state <= WRITEBACK;				
				when ST_TYPE_JALR =>
					state <= WRITEBACK;
				when ST_TYPE_L =>
					state <= WRITEBACK_MEM;				
				when ERROR =>
					state <= ERROR;
				when WRITEBACK => 
					state <= FETCH;
				when WRITEBACK_MEM =>
					
					if (bus_lag = '0') then
						state <= FETCH;
					else
						state <= READ;
					end if;
				when HALT =>
				
			end case;
		end if;
	end process;
	
	moore : process(state, opcodes) is
	begin
		ulaMuxData <= "00";
		
		-- !Control flow default signal values
		jumps.inc <= '0';
		jumps.load <= '0';
		jumps.load_from <= "00";
		
		writeBackMux <= "000";
		reg_write <= '0';
				
		ulaCod <= (others => '0');
		
		-- !Memory interface default signal values
		dmemory.read  <= '0';
		dmemory.write <= '0';
		dmemory.word_size <= "00";	

		cpu_state.halted <= '0';
		cpu_state.error  <= '0';
		
		case state is 
			when READ =>
				
			when FETCH=>
				
			when DECODE =>
			
			when ST_TYPE_JAL =>
				jumps.load <= '1';
				jumps.load_from <= "00";
				writeBackMux <= "011";
				reg_write <= '1';					
				
			when ST_TYPE_AUIPC =>
				writeBackMux <= "010";
				jumps.inc <= '1';
				reg_write <= '1';			
				
			when ST_TYPE_I =>
				case opcodes.funct3 is
					when TYPE_ADDI =>
						ulaMuxData <= "01";	
						ulaCod <= ALU_ADD;
										
					when TYPE_SLTI =>
						report "Not implemented" severity Failure;
					when TYPE_SLTIU =>
						report "Not implemented" severity Failure;
					when TYPE_XORI =>
						ulaMuxData <= "01";	
						ulaCod <= ALU_XOR;
					when TYPE_ORI =>
						ulaMuxData <= "01";	
						ulaCod <= ALU_OR;
					
					when TYPE_ANDI =>
						ulaMuxData <= "01";	
						ulaCod <= ALU_AND;
					
					when TYPE_SLLI =>
						ulaMuxData <= "01";	
						ulaCod <= ALU_SLL;
					when TYPE_SR =>
						case opcodes.funct7 is
							when TYPE_SRLI =>
								ulaMuxData <= "01";	
								ulaCod <= ALU_SRL;								
							when TYPE_SRAI =>
								ulaMuxData <= "01";	
								ulaCod <= ALU_SRA;								
							when others =>
						end case;
						
											
					when others =>
						report "Not implemented" severity Failure;				
				end case;				
				
				--writeBackMux <= "001";
				jumps.inc <= '1';
				reg_write <= '1';	
				
				
			when EXE_ALU =>
				
				case opcodes.funct3 is
					when TYPE_ADD_SUB =>					
						if opcodes.funct7 = TYPE_ADD then
							ulaCod <= ALU_ADD;
						else
							ulaCod <= ALU_SUB;
						end if;
						
					when TYPE_AND =>
						ulaCod <= ALU_AND;	
										
					when TYPE_SLL =>
						ulaCod <= ALU_SLL;
					
					when TYPE_XOR =>
						ulaCod <= ALU_XOR;
										
					when others =>		
						report "Not implemented" severity Failure;				
				end case;
				
				jumps.inc <= '1';
				reg_write <= '1';				
				
				
			when ST_TYPE_S =>
				
				case opcodes.funct3 is
					when TYPE_SB =>
						dmemory.write <= '1';
						dmemory.word_size <= "01";	
						-- report "Not implemented" severity Failure;
					when TYPE_SH =>
						report "Not implemented" severity Failure;
					when TYPE_SW =>
						dmemory.write <= '1';
						dmemory.word_size <= "00";	
					when others =>	
				end case;
				
				jumps.inc <= '1';				
			
			when ST_TYPE_U =>
				writeBackMux <= "001";
				jumps.inc <= '1';
				reg_write <= '1';	
				
				
			when ST_BRANCH =>	
				jumps.load <= '1';
				jumps.load_from <= "01";			
			
			when ST_TYPE_JALR =>
				jumps.load <= '1';
				jumps.load_from <= "11";	
				
			when ST_TYPE_L =>
				case opcodes.funct3 is
					when TYPE_LB =>
						report "Not implemented" severity Failure;	
					when TYPE_LH =>
						report "Not implemented" severity Failure;
					when TYPE_LW =>
						dmemory.read <= '1';
						dmemory.word_size <= "00";	
					when others =>	
				end case;
				
				jumps.inc <= '1';				
				
			when ERROR =>
				cpu_state.error  <= '0';
				report "Not implemented" severity Failure;
			
			when HALT =>
				cpu_state.halted <= '0';
				report "Simulation success!" severity Failure;
				
			when WRITEBACK => 
				
			when WRITEBACK_MEM =>
				writeBackMux <= "100";
				reg_write <= '1';
				dmemory.read <= '1';					
		end case;
		
	end process moore;

end architecture RTL;
