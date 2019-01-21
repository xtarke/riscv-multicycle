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
		
		-- Jump and branches signals
		jumps : out jumps_ctrl_t;	
		
		-- ULA signals
		ulaMuxData  : out std_logic_vector(1 downto 0);
		ulaCod		: out std_logic_vector(2 downto 0);
		
		--! Write back contrl
		
		writeBackMux: out std_logic_vector(2 downto 0);
		reg_write	: out std_logic
		
		-- Comparator signals
--		compResult	: in std_logic;
--		compMux		: out std_logic
				


	);
end entity decoder;

architecture RTL of decoder is
	type state_type is (READ, FETCH, DECODE, EXE_ALU, ST_TYPE_JAL, 
		ST_TYPE_AUIPC, ST_TYPE_I, ST_TYPE_U, ST_TYPE_S, ST_BRANCH, LW_SW, LW_SW2, WRITEBACK, ERROR
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
						when TYPE_JAL => state <= ST_TYPE_JAL;
						when TYPE_BRANCH => state <= ST_BRANCH;
						
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
				
				when LW_SW =>
					state <= LW_SW2;
				when LW_SW2 =>
					state <= READ;
				when ERROR =>
					state <= ERROR;
				when WRITEBACK => 
					state <= FETCH;
				
			end case;
		end if;
	end process;
	
	moore : process(state, opcodes) is
	begin
--		rd_rom <= '0';
--		--ir_load <= '0';
--		br_w_ena 	<= '0';
		ulaMuxData <= "00";
		
		jumps.inc <= '0';
		jumps.load <= '0';
		jumps.load_from <= "00";
		
		writeBackMux <= "000";
		reg_write <= '0';
				
--		pc_load <= '0';
--		br_ula_mux <= MUX_BR_ULA;
--		ram_r_en <= '0';
--		ram_w_en <= '0';
--		ulaCod <= (others => '1');
--		compMux <= MUX_COMP_0;
--		pcMux	<= PC_DT_PSEUDO;

		ulaCod <= (others => '0');
		
		-- !Memory interface default signal values
		dmemory.read  <= '0';
		dmemory.write <= '0';
		dmemory.word_size <= "00";	

		
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
						report "Not implemented" severity Failure;
					when TYPE_ORI =>
						report "Not implemented" severity Failure;
					when TYPE_ANDI =>
						report "Not implemented" severity Failure;
					
					when TYPE_SLLI =>
						ulaMuxData <= "01";	
						ulaCod <= ALU_SLL;
											
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
					when others =>						
				end case;
				
				jumps.inc <= '1';
				reg_write <= '1';				
				
				
			when ST_TYPE_S =>
				
				case opcodes.funct3 is
					when TYPE_SB =>
						report "Not implemented" severity Failure;
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
			
			when LW_SW =>
				
			when LW_SW2 =>
				
			when ERROR =>
				report "Not implemented" severity Failure;
				
			when WRITEBACK => 
				
				
				
						
		end case;
		
	end process moore;

end architecture RTL;
