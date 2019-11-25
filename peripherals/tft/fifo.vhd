-------------------------------------------------------------------
-- Name        : 
-- Author      : 
-- Version     : 
-- Copyright   : 
-- Description : 
-------------------------------------------------------------------

-- Bibliotecas e clásulas
LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_textio.all;
use std.textio.all;
 
 entity ring_buffer IS
	GENERIC(
		RAM_WIDTH : natural := 32;
		RAM_DEPTH : natural := 42;
		HEAD_INIT : natural :=  0;
		FILENAME  : string  :="empty.txt"
	);
	PORT(clk     	: IN  std_logic;
	     rst        : IN  std_logic;
	     
	     wr_en      : IN  std_logic;
	     wr_data    : IN  unsigned(RAM_WIDTH - 1 downto 0);
	     
	     rd_en      : IN  std_logic;
	     rd_valid   : OUT std_logic;
	     rd_data    : OUT unsigned(RAM_WIDTH - 1 downto 0);
	     
	     empty      : OUT std_logic;
	     --empty_next : OUT std_logic;
	     full       : OUT std_logic;
	     --full_next  : OUT std_logic;
	     fill_count : OUT integer range RAM_DEPTH - 1 downto 0
	    );
end entity;
 
-- Arquitetura e
architecture rtl of ring_buffer IS
	type MEM is array (0 to RAM_DEPTH - 1) of unsigned(wr_data'range);
	
	impure function InitMEMFromFile(RamFileName : in string) return MEM is
	FILE MEMFile : text open read_mode is RamFileName;
	
	variable MEMFileLine : line;
	variable RAM : MEM;
	variable hex : std_logic_vector(wr_data'range);
				
	begin
		
		for i in MEM'range loop
			
			if(not endfile(MEMFile)) then
        		readline(MEMFile, MEMFileLine);			
				hread(MEMFileLine, hex);
        	else
        		hex := (others => '0');
      		end if;
      		
			RAM(i) := unsigned(hex);
		end loop;
		
		return RAM;
	
	end function;
	
	signal ram_block: MEM := InitMEMFromFile(FILENAME);
	
	subtype index_type is integer range ram_block'range;
	signal head : index_type ;--:= HEAD_INIT;
	signal tail : index_type;

	signal empty_i      : std_logic;
	signal full_i       : std_logic;
	signal fill_count_i : integer range RAM_DEPTH - 1 downto 0;
 
	-- Increment and wrap
	procedure incr(signal index : inout index_type) is
	begin
		if index = index_type'high then
			index <= index_type'low;
		else
			index <= index + 1;
		end if;
	end procedure;
	
begin
	empty      <= empty_i;
	full       <= full_i;
	fill_count <= fill_count_i;

	-- Set the flags
	empty_i    <= '1' when fill_count_i = 0 else '0';
	--empty_next <= '1' when fill_count_i <= 1 else '0';
	full_i     <= '1' when fill_count_i >= RAM_DEPTH - 1 else '0';
	--full_next  <= '1' when fill_count_i >= RAM_DEPTH - 2 else '0';

	-- Update the head pointer in write
	PROC_HEAD : process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				head <=  HEAD_INIT -1;--0;			
			else

				if wr_en = '1' and full_i = '0' then
					incr(head);
				end if;

			end if;
		end if;
	end process;

	-- Update the tail pointer on read and pulse valid
	PROC_TAIL : process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				tail     <= 0;
				rd_valid <= '0';				
			else
				rd_valid <= '0';

				if rd_en = '1' and empty_i = '0' then
					incr(tail);
					rd_valid <= '1';
				end if;

			end if;
		end if;
	end process;

	-- Write to and read from the RAM
	PROC_RAM : process(clk)
	begin
		if rising_edge(clk) then
			ram_block(head) <= wr_data;
			rd_data   <= ram_block(tail);
		end if;
	end process;

	-- Update the fill count
	PROC_COUNT : process(head, tail)
	begin
		if head < tail then
			fill_count_i <= head - tail + RAM_DEPTH;
		else
			fill_count_i <= head - tail;
		end if;
	end process;

end architecture;
