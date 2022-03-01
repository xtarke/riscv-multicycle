-------------------------------------------------------
--! @file
--! @brief RISCV Simple GPIO module
--         RAM mapped general purpose I/O

--! @Todo: Module should mask bytes (Word, half word and byte access)
--         
--        
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gpio is
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
		dmask     : in std_logic_vector(3 downto 0);	--! Byte enable mask
		
		-- hardware input/output signals
        --REMOVE
		input  : in std_logic_vector(31 downto 0);
		output : out std_logic_vector(31 downto 0);		
	    gpio_interrupts : out std_logic_vector(6 downto 0)   
	);
end entity gpio;

architecture RTL of gpio is
	-- Declaração de sinais
    signal myInterrupts_d : std_logic_vector(6 downto 0); 
    signal interrupts: std_logic_vector(6 downto 0);
    
    signal enable_exti_mask: std_logic_vector(31 downto 0);
    signal edge_exti_mask: std_logic_vector(31 downto 0);
    
    signal EXTIx    : std_logic_vector(31 downto 0);
    
    signal EXTI5_9  : std_logic;
    signal EXTI10_15: std_logic;
    signal output_reg:std_logic_vector(31 downto 0);    
    

	-- index x_y: input x of neuron y
	signal x0_0 : std_logic_vector(N-1 downto 0);
    signal x1_0 : std_logic_vector(N-1 downto 0);
    signal w0_0 : std_logic_vector(N-1 downto 0);
    signal w1_0 : std_logic_vector(N-1 downto 0);
    signal output_0 : std_logic_vector(N-1 downto 0);
	signal x0_1 : std_logic_vector(N-1 downto 0);
    signal x1_1 : std_logic_vector(N-1 downto 0);
    signal w0_1 : std_logic_vector(N-1 downto 0);
    signal w1_1 : std_logic_vector(N-1 downto 0);
    signal output_1 : std_logic_vector(N-1 downto 0);
	signal x0_2 : std_logic_vector(N-1 downto 0);
    signal x1_2 : std_logic_vector(N-1 downto 0);
    signal w0_2 : std_logic_vector(N-1 downto 0);
    signal w1_2 : std_logic_vector(N-1 downto 0);
    signal output_2 : std_logic_vector(N-1 downto 0);

begin
    -- Available neurons
    n0: entity work.perceptron 
        generic map (
            N => N
        ) 
        port map (
            x0 => x0_0,
            x1 => x1_0,
            w0 => w0_0,
            w1 => w1_0,
            output  => output_0
    );

    n1: entity work.perceptron 
        generic map (
            N => N
        ) 
        port map (
            x0 => x0_1,
            x1 => x1_1,
            w0 => w0_1,
            w1 => w1_1,
            output  => output_1
    );

    n2: entity work.perceptron 
        generic map (
            N => N
        ) 
        port map (
            x0 => x0_2,
            x1 => x1_2,
            w0 => w0_2,
            w1 => w1_2,
            output  => output_2
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
