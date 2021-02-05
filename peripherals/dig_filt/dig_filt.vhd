-- dig_filt.vhd
--  Created on: out 12, 2020
--     Author: Tarcis Becher
--      Instituto Federal de Santa Catarina
--
-- Digital filter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dig_filt is
	generic (
		--! Chip selec
		MY_CHIPSELECT : std_logic_vector(1 downto 0) := "10"
	);

	port(
		clk : in std_logic;
		rst : in std_logic;

		-- Core data bus signals
		-- ToDo: daddress shoud be unsgined
		daddress  : in  natural;
		ddata_w	  : in 	std_logic_vector(31 downto 0);
		ddata_r   : out	std_logic_vector(31 downto 0);
		d_we      : in std_logic;
		d_rd	  : in std_logic;
		dcsel	  : in std_logic_vector(1 downto 0);	--! Chip select 
		-- ToDo: Module should mask bytes (Word, half word and byte access)
		dmask     : in std_logic_vector(3 downto 0);	--! Byte enable mask

		-- hardware input/output signals		
		debug_leds	  : out	std_logic_vector(7 downto 0);
		debug_hex0	  : out	std_logic_vector(3 downto 0);
		debug_hex1	  : out	std_logic_vector(3 downto 0);
		debug_hex2	  : out	std_logic_vector(3 downto 0);
		debug_hex3	  : out	std_logic_vector(3 downto 0);
		debug_hex4	  : out	std_logic_vector(3 downto 0);
		debug_hex5	  : out	std_logic_vector(3 downto 0)
	);
end entity dig_filt;

architecture RTL of dig_filt is
	type crtl_state_type is (IDLE, RESET, NEW_DATA, WAIT_DATA);
	type new_data_state_type is (IDLE, GET_DATA_TO_BUFFER, WRITE_BUFFER_TO_AC_N_REG, UPDATE_INDEXES);
	
	signal crtl_state     : crtl_state_type;
	signal new_data_state : new_data_state_type;

	signal crtl_change_state : integer;
	signal new_data_change_state : integer;

	signal data_is_ready : std_logic;
	signal n_rst : std_logic;
	signal w_flag_encoder : std_logic_vector(31 downto 0);

	signal mem_data_in 	  : std_logic_vector((31) downto 0);
	signal mem_data_out	  : std_logic_vector((31) downto 0);
	signal mem_ctrl_reg	  : std_logic_vector((31) downto 0);

	signal reg_data_in	  : std_logic_vector((31) downto 0);

	-- signal acumulator	  : std_logic_vector((31+5) downto 0);
	
	type reg_array is array (0 to 31) of std_logic_vector (31 downto 0);
	signal registers : reg_array;

	signal reg_write_index 	  : integer range 0 to 31;


