library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity boot_mem is
	port(clk     : in  std_logic;
	     rst     : in  std_logic;
	     rd_en   : in  std_logic;
	     rd_data : out unsigned(31 downto 0);
	     empty   : out std_logic
	    );
end entity;

architecture rtl_boot_mem of boot_mem IS
	
	-- Define the length of the boot memory
	-- If you have 54 words in the memory, this number must be 53
	constant mem_lengh : natural := 53;
	
	type MEM is array (0 to mem_lengh) of unsigned(rd_data'range);
	signal ram_block : MEM := (x"00e58000", x"00000001", x"00010100", x"00020700",
	                           x"00031030", x"00040000", x"00080202", x"00090000",
	                           x"000A0000", x"000C0000", x"000D0000", x"000F0000",
	                           x"00100000", x"00110007", x"00120000", x"00130000",
	                           x"FFFF0032", x"001017B0", x"00110007", x"FFFF000A",
	                           x"0012013A", x"FFFF000A", x"00131A00", x"0029000c",
	                           x"FFFF000A", x"00300000", x"00310505", x"00320004",
	                           x"00350006", x"00360707", x"00370105", x"00380002",
	                           x"00390707", x"003C0704", x"003D0807", x"0060A700",
	                           x"00610001", x"006A0000", x"00210000", x"00200000",
	                           x"00800000", x"00810000", x"00820000", x"00830000",
	                           x"00840000", x"00850000", x"00900010", x"00920000",
	                           x"00930003", x"00950110", x"00970000", x"00980000",
	                           x"00070173", x"FFFF0032");
	
	signal tail		: integer range mem_lengh downto 0;
	signal count	: integer range mem_lengh downto 0;
	signal empty_i	: std_logic;
	
begin
	-- Set the empty flag
	empty <= empty_i;
	empty_i <= '1' when count = 0 else '0';
	
	-- Update the tail pointer on read and pulse valid
	proc_tail : process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				tail <= 0;
			else
				if rd_en = '1' and empty_i = '0' then
					tail <= tail + 1;
				end if;

			end if;
		end if;
	end process;

	rd_data <= ram_block(tail);
	count <= mem_lengh - tail;

end architecture;
