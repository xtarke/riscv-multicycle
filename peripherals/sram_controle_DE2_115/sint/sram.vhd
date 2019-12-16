library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity sram is
	PORT(
		SRAM_OE_N     : out   std_logic;
		SRAM_WE_N     : out   std_logic;
		SRAM_CE_N     : out   std_logic;
		SRAM_ADDR     : out   std_logic_vector(19 downto 0);
		SRAM_DQ       : inout std_logic_vector(15 downto 0);
		SRAM_UB_N     : out   std_logic;
		SRAM_LB_N     : out   std_logic;
		--

		clk           : IN    STD_LOGIC;
		chipselect    : IN    STD_LOGIC;
		write         : IN    STD_LOGIC;
		read		  : IN    STD_LOGIC;
		data_out          : in  STD_LOGIC_VECTOR(15 DOWNTO 0);
		address       : in    std_logic_vector(19 downto 0);
		--read_address  : IN    unsigned(15 downto 0);
		--write_address : IN    unsigned(15 downto 0);
		--we            : IN  STD_LOGIC;
		data_in             : OUT   STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
end entity sram;

architecture RTL of sram is
	type mem_state_type is (IDLE, READ_M, WRITE_M, DONE);
	signal mem_state : mem_state_type;

	--type reg_array is array (0 to 31) of std_logic_vector(7 downto 0);
	--signal memory : reg_array;

begin
	SRAM_ADDR <= address(19 downto 0);

	memory_state : process(clk)
	begin
		if rising_edge(clk) then
			case mem_state is
				when IDLE =>

					if chipselect = '1' then

						if write = '1' then
							mem_state <= WRITE_M;
						end if;
						if read = '1' then
							mem_state <= READ_M;
						end if;

					end if;

				when WRITE_M =>
					mem_state <= DONE;

				when READ_M =>
					mem_state <= DONE;

				when DONE =>
					mem_state <= IDLE;

			end case;
		end if;

	end process;

	memory_state_output : process(mem_state, SRAM_DQ, data_out)
	begin
		
		SRAM_CE_N <= '1';
		--SRAM_LB_N <= '0';
		--SRAM_UB_N <= '0';
		--SRAM_WE_N <= '0';
		--SRAM_OE_N <= '0';

		case mem_state is

			when IDLE =>
				SRAM_WE_N <= '1';
				SRAM_CE_N <= '0';
				SRAM_OE_N <= '1';
				SRAM_LB_N <= '0';
				SRAM_UB_N <= '0';
				
			when READ_M =>
				SRAM_WE_N <= '1';
				SRAM_CE_N <= '0';
				SRAM_OE_N <= '0';
				SRAM_LB_N <= '0';
				SRAM_UB_N <= '1';
				data_in <= SRAM_DQ;
				
			when WRITE_M =>
				SRAM_OE_N <= '0';
				SRAM_CE_N <= '0';
				SRAM_WE_N <= '0';
				SRAM_LB_N <= '0';
				SRAM_UB_N <= '1';
				SRAM_DQ <= data_out;

			when DONE =>
--				SRAM_WE_N <= '1';
--				SRAM_CE_N <= '0';
--				SRAM_OE_N <= '1';
--				SRAM_LB_N <= '0';
--				SRAM_UB_N <= '0';
				

		end case;
	end process;


end architecture RTL;
