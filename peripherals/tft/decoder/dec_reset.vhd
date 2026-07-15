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
	type state_type is (IDLE, RESET_PULSE, WAIT_INIT, FINISHED);
	signal state : state_type := IDLE;
	signal start : std_logic;
begin
	
	start <= '1' when sel = x"01" else '0';
	
	process(clk) is
	begin
		if rising_edge(clk) then
			case state is
				when IDLE =>
					if start = '1' then
						state <= RESET_PULSE;
					end if;
				when RESET_PULSE =>
					state <= WAIT_INIT;
				when WAIT_INIT =>
					if (mem_init = '1') then
						state <= FINISHED;
					end if;
				when FINISHED =>
					state <= IDLE;
			end case;
		end if;
	end process;

	process(state)
	begin
		completed <= '0';
		rst <= '0';
		case state is
			when RESET_PULSE =>
				rst <= '1';
			when FINISHED =>
				completed <= '1';
			when others =>
				null;
		end case;
	end process;
end architecture;