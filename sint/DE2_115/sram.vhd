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
		--data          : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		address       : in    std_logic_vector(19 downto 0);
		read_address  : IN    unsigned(15 downto 0);
		write_address : IN    unsigned(15 downto 0);
		--we            : IN  STD_LOGIC;
		q             : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
end entity sram;

architecture RTL of sram is
	type mem_state_type is (IDLE, READ_M, WRITE_M, DONE);
	signal mem_state : mem_state_type;

	signal d_read  : std_logic;
	signal d_write : std_logic;

	signal byteenable_reg : STD_LOGIC_VECTOR(3 DOWNTO 0);

	signal in_reg_en : std_logic;

	signal chip_en_reg : std_logic;
	--type reg_array is array (0 to 31) of std_logic_vector(7 downto 0);
	--signal memory : reg_array;

begin
	SRAM_ADDR <= address(19 downto 0);

	memory_state : process(clk, mem_state)
	begin
		if rising_edge(clk) then
			case mem_state is
				when IDLE =>

					if chipselect = '1' then

						if write = '1' then
							mem_state <= WRITE_M;
						else
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

	memory_state_output : process(mem_state, chipselect, write, address, chip_en_reg, byteenable_reg)
	begin

		SRAM_CE_N <= '1';

		case mem_state is

			when IDLE =>
				SRAM_WE_N <= '1';
				SRAM_CE_N <= '0';
				SRAM_OE_N <= '1';
				
			when READ_M =>
				SRAM_WE_N <= '1';
				SRAM_CE_N <= '0';
				SRAM_OE_N <= '0';
				SRAM_LB_N <= '0';
				SRAM_UB_N <= '1';

			when WRITE_M =>
				SRAM_CE_N <= '0';
				SRAM_WE_N <= '0';
				SRAM_LB_N <= '0';
				SRAM_UB_N <= '1';
 
				SRAM_DQ <= "0000010000000000";

			when DONE =>

		end case;
	end process;

--	process(clk)
--	begin
--		if rising_edge(clk) then
--			SRAM_DQ <= address;
--		end if;

--	end process;

end architecture RTL;
