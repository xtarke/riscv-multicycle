library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package cpu_typedef_package is	
	--generic
	constant WORD_SIZE 			: integer := 32;
	constant PC_SIZE 			: integer := 23;
		
	subtype word_t is std_logic_vector(WORD_SIZE-1 downto 0);
	subtype pc_t is std_logic_vector(PC_SIZE-1 downto 0);
	
	--RAM
	constant RAM_ADDR_SIZE		: integer := 32;
	
	
	--SSRAM
	-- depend on memory map
	constant SSRAM_ADDR_SIZE		: integer	:= 20;
	--constant SSRAM_ADDR_SIZE		: integer	:= 7;
	constant SSRAM_ADDR_INI			: integer := 0;
	constant SSRAM_ADDR_END	   : integer := 524287;
	
	-- SSRAM_ADDR_END: DEi2-150:  IS61LPS25672A: 512K x 36,  SYNCHRONOUS PIPELINED, SINGLE CYCLE DESELECT STATIC RAM
	
	-- instructotion memory
	constant INS_ADDR_INI					: integer := SSRAM_ADDR_END + 1;   
	constant INS_ADDR_END				: integer := INS_ADDR_INI + 256;
	
	constant INS_ADDR_SIZE				: integer := 14;		-- log2 (SSRAM_ADDR_INI)
	--constant <constant_name> : <type> := <constant_value>;

	-- data memory
	--constant DATA_ADDR_INI				: integer :
	
	
	
	-- CPU memory MAP
	constant CODE_INI		: integer := 0;
	constant CODE_END	: integer :=  16:3FFFFFFF:;
	
	constant SRAM_INI		: integer := 16:40000000:;
	constant SRAM_END	: integer := 16:403FFFFF:;
	
