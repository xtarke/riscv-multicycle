library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.cpu_typedef_package.all;

entity sdram_controller is 
	
	-- Altera SDRAM controller configuration
	generic (
         ASIZE          : integer := 23;
         DSIZE          : integer := 32;
         ROWSIZE        : integer := 12;
         COLSIZE        : integer := 9;
         BANKSIZE       : integer := 2;
         ROWSTART       : integer := 9;
         COLSTART       : integer := 0;
         BANKSTART      : integer := 20
    );
	 
	
	port (
	  -- inputs:
	  address 		: IN STD_LOGIC_VECTOR (DATA_ADDR_SIZE-1 DOWNTO 0);
	  byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
	  chipselect 	: IN STD_LOGIC;
	  clk 					: IN STD_LOGIC;
	  clken 				: IN STD_LOGIC;
	  reset 				: IN STD_LOGIC;
	  reset_req 	: IN STD_LOGIC;
	  write 				: IN STD_LOGIC;
	  writedata 		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
	
	  -- outputs:
	  readdata 		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
	  waitrequest : out std_logic;
	  
	 DRAM_ADDR :  out std_logic_vector( 12  downto 0  );
    DRAM_BA :  out std_logic_vector( 1  downto 0  );
    DRAM_CAS_N :  out std_logic;
    DRAM_CKE :  out std_logic;
    DRAM_CLK :  out std_logic;
    DRAM_CS_N :  out std_logic;
    DRAM_DQ :  inout std_logic_vector( 31  downto 0  );
    DRAM_DQM :  out std_logic_vector( 3  downto 0  );
    DRAM_RAS_N :  out std_logic;
    DRAM_WE_N :  out std_logic
);
end entity sdram_controller;

architecture rtl of sdram_controller is

	-- altera sdram controller
	component sdr_sdram
	port (
         CLK            : in      std_logic;                                 					  --System Clock
         RESET_N        : in      std_logic;                                 			  --System Reset
         ADDR           : in      std_logic_vector(ASIZE-1 downto 0);          --Address for controller requests
         CMD            : in      std_logic_vector(2 downto 0);                --Controller command 
         CMDACK         : out     std_logic;                                   --Controller command acknowledgement
         DATAIN         : in      std_logic_vector(DSIZE-1 downto 0);          --Data input
         DATAOUT        : out     std_logic_vector(DSIZE-1 downto 0);          --Data output
         DM             : in      std_logic_vector(DSIZE/8-1 downto 0);        --Data mask input
			
         SA             : out     std_logic_vector(11 downto 0);               --SDRAM address output
         BA             : out     std_logic_vector(1 downto 0);                --SDRAM bank address
         CS_N           : out     std_logic_vector(1 downto 0);                --SDRAM Chip Selects
         CKE            : out     std_logic;                                   --SDRAM clock enable
         RAS_N          : out     std_logic;                                   --SDRAM Row address Strobe
         CAS_N          : out     std_logic;                                   --SDRAM Column address Strobe
         WE_N           : out     std_logic;                                   --SDRAM write enable
         DQ             : inout   std_logic_vector(DSIZE-1 downto 0);          --SDRAM data bus
         DQM            : out     std_logic_vector(DSIZE/8-1 downto 0)         --SDRAM data mask lines
  	);
	end component;
	
		

	component tristate
	PORT (
		mybidir 		: INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		myinput 		: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		myenable 	: IN STD_LOGIC
	);
	end component tristate;

	type mem_state_type is (CONFIG, C_PRE, C_LD, C_REG1, C_REG2, IDLE, READ_M, WRITE_M, RW_NOP, RW_PRE, DONE, NOP);
	signal mem_state : mem_state_type;

	signal d_read : std_logic;
	signal d_write : std_logic;
	
	signal mem_data : word_t;
	
	signal byteenable_reg : STD_LOGIC_VECTOR (3 DOWNTO 0);
	
	signal in_reg_en : std_logic;
		
	signal  chip_en_reg : std_logic;	
	
	-- sdram controller signal
	signal reset_n : std_logic;
	signal addr : std_logic_vector(ASIZE-1 downto 0);
	signal cmd :  std_logic_vector(2 downto 0);
	signal cmdack : std_logic;
	signal datain : std_logic_vector(DSIZE-1 downto 0);
	signal dataout : std_logic_vector(DSIZE-1 downto 0);
	signal dm :  std_logic_vector(DSIZE/8-1 downto 0);
	signal cs_n : std_logic_vector(1 downto 0);
	
	signal dram_addr_int :  std_logic_vector(11 downto 0);
	
	signal cas_to_ras : std_logic_vector(3 downto 0);
	
