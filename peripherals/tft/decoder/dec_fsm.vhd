library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dec_fsm is
	port(
		clk      : in  std_logic;
		ready    : in  std_logic;
		start    : in  std_logic;
		input_a  : in  unsigned(31 downto 0);
		input_b  : in  unsigned(31 downto 0);
		input_c  : in  unsigned(31 downto 0);
		color    : out unsigned(15 downto 0);
		output_b : out unsigned(31 downto 0);
		output_c : out unsigned(31 downto 0);
		sel      : out unsigned(7 downto 0)
	);
end entity;

architecture rtl_dec_fsm of dec_fsm is
	type state_type is (IDLE, RESET, CLEAN, SQR, RECT, FINISHED);
	signal state   : state_type;
	--signal start   : std_logic;
	signal start_i : std_logic;
	--signal cmd     : unsigned(15 downto 0);

	signal active : std_logic := '0';

begin
	--start <= input_a(31);
	--cmd   <= '0' & input_a(30 downto 16);

	start_detect : process(start, active) is
	begin
		if active = '0' then
			if rising_edge(start) then
				start_i  <= '1';
			end if;
		else
			start_i <= '0';
		end if;
	end process;

		process(start_i) is
		begin
			if rising_edge(start_i) then
				color    <= input_a(15 downto 0);
				output_b <= input_b;
				output_c <= input_c;
			end if;
		end process;

	moore : process(clk, start_i) is
	begin
		if start_i = '1' then
			state  <= IDLE;
			active <= '1';

		elsif rising_edge(clk) then
			case state is
				when IDLE =>
					if (start = '1') then
						active <= '1';
						case input_a(31 downto 16) is
							when x"FFFF" => state <= RESET;
							when x"0001" => state <= CLEAN;
							when x"0002" => state <= SQR;
							when x"0003" => state <= RECT;
							when others  => null;
						end case;
					end if;
				when RESET =>
					if (ready = '1') then
						active <= '0';
						state  <= FINISHED;
					end if;
				when CLEAN =>
					if (ready = '1') then
						active <= '0';
						state  <= FINISHED;
					end if;
				when RECT =>
					if (ready = '1') then
						active <= '0';
						state  <= FINISHED;
					end if;
				when SQR =>
					if (ready = '1') then
						active <= '0';
						state  <= FINISHED;
					end if;
				when FINISHED =>
					state  <= FINISHED;
					active <= '0';
			end case;
		end if;
	end process;

	mealy : process(state)
	begin
		sel <= (others => '0');
		case state is
			when IDLE =>
				null;
			when RESET =>
				sel <= x"01";
			when CLEAN =>
				sel <= x"02";
			when SQR =>
				sel <= x"03";
			when RECT =>
				sel <= x"04";
			when FINISHED =>
				null;
		end case;
	end process;

end architecture;
