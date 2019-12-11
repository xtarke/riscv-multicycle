library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dec_reset is
	port(
		clk			: in  std_logic;
		sel			: in  unsigned(7 downto 0);
		mem_init	: in  std_logic;
		completed	: out std_logic;
		rst			: out std_logic
	);
end entity;

architecture rtl_dec_reset of dec_reset is
	type state_type is (IDLE, RESET, FINISHED);
	
	signal state		: state_type;
	signal start		: std_logic;
	signal start_i		: std_logic;
begin
	
	start <= '1' when sel = x"01" else '0';
	
	start_detect : process(start, state) is
	begin
		if(state = RESET) then
			start_i <= '0';
		elsif rising_edge(start) then
			if state = IDLE then
				start_i <= '1';
			elsif state = FINISHED then
				start_i <= '1';
			end if;
		end if;
	end process;
	
	moore : process(clk, start_i) is
	begin
		if start_i = '1' then
			state <= RESET;
--		if rising_edge(start) then
--			state <= RESET;
		elsif rising_edge(clk) then
			case state is
				when IDLE =>
					if (mem_init = '1') then
						state <= FINISHED;
					end if;
				when RESET =>
					state <= IDLE;
				when FINISHED =>
					null;
			end case;
		end if;
	end process;

	mealy : process(state)
	begin
		completed <= '0';
		rst <= '0';
		case state is
			when IDLE =>
				null;
			when RESET =>
				rst <= '1';
			when FINISHED =>
				completed <= '1';
		end case;
	end process;

end architecture;
