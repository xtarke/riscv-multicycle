library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dec_rect is
	generic(
		WIDTH  : natural := 240;
		HEIGHT : natural := 320
	);
	port(
		clk       : in  std_logic;
		sel       : in  unsigned(7 downto 0);
		mem_full  : in  std_logic;
		color     : in  unsigned(15 downto 0);
		pos_x     : in  unsigned(15 downto 0);
		pos_y     : in  unsigned(15 downto 0);
		len_x     : in  unsigned(15 downto 0);
		len_y     : in  unsigned(15 downto 0);
		write_en  : out std_logic;
		output    : out unsigned(31 downto 0);
		completed : out std_logic
	);
end entity;

architecture rtl_dec_rect of dec_rect IS
	type state_type is (IDLE, INIT, FULL_VERIFY, FINISHED,
	                    SET_ADDRESS_X, SET_ADDRESS_Y, SET_DIR_1, SET_DIR_2, SET_DIR_3, SET_DIR_4,
	                    WRITE_X1, WRITE_X2, WRITE_Y1, WRITE_Y2);
	signal state      : state_type := IDLE;
	signal next_state : state_type := IDLE;

	signal x : unsigned(15 downto 0) := (others => '0');
	signal y : unsigned(15 downto 0) := (others => '0');

	signal len_x_cmp : unsigned(15 downto 0);
	signal len_y_cmp : unsigned(15 downto 0);
	signal len_y_i   : unsigned(15 downto 0);

	signal count_x : unsigned(15 downto 0) := (others => '0');
	signal count_y : unsigned(15 downto 0) := (others => '0');

	signal start   : std_logic;
	signal count   : natural := 0;
begin

	start <= '1' when sel = x"03"
	         else '1' when sel = x"04"
	         else '0';

	len_y_i <= len_x when sel = x"03" else len_y;

	len_x_cmp <= x + len_x;
	len_y_cmp <= y + len_y_i;

	limit_verify : process(pos_x, len_x, len_x_cmp, len_y, len_y_cmp, pos_y, x, y)
	begin
		if (pos_x > WIDTH) then
			x <= x"0000";
		else
			x <= pos_x;
		end if;

		if (pos_y > HEIGHT) then
			y <= x"0000";
		else
			y <= pos_y;
		end if;

		if (len_x_cmp > WIDTH) then
			count_x <= to_unsigned(WIDTH, 16) - x;
		else
			count_x <= len_x;
		end if;

		if (len_y_cmp > HEIGHT) then
			count_y <= to_unsigned(HEIGHT, 16) - y;
		else
			count_y <= len_y;
		end if;
	end process;

	process(clk) is
	begin
		if rising_edge(clk) then
			case state is
				when IDLE =>
					if start = '1' then
						state <= INIT;
					end if;

				when INIT =>
					state      <= FULL_VERIFY;
					next_state <= SET_ADDRESS_X;
					count      <= 0;

				when SET_ADDRESS_X =>
					state      <= FULL_VERIFY;
					next_state <= SET_ADDRESS_Y;
				
				when SET_ADDRESS_Y =>
					state      <= FULL_VERIFY;
					next_state <= SET_DIR_1;

				when SET_DIR_1 =>
					state      <= FULL_VERIFY;
					next_state <= WRITE_X1;

				when WRITE_X1 =>
					count <= count + 1;
					if (count < to_integer(count_x)) then
						state      <= FULL_VERIFY;
						next_state <= WRITE_X1;
					else
						state      <= FULL_VERIFY;
						next_state <= SET_DIR_2;
						count      <= 0;
					end if;

				when SET_DIR_2 =>
					state      <= FULL_VERIFY;
					next_state <= WRITE_Y1;

				when WRITE_Y1 =>
					count <= count + 1;
					if (count < to_integer(count_y)) then
						state      <= FULL_VERIFY;
						next_state <= WRITE_Y1;
					else
						state      <= FULL_VERIFY;
						next_state <= SET_DIR_3;
						count      <= 0;
					end if;

				when SET_DIR_3 =>
					state      <= FULL_VERIFY;
					next_state <= WRITE_X2;

				when WRITE_X2 =>
					count <= count + 1;
					if (count < to_integer(count_x)) then
						state      <= FULL_VERIFY;
						next_state <= WRITE_X2;
					else
						state      <= FULL_VERIFY;
						next_state <= SET_DIR_4;
						count      <= 0;
					end if;

				when SET_DIR_4 =>
					state      <= FULL_VERIFY;
					next_state <= WRITE_Y2;

				when WRITE_Y2 =>
					count <= count + 1;
					if (count < to_integer(count_y)) then
						state      <= FULL_VERIFY;
						next_state <= WRITE_Y2;
					else
						state      <= FULL_VERIFY;
						next_state <= FINISHED;
						count      <= 0;
					end if;

				when FULL_VERIFY =>
					if (mem_full = '0') then
						state <= next_state;
					else
						state <= FULL_VERIFY;
					end if;

				when FINISHED =>
					state <= IDLE;
			end case;
		end if;
	end process;

	mealy : process(state, color, x, y)
	begin
		completed <= '0';
		write_en  <= '1';
		output    <= (others => '0');
		case state is

			when IDLE =>
				write_en <= '0';

			when INIT =>
				output    <= x"00000000";

			when SET_ADDRESS_X =>
				output(31 downto 16) <= x"0020";
				output(15 downto 0)  <= x;
				
			when SET_ADDRESS_Y =>
				output(31 downto 16) <= x"0021";
				output(15 downto 0)  <= y;

			when SET_DIR_1 => 
				output <= x"00031030";

			when WRITE_X1 =>
				output(31 downto 16) <= x"0022";
				output(15 downto 0)  <= color;

			when SET_DIR_2 =>
				output <= x"00031038";

			when WRITE_Y1 =>
				output(31 downto 16) <= x"0022";
				output(15 downto 0)  <= color;

			when SET_DIR_3 =>
				output <= x"00031000";

			when WRITE_X2 =>
				output(31 downto 16) <= x"0022";
				output(15 downto 0)  <= color;

			when SET_DIR_4 =>
				output <= x"00031008";

			when WRITE_Y2 =>
				output(31 downto 16) <= x"0022";
				output(15 downto 0)  <= color;

			when FULL_VERIFY =>
				write_en <= '0';
				output   <= x"00000000";

			when FINISHED =>
				write_en  <= '0';
				output    <= x"00000000";
				completed <= '1';
		end case;
	end process;

end architecture;