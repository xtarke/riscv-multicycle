library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.decoder_types.all;
use work.alu_types.all;

entity core is
	generic (
		--! Num of 32-bits memory words 
		IMEMORY_WORDS : integer := 1024;
		DMEMORY_WORDS : integer := 512
	);
	port(
		clk : in std_logic;
		rst : in std_logic;
		
		iaddress  : out  integer range 0 to IMEMORY_WORDS-1;
		idata	  : in 	std_logic_vector(31 downto 0);
		
		daddress  : out  integer range 0 to DMEMORY_WORDS-1;
		
		ddata_r	  : in 	std_logic_vector(31 downto 0);
		ddata_w   : out	std_logic_vector(31 downto 0);
		d_we      : out std_logic;
		d_rd	  : out std_logic;
		dcsel	  : out std_logic_vector(1 downto 0);	--! Chip select 
		dmask     : out std_logic_vector(3 downto 0)	--! Byte enable mask 
	);
end entity core;

architecture RTL of core is
	
	component iregister
		port(
			clk    : in  std_logic;
			rst    : in  std_logic;
			data   : in  std_logic_vector(31 downto 0);
			opcodes : out opcodes_t;		
			rd     : out integer range 0 to 31;
			rs1    : out integer range 0 to 31;
			rs2    : out integer range 0 to 31;
			imm_i  : out integer;
			imm_s  : out integer;
			imm_b  : out integer;
			imm_u  : out integer;
			imm_j  : out integer
		);
	end component iregister;
	
	component register_file
	port(
		clk        : in  std_logic;
		rst        : in  std_logic;
		w_ena      : in  std_logic;
		w_address  : in  integer range 0 to 31;
		w_data     : in  std_logic_vector(31 downto 0);
		r1_address : in  integer range 0 to 31;
		r1_data    : out std_logic_vector(31 downto 0);
		r2_address : in  integer range 0 to 31;
		r2_data    : out std_logic_vector(31 downto 0)
	);
	end component register_file;
		
	component decoder
		port(
			clk          : in  std_logic;
			rst          : in  std_logic;
			dmemory      : out mem_ctrl_t;
			opcodes      : in  opcodes_t;
			bus_lag      : in  std_logic;
			jumps        : out jumps_ctrl_t;
			ulaMuxData   : out std_logic_vector(1 downto 0);
			ulaCod       : out std_logic_vector(3 downto 0);
			writeBackMux : out std_logic_vector(2 downto 0);
			reg_write    : out std_logic
		);
	end component decoder;
	
	component ULA
		port(
			alu_data : in  alu_data_t;
			dataOut  : out integer
		);
	end component ULA;
	
	signal pc      : std_logic_vector(31 downto 0);
	signal next_pc : std_logic_vector(31 downto 0);
	signal opcodes : opcodes_t;

	signal rd     :  integer range 0 to 31;
	signal rs1    :  integer range 0 to 31;
	signal rs2    :  integer range 0 to 31;
	signal imm_i  :  integer;
	signal imm_s  :  integer;
	signal imm_b  :  integer;
	signal imm_u  :  integer;
	signal imm_j  :  integer;
	
	signal rf_w_ena : std_logic;
	signal rw_data	: std_logic_vector(31 downto 0);
	signal rs1_data	: std_logic_vector(31 downto 0);
	signal rs2_data	: std_logic_vector(31 downto 0);
	
	--! Signals for alu control
	signal alu_data : alu_data_t;
	signal alu_out : integer;
	
	--! Controls signals
	signal jumps : jumps_ctrl_t;	
	
	
	signal ulaMuxData : std_logic_vector(1 downto 0);
	signal writeBackMux : std_logic_vector(2 downto 0);
	
	signal dmemory : mem_ctrl_t;
		
	signal jal_target : integer;	--!= Target address for jump instruction 
	signal jalr_target : integer;	--!= Target address for jalr instruction
	signal auipc_offtet : integer;	--!= PC plus offset for aiupc instruction

	signal branch_cmp : std_logic;
	signal bus_lag : std_logic;
		
