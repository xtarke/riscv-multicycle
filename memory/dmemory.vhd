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
		rst : in std_logic;
		clk : in std_logic;							--! Clock input
		data: in std_logic_vector (31 downto 0);	--! Write data input
		address:  in integer range 0 to MEMORY_WORDS-1;	--! Address to be read
    	we: in std_logic;							--! Write Enable
    	csel : in std_logic;						--! Chip select
    	dmask     : in std_logic_vector(3 downto 0);	--! Byte enable mask 
    	q:  out std_logic_vector (31 downto 0)		--! Read output
	);
end entity dmemory;


--! @brief Architecture definition of the imemory
--! @details More details about this imemory element.
architecture RTL of dmemory is
	type mem is array (0 to MEMORY_WORDS-1) of std_logic_vector(31 downto 0);	--! Array MEMORY_WORDS x 31 bits type creation
    
   	impure function InitRam return mem is		
		variable RAM : mem;	
	begin
		
		for i in mem'range loop
			RAM(i) :=  (others => '0');		
		end loop;
		
		return RAM;	
	end function;	
    
    
    signal ram_block: mem := InitRam;	--! RAM Block instance
    signal read_address_reg: integer range 0 to MEMORY_WORDS-1;	--! Read address register


	type state_type is (READ, WORD, BYTE0, BYTE1, BYTE2, BYTE3);
	signal state : state_type;

	signal fsm_we : std_logic;
	signal fsm_data : std_logic_vector (31 downto 0);
	signal ram_data : std_logic_vector (31 downto 0);
 
begin
	
	--! @brief Memory transaction process. Must me synchronous and with this format
	p1: process (clk)
	begin
		if rising_edge(clk) then
	        if (fsm_we = '1') then
	            ram_block(address) <= fsm_data;
	        end if;
	        
	        read_address_reg <= address;
	    end if;
	end process;

	fsm: process(clk, rst)
	begin
		if rst = '1' then
			state <= READ;
		else
			if rising_edge(clk) then
		
				case state is 
					when READ =>
						if we = '1' then
							case dmask is 
								when "1111" =>
									state <= WORD;
								when "0001" => 
									state <= BYTE0;
								when "0010" => 
									state <= BYTE1;	
								when "0100" => 
									state <= BYTE2;	
								when "1000" => 
									state <= BYTE3;		
								when others => 	
							end case;							
						end if;
					when WORD =>
						state <= READ;
					when BYTE0 =>
						state <= READ;
					when BYTE1 =>
						state <= READ;
					when BYTE2 =>
						state <= READ;
					when BYTE3 =>
						state <= READ;
				end case;
				
			end if;
		
		end if;		
	end process;
	
	ctrl_fsm: process(state,ram_data,data)
	begin
		
		fsm_we <= '0';
		fsm_data <= data;
		
		case state is 
			when READ =>
				null;
			when WORD =>
				fsm_we <= '1';
				fsm_data <= data;
			when BYTE0 =>
				fsm_we <= '1';
				fsm_data <= ram_data(31 downto 8) & data(7 downto 0); 
			when BYTE1 =>
				fsm_we <= '1';
				fsm_data <= ram_data(31 downto 16) & data(7 downto 0) & ram_data(7 downto 0);
			when BYTE2 =>
				fsm_we <= '1';
				fsm_data <= ram_data(31 downto 24) & data(7 downto 0) & ram_data(15 downto 0);
			when BYTE3 =>
				fsm_we <= '1';
				fsm_data <= data(7 downto 0) & ram_data(23 downto 0);
		end case;
						
	end process;

    ram_data <= ram_block(address);    
    
    with csel select
			q <= ram_data when '1',
			      (others => 'Z') when others;		
    
    

end architecture RTL;
