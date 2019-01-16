-------------------------------------------------------
--! @file
--! @brief Simple instruction memory
-------------------------------------------------------

--! Use IEE standard library
library ieee;
	--! Use standard logic elements
	use ieee.std_logic_1164.all;
	--! Use conversion functions
	use ieee.numeric_std.all;
	--! Use read hex and io functions
	use ieee.std_logic_textio.all;

--! Use standard library
use std.textio.all;


--! imemory entity brief description

--! Detailed description of this 
--! imemory design element.

entity imemory is
	generic (
		--! Num of 32-bits memory words 
		MEMORY_WORDS : integer := 256 
	);
	
	port(
		clk : in std_logic;							--! Clock input
		data: in std_logic_vector (31 downto 0);	--! Write data input
		write_address: in integer range 0 to MEMORY_WORDS-1;	--! Address to be written
    	read_address:  in integer range 0 to MEMORY_WORDS-1;	--! Address to be read
    	we: in std_logic;							--! Write Enable
    	q:  out std_logic_vector (31 downto 0)		--! Read output
	);
end entity imemory;


--! @brief Architecture definition of the imemory
--! @details More details about this imemory element.
architecture RTL of imemory is
		
	type RamType is array (0 to MEMORY_WORDS-1) of std_logic_vector(31 downto 0);
	
	impure function InitRamFromFile(RamFileName : in string) return RamType is
		FILE RamFile : text open read_mode is RamFileName;
		
		variable RamFileLine : line;
		variable RAM : RamType;
		variable hex : std_logic_vector(31 downto 0);
		variable stringRead: string (7 downto 0);
		
	begin
		
		for i in RamType'range loop
			readline(RamFile, RamFileLine);			
			hread(RamFileLine, hex);
			
			--read (RamFileLine, stringRead);			
			--report "Data: " & stringRead;
			
			RAM(i) := hex;			
		end loop;
		
		return RAM;
	
	end function;
	
	--! RAM Block instance
	signal RAM : RamType := InitRamFromFile("memory.hex");	
	
	--type mem is array (0 to 31) of std_logic_vector(31 downto 0);	--! Array 31 x 31 bits type creation
    --signal ram_block: mem;	
    signal read_address_reg: integer range 0 to MEMORY_WORDS-1;	--! Read address register
begin
	
	--! @brief Memory transaction process. Must me synchronous and with this format
	p1: process (clk)
	begin
		if rising_edge(clk) then
	        if (we = '1') then
	            RAM(write_address) <= data;
	        end if;
	        
	        read_address_reg <= read_address;
	    end if;
	end process;

    q <= RAM(read_address_reg);

end architecture RTL;