begin
	
	pc_blk: block
	begin		
		
		next_pc <= std_logic_vector(to_unsigned(to_integer(signed(pc)) + 4,32));
		
		pc_proc: process (clk, rst)
		begin			
			if rst = '1' then 
				pc <= (others => '0');
			else
				if rising_edge(clk) then
					if jumps.inc = '1' then
						pc <= next_pc;
					 elsif jumps.load = '1' then						
						case jumps.load_from is 
							when "00" =>
								pc <= std_logic_vector(to_unsigned(jal_target,32));
							
							when "01" =>
								if branch_cmp = '1' then
									pc <= std_logic_vector(to_unsigned(to_integer(signed(pc)) + imm_b,32));						
								else
									pc <= next_pc;
								end if;	
								
							when "11" =>
								pc <= std_logic_vector(to_unsigned(jalr_target,32));							
							
							when others =>
								report "Not implemented" severity Failure;
						end case;						
					
					end if;
				end if;
			end if;			
		end process;
		
		jal_target <= to_integer(signed(pc)) + imm_j;
		auipc_offtet <= to_integer(signed(pc)) + imm_u;
		jalr_target <= to_integer(signed(rs1_data)) + imm_i;
		
		iaddress <= to_integer(unsigned(pc(16 downto 2)));	
	end block;
	
	
	branch_unit: block
	begin	
		cmp_prc: process(opcodes, rs1_data, rs2_data)
		begin		
				branch_cmp <= '0';
				
				case opcodes.funct3 is
					when TYPE_BEQ =>
						if rs1_data = rs2_data then
							branch_cmp <= '1';											
						end if;	
					when TYPE_BNE => 
						if rs1_data /= rs2_data then
							branch_cmp <= '1';											
						end if;
					when TYPE_BLT => 
						if (to_integer(signed(rs1_data)) < (to_integer(signed(rs2_data)))) then
							branch_cmp <= '1';											
						end if;	
					when TYPE_BGE => 
						if (to_integer(signed(rs1_data)) >= (to_integer(signed(rs2_data)))) then
							branch_cmp <= '1';											
						end if;		
					when TYPE_BLTU =>						
						if (to_integer(unsigned(rs1_data)) < (to_integer(unsigned(rs2_data)))) then
							branch_cmp <= '1';											
						end if;		
					
					when TYPE_BGEU =>						
						if (to_integer(unsigned(rs1_data)) >= (to_integer(unsigned(rs2_data)))) then
							branch_cmp <= '1';											
						end if;
					
					when others =>
				end case;		
		end process;		
	end block;
		
	ireg: component iregister
		port map(
			clk    => clk,
			rst    => rst,
			data   => idata,
			opcodes => opcodes,
			rd     => rd,
			rs1    => rs1,
			rs2    => rs2,
			imm_i  => imm_i,
			imm_s  => imm_s,
			imm_b  => imm_b,
			imm_u  => imm_u,
			imm_j  => imm_j
		);
		
	registers: component register_file
		port map(
			clk        => clk,
			rst        => rst,
			w_ena      => rf_w_ena,
			w_address  => rd,
			w_data     => rw_data,
			r1_address => rs1,
			r1_data    => rs1_data,
			r2_address => rs2,
			r2_data    => rs2_data
		);
		
	writeBackMuxBlock: block 
	begin
		with writeBackMux select
			rw_data <= std_logic_vector(to_signed(alu_out,32)) when "000",
			           std_logic_vector(to_signed(imm_u,32))   when "001",
			           std_logic_vector(to_signed(auipc_offtet,32)) when "010",
			           next_pc when "011",
			           ddata_r when "100",
			           std_logic_vector(to_signed(imm_i,32))   when others;
		
	end block;
			
	decoder0: component decoder
		port map(
			clk        => clk,
			rst        => rst,
			jumps	   => jumps,
			opcodes    => opcodes,
			ulaMuxData => ulaMuxData,
			ulaCod     => alu_data.code,
			bus_lag    => bus_lag,
			
			dmemory => dmemory,
			
			writeBackMux => writeBackMux,
			reg_write  => rf_w_ena
		);
	
	
	
	alu_0: component ULA
		port map(
			alu_data => alu_data,
			dataOut  => alu_out
		);
	
	alu_data.a <= to_integer(signed(rs1_data));
	
	aluMuxBlock: block 
	begin
		with ulaMuxData select
			alu_data.b <= to_integer(signed(rs2_data)) when "00",
			              imm_i   when "01",
			              imm_b   when others;		
	end block;
	
	memAddrTypeSBlock: block 
		signal addr : std_logic_vector(31 downto 0);
		signal byteSel: std_logic_vector(1 downto 0);
		signal dcsel_block   :  std_logic_vector(1 downto 0);	--! Chip select
	begin
		-- != Load and Store instructions have different address generation 
		with dmemory.read select
			addr <= std_logic_vector(to_signed(to_integer(signed(rs1_data)) + imm_i,32)) when '1',   -- to_unsigned
				    std_logic_vector(to_signed(to_integer(signed(rs1_data)) + imm_s,32)) when others;		-- to_unsigned
		
		byteSel <= addr(1 downto 0);
		daddress <= to_integer(unsigned(addr(11 downto 2)));
		
		ddata_w <= rs2_data;		--! Data to write
		d_we <= dmemory.write;		--! Write signal
		d_rd <= dmemory.read;		--! Read signal
				
		bus_lag <= not addr(17);	--! Stall another cycle when reading from imem
				
		-- Address space (check sections.ld):
		-- 0x00000    ->    0b000 0000 0000 0000 0000
		-- 0x20000    ->    0b010 0000 0000 0000 0000
		-- 0x40000    ->    0b100 0000 0000 0000 0000		
		dcsel <= addr(18 downto 17);
				
		--! Chip Select
		--with addr(17) select
		--	dcsel_block <= "01"  when '0',
		--	         "10" when '1',
		--	         "00" when others;
				
		dmaskGen: process(dmemory, byteSel)
		begin
			dmask <= "0000";
			
			case dmemory.word_size is 
				when "00" =>
					dmask <= "1111";
					
--					if dmemory.write = '1' then
--						if byteSel /= "00" then								
--							report "Word Address not aligned!" severity Failure;
--						end if;
--					end if;
				
				when "01" =>					
					case byteSel is
						when "00" => 
							dmask <= "0001";				
						when "01" => 
							dmask <= "0010";		
						when "10" => 
							dmask <= "0100";							
						when "11" => 
							dmask <= "1000";							
						when others =>
					end case;			
					
				when others => 	
					if dmemory.write = '1' then					
						report "Not implemented" severity Failure;
					end if;	
									
			end case;
		end process;
		
		debug: process(pc)
		begin
		
			if pc = x"00000010" then
			--	report "debug Abort" severity Failure;
			end if;
			
		end process;
		
		
		
	end block;
		
	

end architecture RTL;

