library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.decoder_types.all;
use work.alu_types.all;
use work.M_types.all;

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

		daddress  : out  natural;

		ddata_r	  : in 	std_logic_vector(31 downto 0);
		ddata_w   : out	std_logic_vector(31 downto 0);
		d_we      : out std_logic;
		d_rd	  : out std_logic;
		d_sig     : out std_logic;						--! Signal extension
		dcsel	  : out std_logic_vector(1 downto 0);	--! Chip select
		dmask     : out std_logic_vector(3 downto 0);	--! Byte enable mask
	    
		interrupts:std_logic_vector(31 downto 0);
		
		state	  : out cpu_state_t    

	);
end entity core;

architecture RTL of core is

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
	signal alu_out : signed(31 downto 0);

	--! Signals for M control
	signal M_data : M_data_t;
	signal M_out : std_logic_vector(31 downto 0);

	--! Control flow signals signals
	signal jumps : jumps_ctrl_t;


	signal ulaMuxData : std_logic_vector(1 downto 0);
	signal writeBackMux : std_logic_vector(2 downto 0);

	signal dmemory : mem_ctrl_t;

	signal jal_target : integer;	--!= Target address for jump instruction
	signal jalr_target : integer;	--!= Target address for jalr instruction
	signal auipc_offtet : integer;	--!= PC plus offset for aiupc instruction

	signal branch_cmp : std_logic;
	signal bus_lag : std_logic;
	
	signal pending : std_logic;
	signal csr_write : std_logic;
	signal csr_load_imm: std_logic;
	signal csr_value : std_logic_vector(31 downto 0);
	signal mepc : std_logic_vector(31 downto 0);
	signal csr_new : std_logic_vector(31 downto 0);
	signal load_mepc: std_logic;
  signal mretpc : std_logic_vector(31 downto 0);
  signal mret : std_logic;    

