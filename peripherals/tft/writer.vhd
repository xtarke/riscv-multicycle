library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity writer is
	port(
		clk    : in  std_logic;
		reset  : in  std_logic;
		start  : in  std_logic;
		input   : in  unsigned(31 downto 0);
		output : out unsigned(7 downto 0);
		ready  : out std_logic;
		cs     : out std_logic;
		rs     : out std_logic;
		wr     : out std_logic
	);
end entity;

architecture RTL_writer of writer is
	type state_type is (IDLE, FINISH, DELAY_COUNT,
	                    CS_LOW, CS_HIGH, RS_LOW, RS_HIGH, DELAY, WR_LOW, WR_HIGH,
	                    LCD_CMD_HIGH, LCD_CMD_LOW, LCD_DATA_HIGH, LCD_DATA_LOW
	                   );
	signal state     : state_type;
	signal state_out : state_type;
	signal count     : unsigned(31 downto 0);
	signal count_cmp : unsigned(31 downto 0);
	
	-- Define the adjust of delay_ms, based on clock
	-- ADJ must be clk/1000
	constant ADJ : natural := 10000;
	
begin

	state_transation : process(clk, reset) is
	begin
		if (reset = '1') then
			state <= IDLE;
			count <= (others => '0');
		elsif rising_edge(clk) then
			case state is
				when IDLE =>
					if start = '1' then
						if (input(31 downto 16) = x"FFFF") then
							state <= DELAY_COUNT;
						else
							state <= CS_LOW;
						end if;
					end if;
				when DELAY_COUNT =>
					count_cmp <= input(15 downto 0) * ADJ;
					if (count = count_cmp) then
						state <= FINISH;
					else
						count <= count + 1;
					end if;
				when CS_LOW =>
					state <= RS_LOW;
				when CS_HIGH =>
					state <= FINISH;
				when RS_LOW =>
					state <= LCD_CMD_HIGH;
				when RS_HIGH =>
					state <= LCD_DATA_HIGH;
				when DELAY =>
					state <= WR_LOW;
				when WR_LOW =>
					state <= WR_HIGH;
				when WR_HIGH =>
					if (state_out = LCD_CMD_HIGH) then
						state <= LCD_CMD_LOW;
					elsif (state_out = LCD_CMD_LOW) then
						state <= RS_HIGH;
					elsif (state_out = LCD_DATA_HIGH) then
						state <= LCD_DATA_LOW;
					elsif (state_out = LCD_DATA_LOW) then
						state <= CS_HIGH;
					end if;
				when LCD_CMD_HIGH =>
					state_out <= LCD_CMD_HIGH;
					state     <= DELAY;
				when LCD_CMD_LOW =>
					state_out <= LCD_CMD_LOW;
					state     <= DELAY;
				when LCD_DATA_HIGH =>
					state_out <= LCD_DATA_HIGH;
					state     <= DELAY;
				when LCD_DATA_LOW =>
					state_out <= LCD_DATA_LOW;
					state     <= DELAY;
				when FINISH =>
					count <= (others => '0');
					state <= IDLE;
			end case;
		end if;
	end process;

	mealy_moore : process(state, state_out, input)
	begin
		case state is
			when IDLE =>
				ready <= '1';

				output <= (others => '0');
				cs     <= '1';
				rs     <= '1';
				wr     <= '1';
			when FINISH =>
				ready <= '1';

				output <= (others => '0');
				cs     <= '1';
				rs     <= '1';
				wr     <= '1';
			when DELAY_COUNT =>
				ready <= '0';

				output <= (others => '0');
				cs     <= '1';
				rs     <= '1';
				wr     <= '1';
			when CS_LOW =>
				ready <= '0';
				cs    <= '0';

				output <= (others => '0');
				rs     <= '1';
				wr     <= '1';
			when CS_HIGH =>
				cs <= '1';

				ready  <= '0';
				output <= (others => '0');
				rs     <= '1';
				wr     <= '1';
			when RS_LOW =>
				rs <= '0';

				ready  <= '0';
				output <= (others => '0');
				cs     <= '0';
				wr     <= '1';
			when RS_HIGH =>
				rs <= '1';

				ready  <= '0';
				output <= (others => '0');
				cs     <= '0';
				wr     <= '1';
			when DELAY =>

				ready <= '0';
				cs    <= '0';
				wr    <= '1';
				if (state_out = LCD_CMD_HIGH) then
					rs     <= '0';
					output <= input(31 downto 24);
				elsif (state_out = LCD_CMD_LOW) then
					rs     <= '0';
					output <= input(23 downto 16);
				elsif (state_out = LCD_DATA_HIGH) then
					rs     <= '1';
					output <= input(15 downto 8);
				else
					output <= input(7 downto 0);
					rs     <= '1';
				end if;
			when WR_LOW =>
				wr <= '0';

				ready <= '0';
				cs    <= '0';
				if (state_out = LCD_CMD_HIGH) then
					rs     <= '0';
					output <= input(31 downto 24);
				elsif (state_out = LCD_CMD_LOW) then
					rs     <= '0';
					output <= input(23 downto 16);
				elsif (state_out = LCD_DATA_HIGH) then
					rs     <= '1';
					output <= input(15 downto 8);
				else
					output <= input(7 downto 0);
					rs     <= '1';
				end if;
			when WR_HIGH =>
				wr <= '1';

				ready <= '0';
				cs    <= '0';
				if (state_out = LCD_CMD_HIGH) then
					rs     <= '0';
					output <= input(31 downto 24);
				elsif (state_out = LCD_CMD_LOW) then
					rs     <= '0';
					output <= input(23 downto 16);
				elsif (state_out = LCD_DATA_HIGH) then
					rs     <= '1';
					output <= input(15 downto 8);
				else
					output <= input(7 downto 0);
					rs     <= '1';
				end if;
			when LCD_CMD_HIGH =>
				output <= input(31 downto 24);

				ready <= '0';
				cs    <= '0';
				rs    <= '0';
				wr    <= '1';
			when LCD_CMD_LOW =>
				output <= input(23 downto 16);

				ready <= '0';
				cs    <= '0';
				rs    <= '0';
				wr    <= '1';
			when LCD_DATA_HIGH =>
				output <= input(15 downto 8);

				ready <= '0';
				cs    <= '0';
				rs    <= '1';
				wr    <= '1';
			when LCD_DATA_LOW =>
				output <= input(7 downto 0);

				ready <= '0';
				cs    <= '0';
				rs    <= '1';
				wr    <= '1';
		end case;
	end process;

end architecture;
