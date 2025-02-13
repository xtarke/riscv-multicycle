-------------------------------------------------------
--! @file
--! @brief RISCV Simple CORDIC module
--        
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cordic_bus is
	generic (
		--! Chip selec
		MY_CHIPSELECT : std_logic_vector(1 downto 0) := "10";
		MY_WORD_ADDRESS : unsigned(15 downto 0) := x"0000";	
		DADDRESS_BUS_SIZE : integer := 32;
		DATA_WIDTH_BUS : integer := 16
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
		dmask     : in std_logic_vector(3 downto 0);	--! Byte enable mask
		
		--cordic_core stuff
		start_bus    : in  std_logic;
    	angle_in_bus : in  signed(DATA_WIDTH_BUS-1 downto 0);
    	sin_out_bus  : out signed(DATA_WIDTH_BUS-1 downto 0);
    	cos_out_bus  : out signed(DATA_WIDTH_BUS-1 downto 0);
    	valid_bus    : out std_logic
	);
end entity cordic_bus;

architecture RTL of cordic_bus is
    signal enable_exti_mask: std_logic_vector(31 downto 0);
    signal edge_exti_mask: std_logic_vector(31 downto 0);
    
	 signal output    :std_logic_vector(31 downto 0);
    signal output_reg:std_logic_vector(31 downto 0);    
    
begin

	cordic_inst: entity work.cordic_core
		port map(
			clk_bus => clk,
			rst_bus => rst,
			start => start_bus,
			angle_in => angle_in_bus,
			sin_out => sin_out_bus,
			cos_out => cos_out_bus,
			valid => valid_bus
		);
    
	-- Input register
    process(clk, rst)
    begin
        if rst = '1' then
            ddata_r <= (others => '0');
        else
            if rising_edge(clk) then
                if (d_rd = '1') and (dcsel = MY_CHIPSELECT) then
                    if daddress(15 downto 0) = MY_WORD_ADDRESS then
						sin_out_bus <= signed(ddata_w(31 downto 16));
						cos_out_bus <= signed(ddata_w(15 downto 0));
						-- ddata_r(31 downto 16) <= std_logic_vector(sin_out_bus);
						-- ddata_r(15 downto 0) <= std_logic_vector(cos_out_bus);  
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
						output(31 downto 16) <= (others => '0');
						output(15 downto 0)  <= std_logic_vector(angle_in_bus);
						output_reg(31 downto 16) <= (others => '0');
						output_reg(15 downto 0)  <= std_logic_vector(angle_in_bus);

					--    output <= ddata_w;
					--    output_reg <= ddata_w;
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
