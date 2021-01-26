-------------------------------------------------------
--! @file
--! @brief RISCV Simple GPIO module
--         RAM mapped general purpose I/O

--! @Todo: Module should mask bytes (Word, half word and byte access)
--         Daddress shoud be unsgined
--        
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gpio is
	generic (
		--! Chip selec
		MY_CHIPSELECT : std_logic_vector(1 downto 0) := "10";
		MY_WORD_ADDRESS : unsigned(7 downto 0) := x"10"	
	);
	
	port(
		clk : in std_logic;
		rst : in std_logic;
		
		-- Core data bus signals
		-- ToDo: daddress shoud be unsgined
		daddress  : in  natural;		
		ddata_w	  : in 	std_logic_vector(31 downto 0);
		ddata_r   : out	std_logic_vector(31 downto 0);
		d_we      : in std_logic;
		d_rd	  : in std_logic;
		dcsel	  : in std_logic_vector(1 downto 0);	--! Chip select 
		-- ToDo: Module should mask bytes (Word, half word and byte access)
		dmask     : in std_logic_vector(3 downto 0);	--! Byte enable mask
		
		-- hardware input/output signals
		input  : in std_logic_vector(31 downto 0);
		output : out std_logic_vector(31 downto 0);		
	    gpio_interrupts : out std_logic_vector(6 downto 0)   
	);
end entity gpio;

architecture RTL of gpio is
    signal myInterrupts_d : std_logic_vector(6 downto 0); 
    signal interrupts: std_logic_vector(6 downto 0);
    
    signal enable_exti_mask: std_logic_vector(31 downto 0);
    signal edge_exti_mask: std_logic_vector(31 downto 0);
    
    signal EXTIx    : std_logic_vector(31 downto 0);
    
    signal EXTI5_9  : std_logic;
    signal EXTI10_15: std_logic;
    
    
begin
    
    EXTIx<= (input xor edge_exti_mask) and enable_exti_mask;
    

    EXTI5_9<=   EXTIx(5) or 
                EXTIx(6) or 
                EXTIx(7) or 
                EXTIx(8) or 
                EXTIx(9);
    EXTI10_15<= EXTIx(10) or 
                EXTIx(11) or 
                EXTIx(12) or 
                EXTIx(13) or 
                EXTIx(14) or 
                EXTIx(15);
    
    interrupts<= EXTI10_15 & EXTI5_9 & EXTIx(4) & EXTIx(3) & EXTIx(2) & EXTIx(1) & EXTIx(0);
	 
	 
    interrupt_edge : process (clk, rst) is
    begin
        if rst = '1' then
            
        elsif rising_edge(clk) then
               
            myInterrupts_d <= interrupts; 
            gpio_interrupts <= not myInterrupts_d and interrupts;
    
        end if;
    end process interrupt_edge;
    
    
	-- Input register
    process(clk, rst)
    begin
        if rst = '1' then
            ddata_r <= (others => '0');
        else
            if rising_edge(clk) then

                if (d_rd = '1') and (dcsel = MY_CHIPSELECT) then

                    if to_unsigned(daddress, 32)(15 downto 0) = x"0000" then
                        ddata_r <= input;                
                    elsif to_unsigned(daddress, 32)(15 downto 0) = x"0008" then
                        ddata_r<=enable_exti_mask;
                    elsif to_unsigned(daddress, 32)(15 downto 0) = x"00012" then
                        ddata_r<=edge_exti_mask;
                    end if;

                end if;
            end if;
        end if;
    end process;

    -- Output register
	process(clk, rst)
	begin		
		if rst = '1' then
			output <= (others => '0');
			enable_exti_mask<= (others => '0');
			edge_exti_mask<= (others => '0');
		else
			if rising_edge(clk) then		
				if (d_we = '1') and (dcsel = MY_CHIPSELECT)then					
					-- ToDo: Simplify comparators
					-- ToDo: Maybe use byte addressing?  
					--       x"01" (word addressing) is x"04" (byte addressing)
					-- Address comparator when more than one word is mapped here
					--if to_unsigned(daddress, 32)(8 downto 0) = MY_WORD_ADDRESS then
					--end if;
					
					if to_unsigned(daddress, 32)(15 downto 0) = x"0004" then
					output <= ddata_w;    
					elsif to_unsigned(daddress, 32)(15 downto 0) = x"0008" then
                    enable_exti_mask <= ddata_w;
                    elsif to_unsigned(daddress, 32)(15 downto 0) = x"0000C" then
                    edge_exti_mask <= ddata_w;     
					end if;
					
				end if;
			end if;
		end if;		
	end process;

end architecture RTL;
