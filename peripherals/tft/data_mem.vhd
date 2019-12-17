library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity data_mem is
	generic(
		RAM_WIDTH : natural := 32;
		RAM_DEPTH : natural := 320;
		HEAD_INIT : natural := 0
	);
	port(
		clk     : in  std_logic;
		rst     : in  std_logic;
		wr_en   : in  std_logic;
		wr_data : in  unsigned(RAM_WIDTH - 1 downto 0);
		rd_en   : in  std_logic;
		rd_data : out unsigned(RAM_WIDTH - 1 downto 0);
		empty   : out std_logic;
		full    : out std_logic
	);
end entity;

architecture rtl_data_mem of data_mem IS
	type MEM is array (0 to RAM_DEPTH - 1) of unsigned(wr_data'range);

	signal ram_block : MEM := (others => x"00000000");

	subtype index_type is integer range ram_block'range;
	signal head : index_type;
	signal tail : index_type;

	signal empty_i      : std_logic;
	signal full_i       : std_logic;
	signal fill_count_i : integer range RAM_DEPTH - 1 downto 0;

	-- Increment and wrap
	procedure incr(signal index : inout index_type) is
	begin
		if index = index_type'high then
			index <= index_type'low;
		else
			index <= index + 1;
		end if;
	end procedure;

begin
	empty <= empty_i;
	full  <= full_i;

	-- Set the flags
	empty_i <= '1' when fill_count_i = 0 else '0';
	full_i  <= '1' when fill_count_i >= RAM_DEPTH - 1 else '0';

	-- Update the head pointer in write
	proc_head : process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				head <= HEAD_INIT;
			else

				if wr_en = '1' and full_i = '0' then
					incr(head);
				end if;

			end if;
		end if;
	end process;

	-- Update the tail pointer on read and pulse valid
	proc_tail : process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				tail <= 0;
			else
				if rd_en = '1' and empty_i = '0' then
					incr(tail);
				end if;

			end if;
		end if;
	end process;

	-- Write to and read from the RAM
	proc_ram : process(clk, ram_block, tail)
	begin
		if rising_edge(clk) then
			if wr_en = '1' then
				ram_block(head) <= wr_data;
			end if;
		end if;
		rd_data <= ram_block(tail);
	end process;

	-- Update the fill count
	proc_count : process(head, tail)
	begin
		if head < tail then
			fill_count_i <= head - tail + RAM_DEPTH;
		else
			fill_count_i <= head - tail;
		end if;
	end process;

end architecture;
