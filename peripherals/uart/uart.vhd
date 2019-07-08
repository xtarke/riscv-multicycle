library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is
	
	port(
		clk_in_1M	: in std_logic;
		clk_baud	: in std_logic;
		csel		: in std_logic;
		
		data_in		: in std_logic_vector(7 downto 0);
		tx 			: out std_logic;
		tx_cmp		: out std_logic;
		
		data_out	: out std_logic_vector(7 downto 0);
		rx			: in std_logic;
		rx_cmp		: out std_logic	
	);
end entity uart;

architecture RTL of uart is		
	-- Signals for TX
	type state_tx_type is (IDLE, MOUNT_BYTE, TRANSMIT);
	signal state_tx : state_tx_type := IDLE;
	signal cnt_tx	: integer := 0;
	signal to_tx 	: std_logic_vector(10 downto 0) := (others => '1');
	signal send_byte : boolean := FALSE;
	
	-- Signals for RX
	type state_rx_type is (IDLE, READ_BYTE);
	signal state_rx : state_rx_type := IDLE;
	signal cnt_rx	: integer := 0;
	signal byte_received : boolean := FALSE;
begin	
	
	-------------------- TX --------------------
	
	-- Maquina de estado TX: Moore
	estado_tx: process(clk_in_1M) is
	begin
		if rising_edge(clk_in_1M) then
			case state_tx is
				when IDLE =>
					if csel = '1' then
						state_tx <= MOUNT_BYTE;
					else
						state_tx <= IDLE;
					end if;
				when MOUNT_BYTE =>
						state_tx <= TRANSMIT;
				when TRANSMIT =>
					if (cnt_tx < 10) then
						state_tx <= TRANSMIT;
					else
						state_tx <= IDLE;
					end if;
			end case;
		end if;
	end process;
	
	-- Maquina MEALY: transmission
	tx_proc: process(state_tx, data_in)
	begin
		
		tx_cmp <= '0';
		send_byte <= FALSE;
		
		case state_tx is
			when IDLE =>
				tx_cmp 		<= '1';
				to_tx 		<= (others => '1');
				send_byte 	<= FALSE;
				
			when MOUNT_BYTE =>
				to_tx 		<= "11" & data_in & '0';
				tx_cmp 		<= '0';
				send_byte 	<= FALSE;
			
			when TRANSMIT =>
				send_byte 	<= TRUE;
				to_tx 		<= "11" & data_in & '0';
		end case;
		
	end process;
	
	tx_send: process(clk_baud, send_byte)
	begin
		if send_byte = TRUE then
			if rising_edge(clk_baud) then
				tx 		<= to_tx(cnt_tx);
				cnt_tx 	<= cnt_tx + 1;
			end if;
		else
			tx 		<= '1';
			cnt_tx 	<= 0;
		end if;
	end process;
	
	-------------------- RX --------------------
	-- Maquina de estado RX: Moore
	estado_rx: process(clk_in_1M) is
	begin
		if rising_edge(clk_in_1M) then
			case state_rx is
				when IDLE =>
					if rx = '0' then
						state_rx <= READ_BYTE;
					else
						state_rx <= IDLE;
					end if;
				when READ_BYTE =>
					if (cnt_rx < 10) then
						state_rx <= READ_BYTE;
					else
						state_rx <= IDLE;
					end if;
			end case;
		end if;
	end process;
	
	-- Maquina MEALY: transmission
	rx_proc: process(state_rx)
	begin
		
		case state_rx is
			when IDLE =>
				rx_cmp 		<= '1';
				byte_received <= FALSE;
				
			when READ_BYTE =>
				rx_cmp 		<= '0';
				byte_received 	<= TRUE;
			
		end case;
		
	end process;
	
	rx_receive: process(clk_baud, byte_received)
		variable from_rx 	: std_logic_vector(9 downto 0);
	begin
		if byte_received = TRUE then
			if rising_edge(clk_baud) then
				from_rx(cnt_rx)	:= rx;
				cnt_rx 	<= cnt_rx + 1;
				if cnt_rx = 8 then
					data_out <= from_rx(8 downto 1);
				end if;
			end if;
		else
			cnt_rx 	<= 0;
		end if;
	end process;
	
end architecture RTL;
