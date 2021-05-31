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

use work.decoder_types.all;

--! iregister decodes (bit slicing) an instruction word into
--! several parameters (register addresses, call addresses,
--! immediates). See RV32I instruction format
entity iregister is
	port(
		clk : in std_logic;	--! Clock input
		rst : in std_logic;	--! Asynchronous reset
		
		data : in std_logic_vector(31 downto 0);
				
		opcodes : out opcodes_t;	--! Instruction decoding information. See decoder_types.vhd		
		
		-- opcode : out std_logic_vector(6 downto 0);	--! Instruction opcode
		-- funct3 : out std_logic_vector(2 downto 0);	--! Instruction function: 7 bits
		-- funct7 : out std_logic_vector(6 downto 0);	--! Instruction function: 3 bits
		
		rd  : out unsigned(4 downto 0);		--! Register address destination
		rs1 : out unsigned(4 downto 0);		--! Register address source operand 1
		rs2 : out unsigned(4 downto 0);		--! Register address source operand 2
		
		imm_i : out signed(31 downto 0);	--! Immediate for I-type instruction
		imm_s : out integer;	--! Immediate for S-type instruction
		imm_b : out integer;	--! Immediate for B-type instruction		
		imm_u : out integer;	--! Immediate for U-type instruction
		imm_j : out integer		--! Immediate for J-type instruction				
	);
end entity iregister;

architecture RTL of iregister is
	
	
begin
	--! @brief Decoder process. Must be synchronous for registers generation
	p1: process (rst, clk)
	begin
		if rst = '1' then
			opcodes.opcode <= (others => '0');
			opcodes.funct3 <= (others => '0');
			opcodes.funct7 <= (others => '0');
			opcodes.funct12 <= (others => '0');
			
			rd <= (others => '0');
			rs1 <= (others => '0');
			rs2 <= (others => '0');
			
			imm_i <= (others => '0');
			imm_s <= 0;
			imm_b <= 0;	
			imm_u <= 0;
			imm_j <= 0;
		else
			if rising_edge(clk) then
				opcodes.opcode <= data (6 downto 0);				
				opcodes.funct3 <= data(14 downto 12);
				opcodes.funct7 <= data(31 downto 25);
				opcodes.funct12 <= data(31 downto 20);
				
				rd  <= unsigned(data(11 downto 7));
				rs1 <= unsigned(data(19 downto 15));
				rs2 <= unsigned(data(24 downto 20));
			
				if data(31) = '0' then			
				    imm_i <= x"00000" & signed(data(31 downto 20));
				else
				    imm_i <= x"fffff" & signed(data(31 downto 20));
				end if;
				
				imm_s <= to_integer(signed(data(31 downto 25) & data(11 downto 7)));			
				imm_b <= to_integer(signed(data(31) & data(7) & data(30 downto 25) & data(11 downto 8) & '0'));				
				imm_u <= to_integer(signed(data(31 downto 12) & "000000000000"));
				imm_j <= to_integer(signed(data(31) &  data(19 downto 12) & data(20) & data(30 downto 21) & '0'));
				
			end if;
		end if;
	end process;
end architecture RTL;
