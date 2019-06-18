--#############################################################################
--
--  LOGIC CORE:          Command module							
--  MODULE NAME:         command()
--  COMPANY:             Altera Corporation
--                       www.altera.com	
--
--  REVISION HISTORY:  
--
--    Revision 1.1  06/06/2000	Description: Initial Release.
--
--  FUNCTIONAL DESCRIPTION:
--
--  This module is the command processor module for the SDR SDRAM controller.
--
--
--  Copyright (C) 1991-2000 Altera Corporation
--#############################################################################


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;



entity command is
	
	generic (
		ASIZE 		: integer := 23;
		DSIZE 		: integer := 32;
		ROWSIZE 	: integer := 12;
		COLSIZE 	: integer := 9;
		BANKSIZE 	: integer := 2;
		ROWSTART 	: integer := 9;         -- Starting position of the row address within ADDR   
		COLSTART 	: integer := 0;         -- Starting position of the column address within ADDR
		BANKSTART 	: integer := 20		-- Starting position of the bank address within ADDR
	);

	port (
		CLK			: in	std_logic;							-- System Clock
		RESET_N		: in	std_logic;							-- System Reset
		SADDR		: in	std_logic_vector(ASIZE-1 downto 0);	-- Address
		NOP			: in	std_logic;							-- Decoded NOP command
		READA		: in	std_logic;							-- Decoded READA command
		WRITEA		: in	std_logic;							-- Decoded WRITEA command
		REFRESH		: in	std_logic;							-- Decoded REFRESH command
		PRECHARGE	: in	std_logic;							-- Decoded PRECHARGE command
		LOAD_MODE	: in	std_logic;							-- Decoded LOAD_MODE command
		SC_CL		: in	std_logic_vector(1 downto 0);		-- Programmed CAS latency
		SC_RC		: in	std_logic_vector(1 downto 0);		-- Programmed RC delay
		SC_RRD		: in	std_logic_vector(3 downto 0);		-- Programmed RRD delay
		SC_PM		: in	std_logic;							-- programmed Page Mode
		SC_BL		: in	std_logic_vector(3 downto 0);		-- Programmed burst length
		REF_REQ		: in	std_logic;							-- Hidden refresh request
		REF_ACK		: out	std_logic;							-- Refresh request acknowledge
		CM_ACK		: out	std_logic;							-- Command acknowledge
		OE			: out	std_logic;							-- OE signal for data path module
		SA			: out	std_logic_vector(11 downto 0);		-- SDRAM address
		BA			: out	std_logic_vector(1 downto 0);		-- SDRAM bank address
		CS_N		: out	std_logic_vector(1 downto 0);		-- SDRAM chip selects
		CKE			: out	std_logic;							-- SDRAM clock enable
		RAS_N		: out	std_logic;							-- SDRAM RAS
		CAS_N		: out	std_logic;							-- SDRAM CAS
		WE_N		: out	std_logic							-- SDRAM WE_N
	);
end command;






architecture RTL of command is



	-- signal declarations
	signal	do_nop 			: std_logic;
	signal	do_reada 		: std_logic;
    signal	do_writea 		: std_logic;
    signal	do_writea1 		: std_logic;
    signal	do_refresh 		: std_logic;
    signal	do_precharge 	: std_logic;
    signal	do_load_mode 	: std_logic;
    signal	command_done 	: std_logic;
    signal	command_delay 	: std_logic_vector(7 downto 0);
    signal	rw_shift 		: std_logic_vector(3 downto 0);
    signal	do_act 			: std_logic;			                       
    signal	rw_flag 		: std_logic;			                       
    signal	do_rw 			: std_logic;			                       
    signal	oe_shift 		: std_logic_vector(7 downto 0);
    signal	oe1 			: std_logic;				                       
    signal	oe2 			: std_logic;				                       
    signal	oe3 			: std_logic;				                       
    signal	oe4 			: std_logic;				                       
    signal	rp_shift 		: std_logic_vector(3 downto 0);
    signal	rp_done			: std_logic;
	signal	rowaddr 		: std_logic_vector(ROWSIZE-1 downto 0);
	signal	coladdr 		: std_logic_vector(COLSIZE-1 downto 0);
	signal	bankaddr 		: std_logic_vector(BANKSIZE-1 downto 0);

	signal	REF_REQ_int		: std_logic;
	

