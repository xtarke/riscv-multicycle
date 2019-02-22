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
		MEMORY_WORDS : integer := 1024 
	);
	
	port(
		clk : in std_logic;							--! Clock input
		data: in std_logic_vector (31 downto 0);	--! Write data input
		read_address_a: in integer range 0 to MEMORY_WORDS-1;	--! Address to be written
    	read_address_b: in integer range 0 to MEMORY_WORDS-1;	--! Address to be read
    	q_a:  out std_logic_vector (31 downto 0);		--! Read output
    	csel : in std_logic;    	
    	q_b:  out std_logic_vector (31 downto 0)		--! Read output
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
				
	begin
		
		for i in RamType'range loop
			
			if(not endfile(RamFile)) then
        		--v_data_row_counter := v_data_row_counter + 1;
        		--readline(test_vector,row);
        		readline(RamFile, RamFileLine);			
				hread(RamFileLine, hex);
        	else
        		hex := (others => '0');
      		end if;
			
			--read (RamFileLine, stringRead);			
			--report "Data: " & stringRead;
			
			RAM(i) := hex;			
		end loop;
		
		return RAM;
	
	end function;
	
	--! RAM Block instance
	signal RAM : RamType := InitRamFromFile("firmware32.hex");	
	
	--type mem is array (0 to 31) of std_logic_vector(31 downto 0);	--! Array 31 x 31 bits type creation
    --signal ram_block: mem;	
    signal read_address_reg_a: integer range 0 to MEMORY_WORDS-1;	--! Read address register
    signal read_address_reg_b: integer range 0 to MEMORY_WORDS-1;	--! Read address register
begin
	
	--! @brief Memory transaction process. Must me synchronous and with this format
	p1: process (clk)
	begin
		if rising_edge(clk) then	        
			read_address_reg_a <= read_address_a;
			read_address_reg_b <= read_address_b;
	    end if;
	end process;

    q_a <= RAM(read_address_reg_a);
    
    with csel select    
    	q_b <= RAM(read_address_reg_b) when '1',
    	    (others => 'Z') when others;
    
    

end architecture RTL;
