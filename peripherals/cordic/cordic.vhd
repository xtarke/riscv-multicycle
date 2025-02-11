-------------------------------------------------------
--! @file
--! @brief RISCV Simple CORDIC module

--        
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cordic is
	generic (
		--! Chip selec
		MY_CHIPSELECT : std_logic_vector(1 downto 0) := "10";
		MY_WORD_ADDRESS : unsigned(15 downto 0) := x"0000";	
		DADDRESS_BUS_SIZE : integer := 32
	);
	
	port(
		clk : in std_logic;
		rst : in std_logic;
		
		-- Core data bus signals
		daddress  : in  unsigned(DADDRESS_BUS_SIZE-1 downto 0);
		ddata_w	  : in 	std_logic_vector(31 downto 0);
		ddata_r   : out	std_logic_vector(31 downto 0);
		d_we      : in std_logic;
		d_rd	  : in std_logic;
		dcsel	  : in std_logic_vector(1 downto 0);	--! Chip select 
		-- ToDo: Module should mask bytes (Word, half word and byte access)
		dmask     : in std_logic_vector(3 downto 0)	--! Byte enable mask   
	);
end entity cordic;

architecture RTL of cordic is
    signal enable_exti_mask: std_logic_vector(31 downto 0);
    signal edge_exti_mask: std_logic_vector(31 downto 0);
    
    signal output_reg:std_logic_vector(31 downto 0);    
    
begin
    
    
	-- Input register
    process(clk, rst)
    begin
        if rst = '1' then
            ddata_r <= (others => '0');
        else
            if rising_edge(clk) then
                if (d_rd = '1') and (dcsel = MY_CHIPSELECT) then
                    if daddress(15 downto 0) = MY_WORD_ADDRESS then
                        ddata_r <= input;  
                    elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 1) then
                        ddata_r<=output_reg;              
                    elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 2) then
                        ddata_r<=enable_exti_mask;
                    elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 3) then
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
			output_reg<=(others => '0');
			enable_exti_mask<= (others => '0');
			edge_exti_mask<= (others => '0');
		else
			if rising_edge(clk) then		
				if (d_we = '1') and (dcsel = MY_CHIPSELECT) then				
					if daddress(15 downto 0) = (MY_WORD_ADDRESS + 1) then
					   output <= ddata_w;
					   output_reg <= ddata_w;
					elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 2) then
                        enable_exti_mask <= ddata_w;
                    elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 3) then
                        edge_exti_mask <= ddata_w;     
					end if;
					
				end if;
			end if;
		end if;		
	end process;

end architecture RTL;
