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

entity nn_accelerator is
	generic (
		--! Chip selec
		MY_CHIPSELECT : std_logic_vector(1 downto 0) := "10";
		MY_WORD_ADDRESS : unsigned(15 downto 0) := x"00B0";	
		DADDRESS_BUS_SIZE : integer := 32;
		N_PRECISION : integer := 8
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
		dcsel	  : in std_logic_vector(1 downto 0)	--! Chip select 
	);
end entity nn_accelerator;

architecture RTL of nn_accelerator is
	-- Declaração de sinais
	-- index x_y: input x of neuron y
	signal x0 : std_logic_vector(N_PRECISION-1 downto 0);
	signal x1 : std_logic_vector(N_PRECISION-1 downto 0);
	signal y1 : std_logic_vector(N_PRECISION-1 downto 0);

	signal x0_0 : std_logic_vector(N_PRECISION-1 downto 0);
    signal x1_0 : std_logic_vector(N_PRECISION-1 downto 0);
    signal w0_0 : std_logic_vector(N_PRECISION-1 downto 0);
    signal w1_0 : std_logic_vector(N_PRECISION-1 downto 0);
    signal output_0 : std_logic_vector(N_PRECISION-1 downto 0);
	signal x0_1 : std_logic_vector(N_PRECISION-1 downto 0);
    signal x1_1 : std_logic_vector(N_PRECISION-1 downto 0);
    signal w0_1 : std_logic_vector(N_PRECISION-1 downto 0);
    signal w1_1 : std_logic_vector(N_PRECISION-1 downto 0);
    signal output_1 : std_logic_vector(N_PRECISION-1 downto 0);
	signal x0_2 : std_logic_vector(N_PRECISION-1 downto 0);
    signal x1_2 : std_logic_vector(N_PRECISION-1 downto 0);
    signal w0_2 : std_logic_vector(N_PRECISION-1 downto 0);
    signal w1_2 : std_logic_vector(N_PRECISION-1 downto 0);
    signal output_2 : std_logic_vector(N_PRECISION-1 downto 0);

begin
    -- Available neurons
    n0: entity work.perceptron 
        generic map (
            N => N_PRECISION
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
            N => N_PRECISION
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
            N => N_PRECISION
        ) 
        port map (
            x0 => x0_2,
            x1 => x1_2,
            w0 => w0_2,
            w1 => w1_2,
            output  => output_2
    );
    
    -- Hardcoded interconnections
    x0_0 <= x0;
    x0_1 <= x0;
    x1_0 <= x1;
    x1_1 <= x1;

    x0_2 <= output_0;
    x1_2 <= output_1;
    y1 <= output_2;

	-- Read result
    process(clk, rst)
    begin
        if rst = '1' then
            ddata_r <= (others => '0');
        else
            if rising_edge(clk) then
                if (d_rd = '1') and (dcsel = MY_CHIPSELECT) then
					ddata_r <= (others => '0');
					ddata_r(N_PRECISION-1 downto 0) <= output_0;
                    --ddata_r(N_PRECISION-1 downto 0) <= "01111111";
                end if;
            end if;
        end if;
    end process;

    -- Set inputs
	process(clk, rst)
	begin		
		if rst = '1' then
            w0_0 <= (others => '0');
            w1_0 <= (others => '0');
            w0_1 <= (others => '0');
            w1_1 <= (others => '0');
            w0_2 <= (others => '0');
            w1_2 <= (others => '0');
            x0 <= (others => '0');
            x1 <= (others => '0');
		else
			if rising_edge(clk) then
				if (d_we = '1') and (dcsel = MY_CHIPSELECT) then                    			
					if daddress(15 downto 0) = MY_WORD_ADDRESS then	
                        w0_0 <= ddata_w(N_PRECISION-1 downto 0);
                    elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 1) then	
                        w1_0 <= ddata_w(N_PRECISION-1 downto 0);
                    elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 2) then	
                        w0_1 <= ddata_w(N_PRECISION-1 downto 0);
                    elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 3) then
                        w1_1 <= ddata_w(N_PRECISION-1 downto 0);
                    elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 4) then	
                        w0_2 <= ddata_w(N_PRECISION-1 downto 0);
                    elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 5) then
                        x0 <= "11011111";	
                        w1_2 <= ddata_w(N_PRECISION-1 downto 0);
                    elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 6) then
                        --x0 <= "11111111";
                        x0 <= ddata_w(N_PRECISION-1 downto 0);
                    elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 7) then	
                        x1 <= ddata_w(N_PRECISION-1 downto 0);   
					end if;		
				end if;
			end if;
		end if;		
	end process;

end architecture RTL;