begin

	reset_n <= not reset;

--	 sdr: sdr_sdram 
--         port map (
--              CLK       =>   clk,   
--              RESET_N   =>   reset_n, 
--              ADDR      =>   addr,    
--              CMD       =>   cmd,  
--              CMDACK    =>   cmdack,  
--              DATAIN    =>   datain, 
--              DATAOUT   =>   dataout, 
--              DM        =>   dm,      
--				  
--              SA        =>   dram_addr_int,      
--              BA        =>   DRAM_BA,      
--              CS_N      =>   cs_n,    
--              CKE       =>   DRAM_CKE,     
--              RAS_N     =>   DRAM_RAS_N,  
--              CAS_N     =>   DRAM_CAS_N,   
--              WE_N      =>   DRAM_WE_N,    
--              DQ        =>   DRAM_DQ,      
--              DQM       =>   DRAM_DQM     
-- 		);

	DRAM_CS_N <= cs_n(0);
	
	DRAM_ADDR <= '0' & dram_addr_int;

--	FS_ADDR <= address(21 downto 2);
	
	do_clk_mem_acc_state: process (clk, reset, cmdack)
	begin
		if reset = '1'  then
			mem_state <= CONFIG;			
		else
			if rising_edge (clk) then
				case mem_state is
					when CONFIG =>
						if reset = '0' then
							mem_state <= C_PRE;
						end if;
					
					when C_PRE =>
					
						if cmdack = '1' then
							mem_state <= C_LD;
						end if;
					
					when C_LD => 
						if cmdack = '1' then
							mem_state <= NOP;
						end if;
					
					when NOP => 
						mem_state <= C_REG1;
					
					when C_REG1 => 
						if cmdack = '1' then
							mem_state <= C_REG2;
						end if;
					
					when C_REG2 => 
					
						if cmdack = '1' then
							mem_state <= IDLE;
						end if;
					
					when IDLE =>
						
						if chipselect = '1' then
						
							if write = '1' then
								mem_state <= WRITE_M;
							else
								mem_state <= READ_M;
							end if;							
							
						end if;
					
					when WRITE_M =>
						cas_to_ras <= (others => '0');
						if cmdack = '1' then
							mem_state <= RW_NOP;
						end if;
										
					when READ_M =>
						cas_to_ras <= (others => '0');
						if cmdack = '1' then
							mem_state <= RW_NOP;
						end if;
						
					when RW_NOP => 
						cas_to_ras <= cas_to_ras + 1;
						
						-- wait for RAS to CAS to expire
						if cas_to_ras = "0011" then														
							mem_state <= DONE;
						end if;
						
					
					when RW_PRE =>
						if cmdack = '1' then
							mem_state <= DONE;
						end if;					
						
					when DONE => 
						mem_state <= IDLE;
				
				end case;		
			end if;		
		end if;	
	end process;
	
	do_clk_mem_acc_state_output: process (mem_state, reset, chipselect, write, byteenable, address, chip_en_reg, byteenable_reg)
	begin

		in_reg_en    <= '0';
		waitrequest <= '0';
		d_read			 <= '0';
		d_write			<= '0';
		
		-- sdram controller
		addr <= (others => '0');
		cmd <= (others => '0');
		
		-- internal sdram controller
				
		case mem_state is
			
			when CONFIG =>
				if reset = '0' then				
					waitrequest <= '1';					
					
					addr <= (others => '0');					
				end if;
			
			when C_PRE =>
				waitrequest <= '1';
				
				-- precharge comand
				-- cmd <= "100";			
				
				

				
				--              CS_N      =>   cs_n,    
