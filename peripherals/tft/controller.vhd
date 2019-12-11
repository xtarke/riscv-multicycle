library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is
	port(
		clk      : in  std_logic;
		reset    : in  std_logic;
		ready    : in  std_logic;
		start    : out std_logic;
		mux_sel  : out std_logic;
		empty_1  : in  std_logic;
		empty_2  : in  std_logic;
		read_en1 : out std_logic;
		read_en2 : out std_logic
	);
end entity;

architecture rtl_controller of controller is
	type state_type is (IDLE, READ, WRITE);
	signal state : state_type;
begin
	moore : process(clk, reset) is
	begin
		if (reset = '1') then
			state <= WRITE;

		elsif rising_edge(clk) then
			case state is
				when IDLE =>
					if (ready = '1') then
						state <= READ;
					end if;
				when READ =>
					if (empty_1 = '0') then
						state <= WRITE;
					elsif (empty_2 = '0') then
						state <= WRITE;
					else
						state <= IDLE;
					end if;
				when WRITE =>
					state <= IDLE;
			end case;
		end if;
	end process;

	mealy : process(state, empty_1, empty_2)
	begin
		start    <= '0';
		read_en1 <= '0';
		read_en2 <= '0';
		
		mux_sel  <= '1';--
		
		if (empty_1 = '0') then
			mux_sel  <= '0';
		--elsif (empty_2 = '0') then
			--mux_sel  <= '1';
		end if;

		case state is
			when IDLE =>
				null;
			when READ =>
				if (empty_1 = '0') then
					read_en1 <= '1';
				elsif (empty_2 = '0') then
					read_en2 <= '1';
				end if;
			when WRITE =>
				start <= '1';
		end case;
	end process;

end architecture;
