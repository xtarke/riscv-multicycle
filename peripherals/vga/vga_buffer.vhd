library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_buffer is
	port(
		clk           : in  std_logic;
		rst           : in  std_logic;
		address_vga   : in  std_logic_vector(31 downto 0);
		sdram_data    : in  std_logic_vector(15 downto 0);
		sdram_address : out std_logic_vector(31 downto 0);
		sdram_r       : out std_logic;
		VGA_R         : out std_logic_vector(3 downto 0);
		VGA_G         : out std_logic_vector(3 downto 0);
		VGA_B         : out std_logic_vector(3 downto 0)
	);
end entity vga_buffer;

architecture RTL of vga_buffer is
	type state_type is (WAIT_READ, WRITING_BANK1, WRITING_BANK2, IDLE);

	signal bank            : std_logic;
	signal bank_last_value : std_logic;
	signal index           : natural;

	type mem is array (0 to 15) of std_logic_vector(15 downto 0);
	signal memory : mem := (x"0001",x"0001",x"0001",x"0001",x"0001",x"0001",x"0001",x"0001",x"0001",x"0001",x"0001",x"0001",x"0001",x"0001",x"0001",x"0001");

begin

	bank  <= address_vga(3);
	VGA_R <= memory(index)(3 downto 0);
	VGA_G <= memory(index)(7 downto 4);
	VGA_B <= memory(index)(11 downto 8);
	index <= to_integer(unsigned(address_vga(3 downto 0)));

	process(clk, rst) is
		variable state       : state_type := WAIT_READ;
		variable counter     : natural    := 0;
		variable wait_cycles : natural;
	begin
		if rst = '1' then
			state := IDLE;
		elsif rising_edge(clk) then
			case state is
				when IDLE =>
					if bank /= bank_last_value then
						bank_last_value <= bank;
						sdram_address   <= std_logic_vector(to_unsigned((to_integer(unsigned(address_vga)) + 8), 32));
						sdram_r         <= '1';
						wait_cycles     := 5;
						state           := WAIT_READ;
					end if;

				when WAIT_READ =>
					wait_cycles := wait_cycles - 1;
					if wait_cycles = 0 then
						sdram_r <= '0';
						counter := 0;
						if bank = '1' then
							state := WRITING_BANK1;
						else
							state := WRITING_BANK2;
						end if;
					end if;

				when WRITING_BANK1 =>
					memory(counter) <= sdram_data;
					counter         := counter + 1;
					if counter = 8 then
						state := IDLE;
					end if;

				when WRITING_BANK2 =>
					memory(8 + counter) <= sdram_data;
					counter             := counter + 1;
					if counter = 8 then
						state := IDLE;
					end if;
			end case;
		end if;
	end process;

end architecture RTL;
