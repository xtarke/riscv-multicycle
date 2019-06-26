library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.M_types.all;

entity tb_M is
end entity;

architecture waveform of tb_M is
	-------------------------------------------------------------------
	-- CLOCK
	signal clock_50_0_logic, clock_50_PI_logic: std_logic;

	-------------------------------------------------------------------
	-- M
	component M is
		port(
			CLOCK :in std_logic;
			M_DATA : in M_data_t;		
			DATAOUT  : out std_logic_vector(31 downto 0)
		);
	end component;

	--------------------------------------------------------------------
	-- A and B
	signal a_integer: integer; 
	signal a_signed: signed (31 downto 0);
	signal a_logic_vector: std_logic_vector (31 downto 0);

	signal b_integer: integer; 
	signal b_signed: signed (31 downto 0);
	signal b_logic_vector: std_logic_vector (31 downto 0);

	--------------------------------------------------------------------
	-- code
	signal code_logic_vector: std_logic_vector (3 downto 0);

	--------------------------------------------------------------------
	-- M_data
	signal M_data_record: M_data_t;

	--------------------------------------------------------------------
	-- DATAOUT
	signal M_data_out_integer: integer;
	signal M_data_out_signed: signed(31 downto 0);
	signal M_data_out_logic_vector: std_logic_vector(31 downto 0);

begin
	--===============================================================--
	-- CLOCK
	CLOCK_1_50: process -- 50 MHz phase 0
	begin
		clock_50_0_logic <= '1';
		wait for 10 ns;
		clock_50_0_logic <= '0';
		wait for 10 ns;
	end process;

	CLOCK_2_50: process -- 50 MHz phase pi
	begin
		clock_50_PI_logic <= '0';
		wait for 10 ns;
		clock_50_PI_logic <= '1';
		wait for 10 ns;
	end process;

	--===============================================================--
	-- M
	M_vhd: M
		port map(
			CLOCK => clock_50_0_logic,
			M_DATA => M_data_record,
			DATAOUT => M_data_out_logic_vector
		);

	--===============================================================--
	-- A and B
	a_signed <= To_signed(a_integer, 32);
	a_logic_vector <= Std_logic_vector(a_signed);

	b_signed <= To_signed(b_integer, 32);
	b_logic_vector <= Std_logic_vector(b_signed);

	a_integer <= 7;
	b_integer <= 3;

	--===============================================================--
	-- code 
	SET_CODE: process -- 50 MHz phase pi
	begin
		code_logic_vector <= "0000";
		wait for 10 ns;
		code_logic_vector <= "0001";
		wait for 10 ns;
		code_logic_vector <= "0010";
		wait for 10 ns;
		code_logic_vector <= "0011";
		wait for 10 ns;
		code_logic_vector <= "0100";
		wait for 10 ns;
		code_logic_vector <= "0101";
		wait for 10 ns;
		code_logic_vector <= "0110";
		wait for 10 ns;
		code_logic_vector <= "0111";
		wait for 10 ns;
	end process;	
	

	--===============================================================--
	-- M_data
	M_data_record.a	<= a_signed;
	M_data_record.b	<= b_signed;
	M_data_record.code <= code_logic_vector;

	--===============================================================--
	-- DATAOUT
	M_data_out_signed <= Signed(M_data_out_logic_vector);
	M_data_out_integer <= To_integer(M_data_out_signed);

	--&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&--
	-- Code
	M_data_record.code <= code_logic_vector;	

end architecture;