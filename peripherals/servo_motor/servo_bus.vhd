---------------------------------------------------------------------
--! @file
--! @brief RISCV Simple GPIO module
--         RAM mapped general purpose I/O
--! @Todo: Module should mask bytes (Word, half word and byte access)
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity servo_bus is
	generic (
		--! Chip selec
		MY_CHIPSELECT : std_logic_vector(1 downto 0) := "10";
		-- IRDA BASE ADDRESS (4 most significant bytes)
		MY_WORD_ADDRESS : unsigned(15 downto 0) := x"0190";	
		DADDRESS_BUS_SIZE : integer := 32
	);
	
	port(
		clk : in std_logic;
        -- clk_bus : in std_logic;
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
        pwm       : out std_logic;
		
		-- hardware input/output signals
        --mudar esses apar o servo
		--servo_sensor  : in std_logic;
        servo_debug : out std_logic_vector(31 downto 0);
        rotate_o  : out unsigned(31 downto 0)
	);
end entity servo_bus;

architecture RTL of servo_bus is
  
    signal servo_data : std_logic_vector(31 downto 0);
    signal data_ready : std_logic;
    signal rotate : unsigned(31 downto 0);

begin 
    servo_debug <= servo_data;
	-- Input register
    process(clk, rst)
    begin
        if rst = '1' then
            rotate <= (others => '0');
        else
            if rising_edge(clk) then
                if (d_we = '1') and (dcsel = MY_CHIPSELECT) then
                    if daddress(15 downto 0) = MY_WORD_ADDRESS then
                        rotate <= unsigned(ddata_w);
                    end if;
                end if;
            end if;
        end if;
    end process;

    rotate_o <= rotate;

	 
    servo: entity work.pwm
        port map( -- substituir as portas
            clk      => clk, 
            rst      => rst,
            rotate   => rotate,
            pwm      => pwm
        );
        
end architecture RTL;
