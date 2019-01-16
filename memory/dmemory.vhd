-------------------------------------------------------
--! @file
--! @brief Simple instruction memory
-------------------------------------------------------

--! Use standard library
library ieee;
	--! Use standard logic elements
	use ieee.std_logic_1164.all;
	--! Use conversion functions
	use ieee.numeric_std.all;


--! imemory entity brief description

--! Detailed description of this 
--! imemory design element.

entity dmemory is
	generic (
		--! Num of 32-bits memory words 
		MEMORY_WORDS : integer := 256 
	);
	port(
		clk : in std_logic;							--! Clock input
		data: in std_logic_vector (31 downto 0);	--! Write data input
		address:  in integer range 0 to MEMORY_WORDS-1;	--! Address to be read
    	we: in std_logic;							--! Write Enable
    	dmask     : out std_logic_vector(3 downto 0);	--! Byte enable mask 
    	q:  out std_logic_vector (31 downto 0)		--! Read output
	);
end entity dmemory;


--! @brief Architecture definition of the imemory
--! @details More details about this imemory element.
architecture RTL of dmemory is
	type mem is array (0 to MEMORY_WORDS-1) of std_logic_vector(31 downto 0);	--! Array MEMORY_WORDS x 31 bits type creation
    signal ram_block: mem;	--! RAM Block instance
    signal read_address_reg: integer range 0 to MEMORY_WORDS-1;	--! Read address register

begin
	
	--! @brief Memory transaction process. Must me synchronous and with this format
	p1: process (clk)
	begin
		if rising_edge(clk) then
	        if (we = '1') then
	            ram_block(address) <= data;
	        end if;
	        
	        read_address_reg <= address;
	    end if;
	end process;

    q <= ram_block(address);

end architecture RTL;
