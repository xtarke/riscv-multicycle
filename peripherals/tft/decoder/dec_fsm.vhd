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
	signal state : state_type := IDLE;
begin

	process(clk) is
	begin
		if rising_edge(clk) then
			case state is
				when IDLE =>
					if start = '1' then
						color    <= input_a(15 downto 0);
						output_b <= input_b;
						output_c <= input_c;

						case input_a(31 downto 16) is
							when x"FFFF" => state <= RESET;
							when x"0001" => state <= CLEAN;
							when x"0002" => state <= SQR;
							when x"0003" => state <= RECT;
							when others  => state <= FINISHED;
						end case;
					end if;

				when RESET | CLEAN | SQR | RECT =>
					if ready = '1' then
						state <= FINISHED;
					end if;

				when FINISHED =>
					state <= IDLE;
			end case;
		end if;
	end process;

	process(state)
	begin
		sel <= x"00"; 
		
		case state is
			when IDLE     => sel <= x"00";
			when RESET    => sel <= x"01";
			when CLEAN    => sel <= x"02";
			when SQR      => sel <= x"03";
			when RECT     => sel <= x"04";
			when FINISHED => sel <= x"00";
		end case;
	end process;

end architecture;