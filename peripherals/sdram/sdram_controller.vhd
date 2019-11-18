--------------------------------------------------------------------------------
--  VLIW-RT CPU - SDRAM controller top entity
--------------------------------------------------------------------------------
--
-- Copyright (c) 2016, Renan Augusto Starke <xtarke@gmail.com>
-- 
-- Departamento de Automação e Sistemas - DAS (Automation and Systems Department)
-- Universidade Federal de Santa Catarina - UFSC (Federal University of Santa Catarina)
-- Florianópolis, Brasil (Brazil)
--
-- This file is part of VLIW-RT CPU.

-- VLIW-RT CPU is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- VLIW-RT CPU is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with VLIW-RT CPU.  If not, see <http://www.gnu.org/licenses/>.
--
-- This file uses Altera libraries subjected to Altera licenses
-- See altera-ip folder for more information

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity sdram_controller is

	-- Altera SDRAM controller configuration
	generic(
		ASIZE      : integer := 25;
		DSIZE      : integer := 32;
		ROWSIZE    : integer := 13;
		COLSIZE    : integer := 10;
		BANKSIZE   : integer := 2;
		ROWSTART   : integer := 10;
		COLSTART   : integer := 0;
		BANKSTART  : integer := 23;
		-- SDRAM latencies
		DATA_AVAL  : integer := 2;      -- cycles
		RESET_NOP  : integer := 4;      -- cycles
		RAS_TO_CAS : integer := 3;      -- cycles			
		PRE_TO_ACT : integer := 3;      -- cycles
		tRP        : integer := 3;      -- cycles
		tRC        : integer := 12       -- cycles
	);

	port(
		-- inputs:
		address     : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
		byteenable  : IN    STD_LOGIC_VECTOR(1 DOWNTO 0);
		chipselect  : IN    STD_LOGIC;
		clk         : IN    STD_LOGIC;
		clken       : IN    STD_LOGIC;
		reset       : IN    STD_LOGIC;
		reset_req   : IN    STD_LOGIC;
		write       : IN    STD_LOGIC;
		read        : in    std_logic;
		writedata   : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
		burst       : in    std_logic;
		-- outputs:
		readdata    : OUT   STD_LOGIC_VECTOR(15 DOWNTO 0);
		waitrequest : out   std_logic;
		DRAM_ADDR   : out   std_logic_vector(12 downto 0);
		DRAM_BA     : out   std_logic_vector(1 downto 0);
		DRAM_CAS_N  : out   std_logic;
		DRAM_CKE    : out   std_logic;
		DRAM_CLK    : out   std_logic;
		DRAM_CS_N   : out   std_logic;
		DRAM_DQ     : inout std_logic_vector(15 downto 0);
		DRAM_DQM    : out   std_logic_vector(1 downto 0);
		DRAM_RAS_N  : out   std_logic;
		DRAM_WE_N   : out   std_logic
	);
end entity sdram_controller;

architecture rtl of sdram_controller is

	type mem_state_type is (CONFIG, C_PRE, C_PRE_NOP, C_INIT_AUTO_REFRESH, C_LD, C_LD_BURST, C_AUTO_REFRESH, IDLE, WRITE_ROW, WRITE_COL, DATA_REG, DONE);
	signal mem_state     : mem_state_type;
	signal nop_nxt_state : mem_state_type;

	signal d_read  : std_logic;
	signal d_write : std_logic;

	constant WORD_SIZE : integer := 32;
	subtype word_t is std_logic_vector(WORD_SIZE - 1 downto 0);
	signal mem_data    : word_t;

	signal byteenable_reg : STD_LOGIC_VECTOR(1 DOWNTO 0);

	signal in_reg_en : std_logic;

	signal chip_en_reg : std_logic;

	-- sdram controller signal
	signal reset_n : std_logic;
	signal addr    : std_logic_vector(ASIZE - 1 downto 0);
	signal cmd     : std_logic_vector(2 downto 0);
	signal cmdack  : std_logic;
	signal datain  : std_logic_vector(DSIZE - 1 downto 0);
	signal dataout : std_logic_vector(DSIZE - 1 downto 0);
	signal dm      : std_logic_vector(DSIZE / 8 - 1 downto 0);
	signal cs_n    : std_logic_vector(1 downto 0);

	signal dram_addr_int : std_logic_vector(11 downto 0);

	signal cas_to_ras : std_logic_vector(3 downto 0);

	--
	signal row_addr  : std_logic_vector(ROWSIZE - 1 downto 0);
	signal col_addr  : std_logic_vector(COLSIZE - 1 downto 0);
	signal bank_addr : std_logic_vector(BANKSIZE - 1 downto 0);

	--
	signal wait_cycles           : std_logic_vector(3 downto 0);
	signal chipselect_last_value : std_logic;
	signal read_last_value       : std_logic;
	signal write_last_value      : std_logic;
	signal burst_last_value      : std_logic;

