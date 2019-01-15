library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

use work.alu_types.all;
use work.decoder_types.all;

entity decoder is
	port(
		clk : in std_logic;
		rst : in std_logic;
		
		-- PC signals
	 	pc_inc	: out std_logic;
	 	pc_load : out std_logic;
	 	pcMux	: out std_logic;
		-- pc_load	: out std_logic_vector(31 downto 0);
		
		-- RAM signals
		--ram_w_en	: out std_logic;
		--ram_r_en	: out std_logic;
			
		-- IR signals
		opcodes : in opcodes_t;		--! Instruction decoding information. See decoder_types.vhd		
		
		-- BR signals		
--		br_w_ena 	: out std_logic;
--		br_ula_mux	: out std_logic;
		
		-- ULA signals
		ulaMuxData  : out std_logic_vector(1 downto 0);
		ulaCod		: out std_logic_vector(2 downto 0);
		
		reg_write	: out std_logic
		
		-- Comparator signals
--		compResult	: in std_logic;
--		compMux		: out std_logic
				


	);
end entity decoder;

architecture RTL of decoder is
	type state_type is (READ, FETCH, DECODE, EXE_ALU, BEQ, BLEZ, BRANCH_JUMP, LOAD_IME, MUL_OP, JUMP, LW_SW, LW_SW2, WRITEBACK, ERROR);
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
						when TYPE_R => state <= EXE_ALU;
						
						when others => state <= ERROR;
					end case;
				
				
				
				
				
				when BEQ =>
--					if compResult = '1' then
--						state <= BRANCH_JUMP;
--					else
--						state <= READ;
--					end if;					
				when BLEZ =>
--					if compResult = '1' then
--						state <= BRANCH_JUMP;
--					else
--						state <= READ;
					-- end if;
				when BRANCH_JUMP =>
					state <= READ;
				when EXE_ALU =>
					
					state <= WRITEBACK;
					
					
					
				when LOAD_IME =>
					state <= READ;
				when MUL_OP =>
					state <= READ;
				when JUMP =>
					state <= READ;
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
--		ulaMuxData <= MUX_ULA_R;
		pc_inc <= '0';
		
		reg_write <= '0';
				
--		pc_load <= '0';
--		br_ula_mux <= MUX_BR_ULA;
--		ram_r_en <= '0';
--		ram_w_en <= '0';
--		ulaCod <= (others => '1');
--		compMux <= MUX_COMP_0;
--		pcMux	<= PC_DT_PSEUDO;

		ulaCod <= (others => '0');

		
		case state is 
			when READ =>
				
			when FETCH=>
				
			when DECODE =>
			
			when BEQ =>
				
			when BLEZ =>
				
			when BRANCH_JUMP =>
				
				
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
				
				pc_inc <= '1';
				reg_write <= '1';				
				
				
			when MUL_OP =>
			
			
			when LOAD_IME =>
				
			when JUMP =>				
			
			when LW_SW =>
				
			when LW_SW2 =>
				
			when ERROR =>
				
				
			when WRITEBACK => 
				
				
				
						
		end case;
		
	end process moore;

end architecture RTL;
