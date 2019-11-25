library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity write_cdmdata is
	port(
		clk 		: in std_logic;
		reset		: in std_logic;
		
		start		: in std_logic;
		ready		: out std_logic;
		
		data		: in unsigned(31 downto 0);
		output		: out unsigned(7 downto 0);
		cs			: out std_logic;
		rs			: out std_logic;
		wr			: out std_logic
	);
end entity;

architecture RTL_fsm_cdm_data of write_cdmdata is
	type state_type is (IDLE, FINISH, DELAY_COUNT,
						CS_LOW, CS_HIGH, RS_LOW, RS_HIGH, DELAY, WR_LOW, WR_HIGH, 
						LCD_CMD_HIGH, LCD_CMD_LOW, LCD_DATA_HIGH, LCD_DATA_LOW
	);
	signal state 	: state_type;
	signal state_out: state_type;
	signal data_cp 	: unsigned(31 downto 0);
	signal count	: unsigned(15 downto 0);
begin

	state_transation : process(clk, reset) is
	begin
		if(reset = '1') then
			state <= IDLE;
			count <= (others => '0');
		elsif rising_edge(clk) then
			case state is 
				when IDLE =>
					data_cp <= data;
					if start = '1' then
						if (data(31 downto 16) = x"FFFF") then
							state <= DELAY_COUNT;
						else
							state <= CS_LOW;
						end if;
					end if;
				when DELAY_COUNT =>
					if (count = data_cp(15 downto 0)) then
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
					state <= DELAY;
				when LCD_CMD_LOW =>
					state_out <= LCD_CMD_LOW;
					state <= DELAY;
				when LCD_DATA_HIGH =>
					state_out <= LCD_DATA_HIGH;
					state <= DELAY;
				when LCD_DATA_LOW =>
					state_out <= LCD_DATA_LOW;
					state <= DELAY;
				when FINISH =>
					count <= (others => '0');
					state <= IDLE;
			end case;
		end if;
	end process;
	
	mealy_moore: process(state, reset, data_cp)
	begin
		if(reset = '1') then
			cs <= '0';
			rs <= '0';
			wr <= '0';
			ready <= '1';
			output <= (others => '0');
		else
			case state is 
				when IDLE =>
					null;
				when FINISH =>
					ready <= '1';
				when DELAY_COUNT =>
					ready <= '0';
				when CS_LOW =>
					ready <= '0';
					cs <= '0';
				when CS_HIGH =>
					cs <= '1';
				when RS_LOW =>
					rs <= '0';
				when RS_HIGH =>
					rs <= '1';
				when DELAY =>
					null;
				when WR_LOW =>
					wr <= '0';
				when WR_HIGH =>
					wr <= '1';
				when LCD_CMD_HIGH =>
					output <= data_cp(31 downto 24);
				when LCD_CMD_LOW =>
					output <= data_cp(23 downto 16);
				when LCD_DATA_HIGH =>
					output <= data_cp(15 downto 8);
				when LCD_DATA_LOW =>
					output <= data_cp(7 downto 0);
			end case;
		end if;
	end process;
	
end architecture;
