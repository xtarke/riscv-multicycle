library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dec_clean is
	generic(
		SIZE_DISPLAY : natural := 76800
	);
	port(
		clk       : in  std_logic;
		sel       : in  unsigned(7 downto 0);
		mem_full  : in  std_logic;
		color     : in  unsigned(15 downto 0);
		output    : out unsigned(31 downto 0);
		write_en  : out std_logic;
		completed : out std_logic
	);
end entity;

architecture rtl_dec_clean of dec_clean is
	type state_type is (IDLE, CLEAN_X, CLEAN_Y, CLEAN_RGB, FULL_VERIFY, FINISHED);
	signal state      : state_type;
	signal next_state : state_type;
	signal start      : std_logic;
	signal start_i    : std_logic;
begin

	start <= '1' when sel = x"02" else '0';

	start_detect : process(start, state) is
	begin
		if (state = CLEAN_X) then
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
		variable count_size : natural := 0;
	begin
		if start_i = '1' then
			state <= CLEAN_X;
		--		if rising_edge(start) then
		--			state <= CLEAN_X;
		elsif rising_edge(clk) then
			case state is
				when IDLE =>
					null;
				when CLEAN_X =>
					state      <= FULL_VERIFY;
					next_state <= CLEAN_Y;
				when CLEAN_Y =>
					state      <= FULL_VERIFY;
					next_state <= CLEAN_RGB;
				when CLEAN_RGB =>
					state      <= FULL_VERIFY;
					next_state <= CLEAN_RGB;
					count_size := count_size + 1;
					if (count_size >= SIZE_DISPLAY) then
						count_size := 0;
						state      <= FINISHED;
					end if;
				when FULL_VERIFY =>
					if (mem_full = '0') then
						state <= next_state;
					end if;
				when FINISHED =>
					null;
			end case;
		end if;
	end process;

	mealy : process(state, color)
	begin
		write_en  <= '0';
		completed <= '0';
		output    <= (others => '0');
		case state is
			when IDLE =>
				null;
			when CLEAN_X =>
				output   <= x"00200000";
				write_en <= '1';
			when CLEAN_Y =>
				output   <= x"00210000";
				write_en <= '1';
			when CLEAN_RGB =>
				output   <= x"0022" & color;
				write_en <= '1';
			when FULL_VERIFY =>
				write_en <= '0';
			when FINISHED =>
				completed <= '1';
		end case;
	end process;

end architecture;
