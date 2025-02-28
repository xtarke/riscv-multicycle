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
		MY_WORD_ADDRESS : unsigned(15 downto 0) := x"0150";	
		DADDRESS_BUS_SIZE : integer := 32;
		DATA_WIDTH_BUS : integer := 16
	);
	
	port(
		clk : in std_logic;
		clk_32x : in std_logic;
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
    	valid_bus    : out std_logic
	);
end entity cordic_bus;

architecture RTL of cordic_bus is

    signal enable_exti_mask: std_logic_vector(31 downto 0);
    signal edge_exti_mask  : std_logic_vector(31 downto 0);
    
	signal output          : std_logic_vector(31 downto 0);
    signal output_reg      : std_logic_vector(31 downto 0);

	signal converted_angle_in : signed(15 downto 0);
	signal converted_sin_out  : signed(15 downto 0);
	signal converted_cos_out  : signed(15 downto 0);

	signal start_reg : std_logic := '0';
    
begin

	converted_angle_in <= signed(output(15 downto 0));
	
	cordic_inst: entity work.cordic_core
	port map(
		clk_bus => clk_32x,
		rst_bus => rst,
		start => start_reg,
		angle_in => converted_angle_in,
		sin_out => converted_sin_out,
		cos_out => converted_cos_out,
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
						ddata_r <= (others => '0');
                        case dmask is
                            when "1111" => 
								ddata_r <= std_logic_vector(converted_sin_out) & std_logic_vector(converted_cos_out);
                            when "0011" => 
								if (converted_cos_out(15) = '0') then
									ddata_r <= x"0000" & std_logic_vector(converted_cos_out);
								else
									ddata_r <= x"FFFF" & std_logic_vector(converted_cos_out);
								end if;
                            when "1100" => 
								if (converted_sin_out(15) = '0') then
									ddata_r <= x"0000" & std_logic_vector(converted_sin_out);
								else
									ddata_r <= x"FFFF" & std_logic_vector(converted_sin_out);
								end if;
                            when others =>
                        end case;

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
			start_reg <= '0';
		elsif rising_edge(clk) then		
				if (d_we = '1') and (dcsel = MY_CHIPSELECT) then				
					if daddress(15 downto 0) = (MY_WORD_ADDRESS + 1) then
						
						output <= x"0001" & ddata_w(15 downto 0);
						output_reg <= std_logic_vector(ddata_w);
						start_reg   <= '1';
					
					elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 2) then
                        enable_exti_mask <= ddata_w;
						start_reg <= '0';
                    elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 3) then
                        edge_exti_mask <= ddata_w;
						start_reg <= '0';
					else
						start_reg <= '0';
					end if;
				else
					start_reg <= '0';
				-- end if;
			end if;
		end if;		
	end process;

end architecture RTL;
