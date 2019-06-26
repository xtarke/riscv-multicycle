LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package M_types is

	--! Record for instruction decoding
	type M_data_t is record
		a : signed(31 downto 0);	--! Source operand A
		b : signed(31 downto 0);	--! Source operand B
		code  : std_logic_vector(3 downto 0);	--! Alu operation code
	end record M_data_t;
	
	constant M_MUL: std_logic_vector(3 downto 0) := "0000";
	constant M_MULH: std_logic_vector(3 downto 0) := "0001";
	constant M_MULHU: std_logic_vector(3 downto 0) := "0010";
	constant M_MULHSU: std_logic_vector(3 downto 0) := "0011";		
	constant M_DIV: std_logic_vector(3 downto 0) := "0100";
	constant M_DIVU: std_logic_vector(3 downto 0) := "0101";
	constant M_REM: std_logic_vector(3 downto 0) := "0110";
	constant M_REMU: std_logic_vector(3 downto 0) := "0111";

end package;

package body M_types is
	
end;
