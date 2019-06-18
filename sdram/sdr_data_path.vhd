--######################################################################
--
--  LOGIC CORE:          SDR Data Path Module							
--  MODULE NAME:         sdr_data_path()
--  COMPANY:             Altera Corporation
--                       www.altera.com		
--
--  REVISION HISTORY:  
--
--    Revision 1.1  06/06/2000	Description: Initial Release.
--
--  FUNCTIONAL DESCRIPTION:
--
--  This module is the data path module for the SDR SDRAM controller.
--
--
--  Copyright (C) 1991-2000 Altera Corporation 
--
--#######################################################################



library ieee;
use ieee.std_logic_1164.all;


entity sdr_data_path is
	
    generic (DSIZE : integer := 32);

    port (
         CLK            : in      std_logic;                              -- System Clock
         RESET_N        : in      std_logic;                              -- System Reset
         OE             : in      std_logic;                              -- Data output(to the SDRAM) enable
         DATAIN         : in      std_logic_vector(DSIZE-1 downto 0);     -- Data input from the host
         DM             : in      std_logic_vector(DSIZE/8-1 downto 0);   -- byte data masks
         DATAOUT        : out     std_logic_vector(DSIZE-1 downto 0);     -- Read data output to host
         DQIN           : in      std_logic_vector(DSIZE-1 downto 0);     -- SDRAM data bus
         DQOUT          : out     std_logic_vector(DSIZE-1 downto 0);
         DQM            : out     std_logic_vector(DSIZE/8-1 downto 0)    -- SDRAM data mask ouputs
         );
end sdr_data_path;



architecture RTL of sdr_data_path is

            
    -- signal declarations 
    signal    DIN1      : std_logic_vector(DSIZE-1 downto 0);
    signal    DIN2      : std_logic_vector(DSIZE-1 downto 0);
    signal    DM1       : std_logic_vector(DSIZE/8-1 downto 0);         


begin

	-- This always block is a two stage pipe line delay that keeps the
	-- data aligned with the command sequence in the other modules.
	-- The pipeline is in both directions.
    process(CLK, RESET_N)
    begin
         if (RESET_N = '0') then
              DIN1      <= (others => '0');
              DIN2      <= (others => '0');
              DM1       <= (others => '0');
         elsif rising_edge(CLK) then
              DIN1      <= DATAIN;
              DIN2      <= DIN1;
              
              DM1       <= DM;
              DQM       <= DM1;


         end if;
    end process;

DATAOUT <= DQIN;
DQOUT   <= DIN2;


end RTL;

