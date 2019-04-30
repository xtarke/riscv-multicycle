library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is
	port(
		clk 		: in std_logic;
		-- rst is not used since this register file uses a SRAM instance		
		rst 		: in std_logic;			
		
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
	-- Build a 2-D array type for the RAM
	type RamType is array (0 to 31) of std_logic_vector(31 downto 0);	
	
	-- RAM initialization function
	impure function InitRam return RamType is		
		variable RAM : RamType;	
	begin
		-- Clear all RAM cells
		for i in RamType'range loop
			RAM(i) :=  (others => '0');		
		end loop;
		
		return RAM;	
	end function;	
	
    signal ram: RamType := InitRam;	--! RAM Block instance with InitRam initializer   
	signal w_ena_prot : std_logic;
		
begin	
	-- Writes to register 0 is not allowed
	w_ena_prot <= '0' when w_address = 0 else w_ena;

	dual_port_ram: block
	begin				
		portA: process(clk)
		begin
			if(rising_edge(clk)) then 
				-- Write port
				if(w_ena_prot = '1') then
					ram(w_address) <= w_data;					
				else
					-- Read port A
					r1_data <= ram(r1_address);
				end if;
			end if;
		end process;
				
		portB: process(clk)
		begin
			if(rising_edge(clk)) then 		
				-- Read port B
				r2_data <= ram(r2_address);
			end if;
		end process;
		
	end block dual_port_ram;
	
end architecture RTL;