begin

	-- debug
	debug_leds <= mem_ctrl_reg (6 downto 0) & data_is_ready;
	debug_hex0 <= mem_data_out (3 downto 0);
	debug_hex1 <= mem_data_out (7 downto 4);
	debug_hex2 <= mem_data_in (3 downto 0);
	debug_hex3 <= mem_data_in (7 downto 4);
	debug_hex4 <= std_logic_vector(To_unsigned(reg_write_index, 4));

	-- code

	-- Process give output value
	process(clk, rst)
	begin
		if rst = '1' then
			ddata_r <= (others => '0');
		else
			if rising_edge(clk) then
				if (d_rd = '1') and (dcsel = MY_CHIPSELECT) then
					if to_unsigned(daddress, 32)(7 downto 0) = x"14" then 	-- core reading DIG_FILT_CTRL
						ddata_r <= mem_ctrl_reg;
						if (data_is_ready = '0') then
							ddata_r(31)<= '0';
						else
							ddata_r(31)<= '1';
						end if;
					elsif to_unsigned(daddress, 32)(7 downto 0) = x"15" then -- core reading DIG_FILT_IN
						ddata_r <= mem_data_in;
					elsif to_unsigned(daddress, 32)(7 downto 0) = x"16" then -- core reading DIG_FILT_OUT
						ddata_r <= mem_data_out;
						debug_hex5 <= mem_data_out(3 downto 0);
					end if;
				end if;
			end if;
		end if;
	end process;

	-- Main process
	state_change_and_do: process(clk, rst) is
		variable reg_write_addr : integer range 0 to 31 := 0;
		variable acumulator_buf: integer := 0;
	begin 
		if (rst = '1') then
			reg_write_addr := 0;
			acumulator_buf := 0;

			mem_data_out <= (others => '0');
			mem_data_in <= (others =>'0');
			mem_ctrl_reg <= (others =>'0');

			n_rst <= '0';
			crtl_change_state <= 0;
			new_data_change_state <= 0;
			reg_data_in <= (others => '0');
		
		elsif (rising_edge(clk)) then
			
			n_rst <= '1';
			-- filtro de entrada para os comandos
			if (d_we = '1') and (dcsel = MY_CHIPSELECT) then
				if to_unsigned(daddress, 32)(7 downto 0) = x"14" then -- core writing in DIG_FILT_CTRL
					if (data_is_ready = '1') then
						if ddata_w(0) = '1' then
							crtl_change_state <= 1;
						elsif ddata_w(1) = '1' then
							crtl_change_state <= 2;
						end if;
					end if;
					mem_ctrl_reg <= ddata_w;
				elsif to_unsigned(daddress, 32)(7 downto 0) = x"15" then -- core writing in DIG_FILT_IN
					mem_data_in <= ddata_w;
				elsif to_unsigned(daddress, 32)(7 downto 0) = x"16" then -- core writing in DIG_FILT_OUT
				end if;
			end if;

			-- control state machine
			if crtl_state = RESET then
				reg_write_addr := 0;
				acumulator_buf := 0;
				mem_data_in <= (others => '0');
				reg_data_in <= (others => '0');
				
				new_data_change_state <= 0;				
				crtl_change_state <= 0;
				n_rst <= '0';

			elsif crtl_state = NEW_DATA then
				new_data_change_state <= 1;
				crtl_change_state <= 3;

			elsif crtl_state = WAIT_DATA then
				mem_ctrl_reg <= (others => '0');
			end if;

			-- new_data state machine
			if new_data_state = GET_DATA_TO_BUFFER then
				reg_data_in <= mem_data_in;
				new_data_change_state <= 2;
			elsif new_data_state = WRITE_BUFFER_TO_AC_N_REG then
				-- change this line for the commented one
				acumulator_buf := 0;
				for i in 0 to 31 loop
					acumulator_buf := acumulator_buf + to_integer(unsigned(registers(i)));
				end loop;
				acumulator_buf := acumulator_buf/32;
				-------------------------------------------------
			--	if reg_write_index = 31 then
		 	--		acumulator_buf := acumulator_buf + to_integer(unsigned(reg_data_in)) - (registers(0));
			--	else
			--		acumulator_buf := acumulator_buf + to_integer(unsigned(reg_data_in)) - registers(reg_write_index+1);
			--	end if;
				new_data_change_state <= 3;
			elsif new_data_state = UPDATE_INDEXES then
				if reg_write_addr = 31 then
					reg_write_addr := 0;
				else
					reg_write_addr := reg_write_addr + 1;
				end if;
				crtl_change_state <= 0;
				new_data_change_state <= 0;
			end if;

		end if;
		reg_write_index <= reg_write_addr;
		mem_data_out <= Std_logic_vector(To_unsigned(acumulator_buf, (32)));
		
	end process;

	-- States Transition
	process(new_data_change_state, crtl_change_state)
	begin
		if (rst = '1') then
			new_data_state <= IDLE;
			crtl_state <= IDLE;
			data_is_ready <= '1';
		else
			-- new data state update
			if (new_data_change_state = 1) then
				new_data_state <= GET_DATA_TO_BUFFER;
			elsif (new_data_change_state = 2) then
				new_data_state <= WRITE_BUFFER_TO_AC_N_REG;
			elsif (new_data_change_state = 3) then
				new_data_state <= UPDATE_INDEXES;
			else
				new_data_state <= IDLE;
			end if;

			-- crtl state update
			if (crtl_change_state = 1) then
				data_is_ready <= '0';
				crtl_state <= RESET;
			elsif (crtl_change_state = 2) then
				data_is_ready <= '0';
				crtl_state <= NEW_DATA;
			elsif (crtl_change_state = 3) then
				crtl_state <= WAIT_DATA;
			else
				crtl_state <= IDLE;
				data_is_ready <= '1';
			end if;

		end if;
	end process;

	-- Process to update write reg
	enc_proc: process(crtl_state, reg_write_index) is
	begin
		w_flag_encoder <= (others => '0');
		w_flag_encoder(reg_write_index) <= '1';

	end process;

	-- Registers Bench to store values
	reg_gen: for i in 0 to 31 generate
	regs: entity work.reg32
		port map (
			clk => clk,
			sclr_n => n_rst,
			clk_ena => w_flag_encoder(i),
			datain => reg_data_in,
			reg_out => registers(i)
		);
	end generate;

end architecture RTL;