--	constant SDRAM_INI			: natural_32 := 16:80000000:;
--	constant SDRAM_END		: natural_32 := 16:FFFFFFFF:;


   --
	constant SP_ADDR_SIZE : integer := 11;


	constant DATA_ADDR_SIZE : integer := 32;
	
	--cache
	constant CACHE_BLOCKS 		: integer := 32;   --blocks or lines
	constant BLOCK_SIZE   		: integer := 8;   --number of words per block	
	constant CACHE_LINE_SIZE	: integer := BLOCK_SIZE*WORD_SIZE;
	
	constant BK_OFFSET_SIZE : integer :=  3;	--// bits to index the block (WORDS in each block) log2 BLOCK_SIZE
	constant BY_OFFSET_END  : integer := -1;
	constant BK_OFFSET_INI	  : integer := (BY_OFFSET_END + 1);			--0
	constant BK_OFFSET_END  : integer := (BK_OFFSET_INI + BK_OFFSET_SIZE - 1);	--2

	constant INDEX_SIZE     : integer := 5;	--// bits to index the lines log2 CACHE_BLOCKS
	constant INDEX_INI     	 : integer := (BK_OFFSET_END + 1); -- 3  
	constant INDEX_END      : integer := (INDEX_INI + INDEX_SIZE - 1); -- 3 + 5 -1 = 7
		
	constant TAG_INI      	 : integer := (INDEX_END + 1);
	constant TAG_END       : integer := (PC_SIZE - 1); -- 23 - 1 = 22
	constant TAG_SIZE      : integer := (TAG_END - TAG_INI + 1); -- 22 - 7 +1 = 
	
	--bundle
	constant WORDS_P_BUNDLE : integer := 4;
	constant BUNDLE_SIZE	   : integer := WORD_SIZE*WORDS_P_BUNDLE;
		
   -- alu
	constant ALU_FUN_SIZE   : integer := 6;
		
	-- register file
	constant REG_ADDR_SIZE	: integer := 6;	
	constant REG_SRC1_INI			: integer := 0;
	constant REG_SRC1_END		: integer := 5;	
	constant REG_SRC2_INI			: integer := 6;
	constant REG_SRC2_END		: integer := 11;	
	constant REG_DEST_INI			: integer := 12;
	constant REG_DEST_END		: integer := 17;
	
	-- predicates
	constant PRED_ADDR_SIZE		: integer := 3;
	constant BDEST_INI			: integer := 18;
	constant BDEST_END			: integer := 20;
	constant SCOND_INI			: integer := 21;
	constant SCOND_END			: integer := 23;
	constant IBDEST_INI			: integer := 6;
	constant IBDEST_END			: integer := 8;
	constant BCOND_INI			: integer := 23;
	constant BCOND_END			: integer := 25;
	
	
	-- immediate
	constant IMMEDIATE_INI		: integer := 12;
	constant IMMEDIATE_END		: integer := 20;
	constant IMMEDIATE_SIZE 	: integer := 9;
	constant IDEST_INI			: integer := 6;
	constant IDEST_END			: integer := 11;
	
	constant BTARG_SIZE			: integer := 23;
	constant BTARG_INI			: integer := 0;
	constant BTARG_END			: integer := 22;	
	
	constant L_IMM_SIZE			: integer := 23;
	constant L_IMM_INI			: integer := 0;
	constant L_IMM_END			: integer := 22;	
	
	
	-- decode fields
	constant DECOD_SIZE		: integer :=  9;
	constant DECOD_INI		: integer :=  21;
	constant DECOD_END		: integer :=  29;	
	
	-- opcode 
	constant OPCODE_SIZE			: integer := 5;	
	constant OPCODE_INI			: integer := 21;
	constant OPCODE_END			: integer := 25;
	constant CMP_OPCODE_SIZE 	: integer := 4;
	constant CMP_OPCODE_INI		: integer := 21;
	constant CMP_OPCODE_END		: integer := 24;
	constant CMP_DEST_SEL		: integer := 25;
	
	constant M0						: integer := 26;
	constant M1						: integer := 27;
	constant M2						: integer := 28;
	constant M3						: integer := 29;
	
	constant INS_FORMAT_SIZE	: integer := 2;
	constant INS_FORMAT_INI		: integer := 28;
	constant INS_FORMAT_END		: integer := 29;
	
	-- type of control flow instruction
	constant CTRFL_SELC			: integer := 27;
	constant CTRFL_REG_IMM_SELL: integer := 23;
	constant CTRFL_FUNC_INI		: integer := 24;
	constant CTRFL_FUNC_END		: integer := 26;
	constant CTRFL_CALL			: std_logic_vector (2 downto 0) := "000";
	constant CTRFL_GOTO			: std_logic_vector (2 downto 0) := "001";
	constant CTRFL_PRED			: std_logic_vector (2 downto 0) := "111";
	constant CTRFL_BR_SELC		: integer := 26;
	
	-- memory instruction
	constant MEMI_SIZE			: integer := 5;
	constant MEMI_INI				: integer := 23;
	constant MEMI_END				: integer := 27;
	
	
	-- slot fetch ouput
	type t_slot_ctrl is record
    src_1 	 	: std_logic_vector(REG_ADDR_SIZE-1 downto 0);
    src_2		: std_logic_vector(REG_ADDR_SIZE-1 downto 0);
    dest		  	: std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	 b_dest    	: std_logic_vector(PRED_ADDR_SIZE-1 downto 0);	
	 scond      : std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
  end record t_slot_ctrl;
  
  -- slot fetch ouput
	type t_ctrl is record   
    alu_func  : std_logic_vector(ALU_FUN_SIZE-1 downto 0);	
	 alu_mux   : std_logic;
	 src_1_reg : std_logic_vector(REG_ADDR_SIZE-1 downto 0);
    src_2_reg : std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	 dest_reg  : std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	 b_dest	  : std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	 scond     : std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	 f_pred    : std_logic;
	 par_on	  : std_logic;
	 par_off	  : std_logic;
	 
	 pred_reg_w_en  : std_logic;
	 reg_w_en  : std_logic;
	 
	 mem_wr		: std_logic;
	 mem_rd		: std_logic;
	 
	 -- "00" W, "01" HW, "10" B 
	 mem_byteen : std_logic_vector(1 downto 0); 
	 mem_sig_ex  : std_logic;
	 
	 mul_div       	: std_logic;
	 mul_div_sel    : std_logic;			-- 0 mul / 1 div
	 
	 branch_en : std_logic;
	 
	 halt				 : std_logic; 
  end record t_ctrl;
  
  
  type t_alu_val is record
	alu_val		: word_t;
	carry_cmp	: std_logic;
  end record t_alu_val;
  
	

end cpu_typedef_package;