--              CKE       =>   DRAM_CKE,     
--              RAS_N     =>   DRAM_RAS_N,  
--              CAS_N     =>   DRAM_CAS_N,   
--              WE_N      =>   DRAM_WE_N,    
				
			
			
			when C_LD => 
				waitrequest <= '1';
				
				-- load cmd comand				
				cmd <= "101";			
				addr(2 downto 0)  <= "000";
				addr(6 downto 4)  <= "011";
				
			when NOP => 
				cmd <= "000";			
			
				
			when C_REG1 => 
				waitrequest <= '1';

				-- load reg_1 : refresh rate
				addr(15 downto 0) <= x"05F6";
            cmd  <= "111";
              
					
			when C_REG2 => 
				waitrequest <= '1';
				
--				-- cas latency
--            addr(1 downto 0) <= "11";
--            -- Ras to Cas delay.
--            addr(3 downto 2) <= "11";
--            -- Burst length 1,2,4, or 8
--            addr(12 downto 9) <= "0001";
--            -- Page mode setting
--            addr(8) <= '0';

				addr(9 downto 0) <= "1011111111";

            cmd  <= "110";
				
							
			when IDLE =>
					
				if chipselect = '1' then					
					waitrequest <= '1';					
				end if;
				
			
			when READ_M =>
			
				waitrequest <= '1';
				cmd  <= "001";
				addr	<= address(22 downto 0);
				
			when WRITE_M =>
				
				waitrequest <= '1';
				cmd  <= "010";
				datain <= writedata;
				addr	<= address(22 downto 0);
				
			when RW_NOP => 
				waitrequest <= '1';
				cmd  <= "000";
				

			when RW_PRE =>
				waitrequest <= '1';
				
				-- precharge comand
				cmd <= "100";			
				
			when DONE => 
				
			
			
			end case;
	end process;	
	
	 
--	 process (d_read, byteenable, FS_DQ)
--	 begin
--		
--		readdata <= FS_DQ;
--		
--		if d_read = '1' then
--						
--			case byteenable is
--				
--				when "0000" =>				
--			
--				when "0001" => 
--					readdata <= x"000000" & FS_DQ(7 downto 0);  
--				
--				when "0010" =>
--					readdata <=  x"000000" & FS_DQ(15 downto 8);
--				
--				when "0100" => 
--					readdata <= x"000000" & FS_DQ(23 downto 16);
--				
--				when "1000" => 
--					readdata <= x"000000" & FS_DQ(31 downto 24); 
--				
--				when "1100" => 
--					readdata <= x"0000" & FS_DQ(31 downto 16); 
--				
--				when "0011" =>
--					readdata <= x"0000" & FS_DQ(15 downto 0); 
--				
--				when "1111" =>						
--					readdata <= FS_DQ;
--					
--				when others =>
--			end case;
--				
--		end if;	 
--	 
--	 end process;
	 
--	tristate_sram_data_rd	: tristate	port map (
--		mybidir 		=> mem_data,
--		myinput 		=> FS_DQ,
--		myenable 	=> d_read
--	);
--	
--	tristate_sram_data_wr	: tristate	port map (
--		mybidir 		=> FS_DQ,
--		myinput 		=> writedata,
--		myenable 	=> d_write
--	);

	 
	process (clk, reset, byteenable, in_reg_en)
	begin
		if reset = '1' then
			byteenable_reg <= "1111";
		else
			if rising_edge(clk) and in_reg_en = '1' then
				byteenable_reg <= not byteenable;	
				chip_en_reg <= address(26);
			end if;
		end if;
	end process;

end rtl;