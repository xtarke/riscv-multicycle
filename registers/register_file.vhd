library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is
	port(
		clk 		: in std_logic;
		rst 		: in std_logic;	-- Clear registers data		
		
		w_ena 		: in std_logic;
		
		w_address	: in integer range 0 to 31;	
		w_data		: in std_logic_vector(31 downto 0);
		
		r1_address	: in integer range 0 to 31;	
		r1_data		: out std_logic_vector(31 downto 0);
		 
		r2_address	: in integer range 0 to 31;
		r2_data		: out std_logic_vector(31 downto 0)		
	);
end entity register_file;

architecture RTL of register_file is
	
	--subtype word_t is std_logic_vector(31 downto 0);	-- Build a 2-D array type for the RAM
	--type memory_t is aray (0 to 31) of word_t;
	-- Declare the RAM signal.
	-- signal ram : memory_t;
	
	type RamType is array (0 to 31) of std_logic_vector(31 downto 0);	--! Array 31 x 31 bits type creation
	
	impure function InitRam return RamType is		
		variable RAM : RamType;	
	begin
		
		for i in RamType'range loop
			RAM(i) :=  (others => '0');		
		end loop;
		
		return RAM;	
	end function;	
	
    signal ram: RamType := InitRam;	--! RAM Block instance
   
	type reg_array is array (0 to 31) of std_logic_vector(31 downto 0);
	signal registers : reg_array;
	
	signal w_vector : std_logic_vector(31 downto 0);	
	
	signal we_b : std_logic;
	
begin	
	-- Port B never writes
	we_b <= '0';	
	
	dual_port_ram: block
	begin
	
		process(clk)
		begin
			if(rising_edge(clk)) then -- Port A
				if(w_ena = '1') then
					ram(w_address) <= w_data;
					-- Read-during-write on the same port returns NEW data
					-- r1_data <= w_data;
				else
					-- Read-during-write on the mixed port returns OLD data
					r1_data <= ram(r1_address);
				end if;
			end if;
		end process;
				
		process(clk)
		begin
			if(rising_edge(clk)) then -- Port B
--				if(we_b = '1') then
--					ram(w_address) <= w_data;
--					-- Read-during-write on the same port returns NEW data
--					r2_data <= w_data;
--				else
					-- Read-during-write on the mixed port returns OLD data
					r2_data <= ram(r2_address);
				--end if;
			end if;
		end process;
		
	end block dual_port_ram;
	
--	w_demux : process(w_ena, w_address)
--	begin
--		if w_ena = '1' then
--			w_vector	<= to_StdLogicVector(x"00000001" sll to_integer(unsigned(w_address)));
--		else
--			w_vector <= (OTHERS => '0');
--		end if;
--	end process w_demux;
	
	-- r1_data <= registers(to_integer(unsigned(r1_address)));	
	-- r2_data <= registers(to_integer(unsigned(r2_address)));
	
end architecture RTL;