begin

	pc_blk: block
  begin

        next_pc <= std_logic_vector(to_unsigned(to_integer(signed(pc)) + 4,32));

        pc_proc: process (clk, rst)
            variable pc_holder : std_logic_vector(31 downto 0);
        begin
            if rst = '1' then
                pc_holder := (others => '0');
                mretpc <= (others => '0');
            else
                if rising_edge(clk) then

                    if jumps.inc = '1' then         -- Calculate next pc
                        pc_holder := next_pc;
                    elsif jumps.load = '1' then
                        case jumps.load_from is
                            when "00" =>
                                pc_holder := std_logic_vector(to_unsigned(jal_target,32));
                            when "01" =>
                                if branch_cmp = '1' then
                                    pc_holder := std_logic_vector(to_unsigned(to_integer(signed(pc)) + imm_b,32));
                                else
                                    pc_holder := next_pc;
                                end if;
                                            
                            when "11" =>
                                pc_holder := std_logic_vector(to_unsigned(jalr_target,32));
                            when others =>
                                report "Not implemented" severity Failure;
                        end case;
                    
                    end if;
                    
                    mretpc<=pc_holder;      -- mretpc recieve the next calculated pc
                    
                    if (load_mepc = '1')then
                        pc_holder:= mepc;   
                    end if;
                    pc <=pc_holder;         -- pc recieve the next calculated pc or index of iqr handler
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
		
	with csr_load_imm select               -- Select between rs1 value and immediate 
	       csr_new <=  rs1_data when '0',
	                   Std_logic_vector(to_unsigned(rs1,32))  when '1',
	                   (others => '0') when others;
	
	
    ins_csr: entity work.csr
        port map(
            clk        => clk,
            rst        => rst,
            pending_inst    => pending,
            write      => csr_write,
            next_pc    => mretpc,
            csr_addr   => imm_i,
            csr_new    => csr_new,
            opcodes    => opcodes,
            mret       => mret,
            interrupts => interrupts,
            csr_value  => csr_value,
            load_mepc  => load_mepc,
            mepc_out   => mepc
        );
		
	ins_register: entity work.iregister
		port map(
			clk     => clk,
			rst     => rst,
			data    => idata,
			opcodes => opcodes,
			rd      => rd,
			rs1     => rs1,
			rs2     => rs2,
			imm_i   => imm_i,
			imm_s   => imm_s,
			imm_b   => imm_b,
			imm_u   => imm_u,
			imm_j   => imm_j
		);


	registers: entity work.register_file
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
			rw_data <= std_logic_vector(alu_out) 			        when "000",
			           std_logic_vector(to_signed(imm_u,32))        when "001",
			           std_logic_vector(to_signed(auipc_offtet,32)) when "010",
			           next_pc 									    when "011",
			           ddata_r 									    when "100",
			           M_out				 			       		when "101",
			           csr_value                                    when "111",
			           std_logic_vector(to_signed(imm_i,32))   		when others;

	end block;

	decoder0: entity work.decoder
		port map(
			clk          => clk,
			rst          => rst,
			dmemory      => dmemory,
			opcodes      => opcodes,
			bus_lag      => bus_lag,
			jumps        => jumps,
			ulaMuxData   => ulaMuxData,
			ulaCod       => alu_data.code,
			M_Cod        => M_data.code,
			writeBackMux => writeBackMux,
			reg_write    => rf_w_ena,
			cpu_state    => state,
			csr_write    => csr_write,
			csr_load_imm => csr_load_imm,
			mret         => mret,
			pending_inst => pending
		);


	alu_0: entity work.ULA
		port map(
			alu_data => alu_data,
			dataOut  => alu_out
		);

	alu_data.a <= (signed(rs1_data));

	aluMuxBlock: block
	begin
		with ulaMuxData select
			alu_data.b <= (signed(rs2_data)) when "00",
			              to_signed(imm_i,32)   when "01",
			              to_signed(imm_b,32)   when others;
	end block;

	M_0: entity work.M
		port map(
			M_data   => M_data,
			dataOut  => M_out
		);

	M_data.a <= (signed(rs1_data));
	M_data.b <= (signed(rs2_data));

	memAddrTypeSBlock: block
		signal addr : std_logic_vector(31 downto 0);
		signal byteSel: std_logic_vector(1 downto 0);
	begin
		-- != Load and Store instructions have different address generation
		with dmemory.read select
			addr <= std_logic_vector(to_signed(to_integer(signed(rs1_data)) + imm_i,32)) when '1',   -- to_unsigned
				    std_logic_vector(to_signed(to_integer(signed(rs1_data)) + imm_s,32)) when others;		-- to_unsigned

		byteSel <= addr(1 downto 0);
		daddress <= to_integer(unsigned(addr(31 downto 2)));

		ddata_w <= rs2_data;		 --! Data to write
		d_we <= dmemory.write;		 --! Write signal
		d_rd <= dmemory.read;		 --! Read signal
		d_sig <= dmemory.signal_ext; --! for byte and halfword loads

		bus_lag <= not addr(25);	--! Stall another cycle when reading from imem

		-- Address space (check sections.ld) and chip select:
		-- 0x0000000000 ->  0b000 0000 0000 0000 0000 0000 0000
		-- 0x0002000000 ->  0b010 0000 0000 0000 0000 0000 0000
		-- 0x0004000000 ->  0b100 0000 0000 0000 0000 0000 0000
		-- 0x0006000000 ->  0b110 0000 0000 0000 0000 0000 0000
		dcsel <= addr(26 downto 25);

		--! Byte sel mask generation
		dmaskGen: process(dmemory, byteSel)
		begin
			dmask <= "0000";

			case dmemory.word_size is
				when "00" =>
					dmask <= "1111";
				when "01" =>
					case byteSel is
						when "00" =>
							dmask <= "0011";
						when "10" =>
							dmask <= "1100";
						when others =>
					end case;
				when "11" =>
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
	end block;

end architecture RTL;