begin

	reset_n  <= not reset;
	DRAM_CLK <= clk;

	-- DRAM_CS_N <= cs_n(0);

	-- DRAM_ADDR <= '0' & dram_addr_int;

	-- FS_ADDR <= address(21 downto 2);

	do_clk_mem_acc_state : process(clk, reset, cmdack)
		variable refresh_counter      : natural;
		variable init_refresh_counter : natural;
		variable precharge_init 	  : std_logic := '0';
	begin
		if reset = '1' then
			mem_state   <= CONFIG;
			wait_cycles <= std_logic_vector(to_unsigned(RESET_NOP, wait_cycles'length));
		else
			if rising_edge(clk) then
				case mem_state is
					when CONFIG =>
						if reset = '0' then

							-- wait RESET_NOP cycles until first precharge
							wait_cycles <= wait_cycles - 1;

							if wait_cycles = 0 then
								init_refresh_counter := 0;
								mem_state            <= C_PRE;
								wait_cycles          <= std_logic_vector(to_unsigned(PRE_TO_ACT - 1, wait_cycles'length));
							end if;
						else
							wait_cycles <= "0000";
						end if;

					when C_PRE =>
						mem_state <= C_PRE_NOP;
						if precharge_init = '0' then
							nop_nxt_state <= C_INIT_AUTO_REFRESH;
							precharge_init := '1';
						else
							wait_cycles          <= std_logic_vector(to_unsigned(PRE_TO_ACT - 1, wait_cycles'length));
							nop_nxt_state <= C_AUTO_REFRESH;
							--mem_state <= IDLE;
						end if;

					when C_PRE_NOP =>
						wait_cycles <= wait_cycles - 1;

						if wait_cycles = 0 then
							mem_state <= nop_nxt_state;
						end if;

					when C_INIT_AUTO_REFRESH =>
						wait_cycles   <= std_logic_vector(to_unsigned(tRC, wait_cycles'length));
						mem_state     <= C_PRE_NOP;
						init_refresh_counter := init_refresh_counter + 1;
						if init_refresh_counter >= 2 then
							nop_nxt_state <= C_LD;
							init_refresh_counter := 0;
						end if;

					when C_LD =>
						wait_cycles   <= std_logic_vector(to_unsigned(PRE_TO_ACT, wait_cycles'length));
						mem_state     <= C_PRE_NOP;
						nop_nxt_state <= C_AUTO_REFRESH;

					when C_LD_BURST =>
						wait_cycles   <= std_logic_vector(to_unsigned(PRE_TO_ACT, wait_cycles'length));
						mem_state     <= C_PRE_NOP;
						nop_nxt_state <= C_AUTO_REFRESH;

					when C_AUTO_REFRESH =>
						wait_cycles   <= std_logic_vector(to_unsigned(tRC, wait_cycles'length));
						mem_state     <= C_PRE_NOP;
						--init_refresh_counter := init_refresh_counter + 1;
						--if init_refresh_counter >= 2 then
							nop_nxt_state <= IDLE;
							--init_refresh_counter := 0;
						--else
							--nop_nxt_state <= C_AUTO_REFRESH;
						--end if;

					when IDLE =>
						if refresh_counter = 10 then
							refresh_counter := 0;
							mem_state       <= C_AUTO_REFRESH;
						elsif burst = '1' and burst_last_value = '0' then
							refresh_counter := 0;
							mem_state       <= C_LD_BURST;
						elsif burst = '0' and burst_last_value = '1' then
							refresh_counter := 0;
							mem_state       <= C_LD;
						elsif chipselect = '1' and (read = '1' and read_last_value = '0') then
							refresh_counter := 0;
							read_last_value <= '1';
							mem_state       <= WRITE_ROW;
						elsif chipselect = '1' and (write = '1' and write_last_value = '0') then
							refresh_counter  := 0;
							write_last_value <= '1';
							mem_state        <= WRITE_ROW;
						end if;

						if read = '0' then
							read_last_value <= '0';
						end if;
						if write = '0' then
							write_last_value <= '0';
						end if;
						if burst /= burst_last_value then
							burst_last_value <= burst;
						end if;

						refresh_counter := refresh_counter + 1;

					when WRITE_ROW =>
						wait_cycles   <= std_logic_vector(to_unsigned(RAS_TO_CAS - 1, wait_cycles'length));
						mem_state     <= C_PRE_NOP;
						nop_nxt_state <= WRITE_COL;

					when WRITE_COL =>
						if read = '1' then
							wait_cycles   <= std_logic_vector(to_unsigned(DATA_AVAL - 1, wait_cycles'length));
							mem_state     <= C_PRE_NOP;
							nop_nxt_state <= DATA_REG;
						else
							mem_state <= DONE;
						end if;

					when DATA_REG =>
						mem_state <= DONE;

					when DONE =>
						mem_state <= C_PRE;

				end case;
			end if;
		end if;
	end process;

	row_addr  <= address(ROWSTART + ROWSIZE - 1 downto ROWSTART); -- (10 + (13 - 1) downto 9) -> (22 downto 10)	       -- assignment of the row address bits from address
	col_addr  <= address(COLSTART + COLSIZE - 1 downto COLSTART); -- (0 + (9 - 1) downto 	0) -> (9 downto 0)	       -- assignment of the column address bits
	bank_addr <= address(BANKSTART + BANKSIZE - 1 downto BANKSTART); -- (23 + (2 - 1) downto 23) -> (24 downto 23)    -- assignment of the bank address bits

	do_clk_mem_acc_state_output : process(mem_state, reset, chipselect, write, byteenable, address, chip_en_reg, byteenable_reg, bank_addr, row_addr, col_addr)
	begin
		in_reg_en   <= '0';
		waitrequest <= '0';
		d_read      <= '0';
		d_write     <= '0';

		-- altera sdram controller
		addr <= (others => '0');
		cmd  <= (others => '0');

		-- internal sdram controller
		DRAM_ADDR <= (others => '0');

		DRAM_BA    <= "00";
		DRAM_CS_N  <= '0';
		DRAM_CKE   <= '1';
		DRAM_RAS_N <= '1';
		DRAM_CAS_N <= '1';
		DRAM_WE_N  <= '1';

		DRAM_DQM <= "00";

		case mem_state is

			when CONFIG =>
				if reset = '0' then
					waitrequest <= '1';
					addr        <= (others => '0');
					DRAM_CS_N   <= '0';
				else
					DRAM_CKE <= '0';
				end if;

			when C_PRE =>
				waitrequest <= '1';

				-- precharge all banks
				DRAM_CS_N     <= '0';
				DRAM_RAS_N    <= '0';
				DRAM_CAS_N    <= '1';
				DRAM_WE_N     <= '0';
				-- all banks code
				DRAM_ADDR(10) <= '1';

			when C_PRE_NOP =>
				waitrequest <= '1';
				DRAM_CS_N   <= '0';

			when C_LD =>
				waitrequest <= '1';

				-- burst length: 1 word
				DRAM_ADDR(2 downto 0)   <= "000";
				-- burst type: sequential
				DRAM_ADDR(3)            <= '0';
				-- cas latency: 2
				DRAM_ADDR(6 downto 4)   <= "010";
				-- Op mode: standard operation
				DRAM_ADDR(8 downto 7)   <= "00";
				-- Write burst mode: single location
				DRAM_ADDR(9)            <= '1';
				-- reserved
				DRAM_ADDR(12 downto 10) <= "001";

				-- commands
				DRAM_BA    <= "00";
				DRAM_CS_N  <= '0';
				DRAM_RAS_N <= '0';
				DRAM_CAS_N <= '0';
				DRAM_WE_N  <= '0';

			when C_LD_BURST =>
				waitrequest <= '1';

				-- burst length: 8 words
				DRAM_ADDR(2 downto 0)   <= "011";
				-- burst type: sequential
				DRAM_ADDR(3)            <= '0';
				-- cas latency: 2
				DRAM_ADDR(6 downto 4)   <= "010";
				-- Op mode: standard operation
				DRAM_ADDR(8 downto 7)   <= "00";
				-- Write in nonburst mode: single location, Read in burst mode with specified length
				DRAM_ADDR(9)            <= '1';
				-- reserved
				DRAM_ADDR(12 downto 10) <= "001";

				-- commands
				DRAM_BA    <= "00";
				DRAM_CS_N  <= '0';
				DRAM_RAS_N <= '0';
				DRAM_CAS_N <= '0';
				DRAM_WE_N  <= '0';
				
			when C_INIT_AUTO_REFRESH =>

				-- commands
				DRAM_BA    <= "00";
				DRAM_CS_N  <= '0';
				DRAM_RAS_N <= '0';
				DRAM_CAS_N <= '0';
				DRAM_WE_N  <= '1';

			when C_AUTO_REFRESH =>

				-- commands
				DRAM_BA    <= "00";
				DRAM_CS_N  <= '0';
				DRAM_RAS_N <= '0';
				DRAM_CAS_N <= '0';
				DRAM_WE_N  <= '1';

				DRAM_ADDR(10) <= '1';

			when IDLE =>
				waitrequest <= chipselect;

			when WRITE_ROW =>
				waitrequest <= '1';

				DRAM_BA    <= bank_addr;
				DRAM_CS_N  <= '0';
				DRAM_RAS_N <= '0';
				DRAM_CAS_N <= '1';
				DRAM_WE_N  <= '1';

				DRAM_ADDR <= row_addr;

			when WRITE_COL =>
				waitrequest <= '1';

				if write = '1' then
					DRAM_DQM  <= not byteenable;
					d_write   <= '1';
					DRAM_WE_N <= '0';
				end if;

				DRAM_BA    <= bank_addr;
				DRAM_CS_N  <= '0';
				DRAM_RAS_N <= '1';
				DRAM_CAS_N <= '0';

				DRAM_ADDR(COLSIZE - 1 downto 0) <= col_addr;
				-- enable auto precharge
				DRAM_ADDR(10)                   <= '1';

			when DATA_REG =>
				waitrequest <= '1';
				d_read      <= '1';

			when DONE =>

		end case;
	end process;

	process(clk, reset, d_read, byteenable, DRAM_DQ)
		variable counter : natural   := 0;
		variable read    : std_logic := '0';
	begin
		if reset = '1' then
			readdata <= (others => '0');
		else
			if rising_edge(clk) then

				if d_read = '1' and burst = '1' then
					counter := 8;
				elsif d_read = '1' then
					counter := 1;
				end if;

				if counter > 0 then
					case byteenable is

						when "00" =>

						when "01" =>
							readdata <= x"00" & DRAM_DQ(7 downto 0);

						when "10" =>
							readdata <= x"00" & DRAM_DQ(15 downto 8);

						when "11" =>
							readdata <= DRAM_DQ;

						when others =>
					end case;
					counter := counter - 1;
				end if;

			end if;
		end if;
	end process;

	DRAM_DQ <= (DRAM_DQ'range => 'Z') WHEN (d_write = '0') ELSE writedata(15 downto 0);

	process(clk, reset, byteenable, in_reg_en)
	begin
		if reset = '1' then
			byteenable_reg <= "11";
		else
			if rising_edge(clk) and in_reg_en = '1' then
				byteenable_reg <= not byteenable;
				chip_en_reg    <= address(26);
			end if;
		end if;
	end process;

end rtl;