begin

	rowaddr   <= SADDR(ROWSTART + ROWSIZE - 1 downto ROWSTART);      -- assignment of the row address bits from SADDR
	coladdr   <= SADDR(COLSTART + COLSIZE - 1 downto COLSTART);      -- assignment of the column address bits
	bankaddr  <= SADDR(BANKSTART + BANKSIZE - 1 downto BANKSTART);   -- assignment of the bank address bits



	-- This process monitors the individual command lines and issues a command
	-- to the next stage if there currently another command already running.
	--
	process(CLK, RESET_N)
	begin
		if (RESET_N = '0') then
			do_nop          <= '0';
			do_reada        <= '0';
			do_writea       <= '0';
			do_refresh      <= '0';
			do_precharge    <= '0';
			do_load_mode    <= '0';
			command_done    <= '0';
			command_delay   <= (others => '0');
			rw_flag         <= '0';
			rp_shift        <= (others => '0');
			rp_done         <= '0';
            do_writea1      <= '0';
		elsif rising_edge(CLK) then
	--  Issue the appropriate command if the sdram is not currently busy     
                if ((REF_REQ = '1' or REFRESH = '1') and command_done = '0' and do_refresh = '0' and rp_done = '0'         -- Refresh
                        and do_reada = '0' and do_writea = '0') then
                        do_refresh <= '1';                                   
                else
                        do_refresh <= '0';
                end if;
                       

                if ((READA = '1') and (command_done = '0') and (do_reada = '0') and (rp_done = '0') and (REF_REQ = '0')) then   -- READA
                        do_reada <= '1';
                else
                        do_reada <= '0';
                end if;
                    
                if ((WRITEA = '1') and (command_done = '0') and (do_writea = '0') and (rp_done = '0') and (REF_REQ = '0')) then -- WRITEA
                        do_writea <= '1';
                        do_writea1 <= '1';
                else
                        do_writea <= '0';
                        do_writea1 <= '0';
                end if;

                if ((PRECHARGE = '1') and (command_done = '0') and (do_precharge = '0')) then                           -- PRECHARGE
                        do_precharge <= '1';
                else
                        do_precharge <= '0';
                end if;
 
                if ((LOAD_MODE = '1') and (command_done = '0') and (do_load_mode = '0')) then                           -- LOADMODE
                        do_load_mode <= '1';
                else
                        do_load_mode <= '0';
                end if;
                                               
	-- set command_delay shift register and command_done flag
	-- The command delay shift register is a timer that is used to ensure that
	-- the SDRAM devices have had sufficient time to finish the last command.

                if ((do_refresh = '1') or (do_reada = '1') or (do_writea = '1') or (do_precharge = '1') or (do_load_mode = '1')) then
                        command_delay 	<= "11111111";
                        command_done  	<= '1';
                        rw_flag 		<= do_reada;                                                  

                else
                        command_done        		<= command_delay(0);                -- the command_delay shift operation
                        command_delay(6 downto 0)  	<= command_delay(7 downto 1);                                
                        command_delay(7)    		<= '0';
                end if;
                
 
	 -- start additional timer that is used for the refresh, writea, reada commands               
                if (command_delay(0) = '0' and command_done = '1') then
                        rp_shift <= "1111";
                        rp_done  <= '1';
                else
                        rp_done         		<= rp_shift(0);
                        rp_shift(2 downto 0)   	<= rp_shift(3 downto 1);
                        rp_shift(3)     		<= '0';
                end if;
		end if;
	end process;




	-- logic that generates the OE signal for the data path module
	-- For normal burst write he duration of OE is dependent on the configured burst length.
	-- For page mode accesses(SC_PM=1) the OE signal is turned on at the start of the write command
	-- and is left on until a PRECHARGE(page burst terminate) is detected.
	--
	process(CLK, RESET_N)
	begin
		if (RESET_N = '0') then
                oe_shift <= (others => '0');
                oe1      <= '0';
                oe2      <= '0';
                oe3      <= '0';
                oe4      <= '0';
                OE       <= '0';
		elsif rising_edge(CLK) then
                if (SC_PM = '0') then
                        if (do_writea1 = '1') then
                                if (SC_BL = "0001") then                       --  Set the shift register to the appropriate
                                        oe_shift <= (others => '0');                -- value based on burst length.
                                elsif (SC_BL = "0010") then
                                        oe_shift <= "00000001";
                                elsif (SC_BL = "0100") then
                                        oe_shift <= "00000111";
                                elsif (SC_BL = "1000") then
                                        oe_shift <= "01111111";
                                end if;
                                oe1 <= '1';
                        else 
                                oe_shift(6 downto 0) <= oe_shift(7 downto 1);       -- Do the shift operation
                                oe_shift(7)   <= '0';
                                oe1  <= oe_shift(0);
                                oe2  <= oe1;
                                oe3  <= oe2;
                                oe4   <= oe3;
                                if (SC_RC = "10") then
                                        OE <= oe3;
                                else
                                        OE <= oe4;
                                end if;
                        end if;
                else
                        if (do_writea1 = '1') then                                    -- OE generation for page mode accesses
                                oe4   <= '1';
                        elsif (do_precharge = '1' or do_reada = '1' or do_refresh = '1') then
                                oe4   <= '0';
                        end if;
                        OE <= oe4;
                end if;
                               
		end if;
	end process;






	-- This process tracks the time between the activate command and the
	-- subsequent WRITEA or READA command, RC.  The shift register is set using
	-- the configuration register setting SC_RC. The shift register is loaded with
	-- a single '1' with the position within the register dependent on SC_RC.
	-- When the '1' is shifted out of the register it sets so_rw which triggers
	-- a writea or reada command
	--
	process(CLK, RESET_N)
	begin
		if (RESET_N = '0') then
                rw_shift <= (others => '0');
                do_rw    <= '0';
		elsif rising_edge(CLK) then
                if ((do_reada = '1') or (do_writea = '1')) then
                        if (SC_RC = "01") then                                      -- Set the shift register
                                do_rw <= '1';
                        elsif (SC_RC = "10")	then
                                rw_shift <= "0001";
                        elsif (SC_RC = "11")	then
                                rw_shift <= "0010";
                        end if;
                else
                        rw_shift(2 downto 0) 	<= rw_shift(3 downto 1);           -- perform the shift operation
                        rw_shift(3) 			<= '0';
                        do_rw         			<= rw_shift(0);
                end if;
		end if;
	end process;


	
	
	-- This process generates the command acknowledge, CM_ACK, signal.
	-- It also generates the acknowledge signal, REF_ACK, that acknowledges
	-- a refresh request that was generated by the internal refresh timer circuit.
	process(CLK, RESET_N)
	begin
		if (RESET_N = '0') then
                CM_ACK   <= '0';
                REF_ACK  <= '0';
		elsif rising_edge(CLK) then
                if (do_refresh = '1' and REF_REQ = '1') then                        -- Internal refresh timer refresh request
                        REF_ACK <= '1';
                elsif ((do_refresh = '1') or (do_reada = '1') or (do_writea = '1') or (do_precharge = '1')   -- externa  commands
                         or (do_load_mode = '1')) then
                        CM_ACK <= '1';
                else
                        REF_ACK <= '0';
                        CM_ACK  <= '0';
                end if;
		end if;
	end process;






	-- This process generates the address, cs, cke, and command signals(ras,cas,wen)
	--
	process(CLK, RESET_N)
	begin
		if (RESET_N = '0') then
                SA    <= (others => '0');
                BA    <= (others => '0');
                CS_N  <= "01";
                RAS_N <= '1';
                CAS_N <= '1';
                WE_N  <= '1';
                CKE   <= '0';

		elsif rising_edge(CLK) then
                CKE <= '1';
	
	-- Generate SA 			
                if (do_writea = '1' or do_reada = '1') then               -- ACTIVATE command is being issued, so present the row address
                        SA(ROWSIZE-1 downto 0) <= rowaddr;
                else
                        SA(COLSIZE-1 downto 0) <=  coladdr;               -- else alway present column address
                end if;
                if ((do_rw='1') or (do_precharge='1')) then
                        SA(10) <= not(SC_PM);                             -- set SA(10) for autoprecharge read/write or for a precharge all command
                end if;
                                                                          -- don't set it if the controller is in page mode.           	
                if (do_precharge='1' or do_load_mode='1') then
                        BA <= "00";                                       -- Set BA=0 if performing a precharge or load_mode command
                else
                        BA <= bankaddr(1 downto 0);                       -- else set it with the appropriate address bits
                end if;
				
                if (do_refresh='1' or do_precharge='1' or do_load_mode='1') then
                        CS_N <= "00";                                     -- Select both chip selects if performing
                else                                                      -- refresh, precharge(all) or load_mode
                        CS_N(0) <= SADDR(ASIZE-1);                        -- else set the chip selects based off of the
                        CS_N(1) <= not(SADDR(ASIZE-1));                   -- msb address bit
                end	if;
	
	
	--Generate the appropriate logic levels on RAS_N, CAS_N, and WE_N
	--depending on the issued command.
	--				
                if (do_refresh='1') then                        -- Refresh: S=00, RAS=0, CAS=0, WE=1
                        RAS_N <= '0';
                        CAS_N <= '0';
                        WE_N  <= '1';
                elsif ((do_precharge='1') and ((oe4 = '1') or (rw_flag = '1'))) then      -- burst terminate if write is active
                        RAS_N <= '1';
                        CAS_N <= '1';
                        WE_N  <= '0';
                elsif ((do_precharge='1')) then                 -- precharge
                        RAS_N <= '0';
                        CAS_N <= '1';
                        WE_N  <= '0';
                elsif (do_load_mode='1') then                 -- Mode Write: S=00, RAS=0, CAS=0, WE=0
                        RAS_N <= '0';
                        CAS_N <= '0';
                        WE_N  <= '0';
                elsif (do_reada = '1' or do_writea = '1') then  -- Activate: S=01 or 10, RAS=0, CAS=1, WE=1
                        RAS_N <= '0';
                        CAS_N <= '1';
                        WE_N  <= '1';
                elsif (do_rw = '1') then                      -- Read/Write:	S=01 or 10, RAS=1, CAS=0, WE=0 or 1
                        RAS_N <= '1';
                        CAS_N <= '0';
                        WE_N  <= rw_flag;
                else
                        RAS_N <= '1';
                        CAS_N <= '1';
                        WE_N  <= '1';
                end	if;
		end if;
	end process;





end RTL;
