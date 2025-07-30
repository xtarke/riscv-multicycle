---------------------------------------------------------------------
--! @file
--! @brief RISCV Simple GPIO module
--         RAM mapped general purpose I/O
--! @Todo: Module should mask bytes (Word, half word and byte access)
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity irda_bus is
	generic (
		--! Chip selec
		MY_CHIPSELECT : std_logic_vector(1 downto 0) := "10";
		-- IRDA BASE ADDRESS (4 most significant bytes)
		MY_WORD_ADDRESS : unsigned(15 downto 0) := x"0180";	
		DADDRESS_BUS_SIZE : integer := 32
	);
	
	port(
		clk : in std_logic;
      clk_50 : in std_logic;
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
		irda_sensor  : in std_logic;
      irda_debug : out std_logic_vector(31 downto 0)
	);
end entity irda_bus;

architecture RTL of irda_bus is
  
    signal irda_data : std_logic_vector(31 downto 0);
    signal data_ready : std_logic;
    signal rst_n : std_logic;    

begin 
    irda_debug <= irda_data;
	-- Input register
    process(clk, rst)
    begin
        if rst = '1' then
            ddata_r <= (others => '0');
        else
            if rising_edge(clk) then
                if (d_rd = '1') and (dcsel = MY_CHIPSELECT) then
                    if daddress(15 downto 0) = MY_WORD_ADDRESS then
                        ddata_r <= irda_data;
                    end if;
                end if;
            end if;
        end if;
    end process;

    rst_n <= not rst;
	 
    irda: entity work.irda
        port map(
            iCLK        => clk_50, 
            iRST_n      => rst_n,
            iIRDA       => irda_sensor,
            oDATA_READY => data_ready,
            oDATA       => irda_data
        );

end architecture RTL;
