library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.M_types.all;

entity M is
	port(
		M_data : in M_data_t;		
		dataOut  : out std_logic_vector(31 downto 0)
	);
end entity;

architecture RTL of M is
	-------------------------------------------------------------------	


	signal mul_signed: Signed(63 downto 0);
	signal mulu_unsigned: Unsigned(63 downto 0);
	
	signal div_signed: Signed(31 downto 0);
	signal divu_unsigned: Unsigned(31 downto 0);
	
	signal rem_signed: Signed(31 downto 0);
	signal remu_unsigned: Unsigned(31 downto 0);

begin
	--===============================================================--

	mul_signed <= M_data.a*M_data.b;
	mulu_unsigned <= Unsigned(M_data.a)*Unsigned(M_data.b);

	div_signed <= M_data.a/M_data.b;
	divu_unsigned <= Unsigned(M_data.a)/Unsigned(M_data.b);
	
	rem_signed <= M_data.a mod M_data.b;  
	remu_unsigned <= Unsigned(M_data.a) mod Unsigned(M_data.b);

	ula_op : with M_data.code select
		dataOut <=	Std_logic_vector(mul_signed(31 downto 0)) when M_MUL,
					Std_logic_vector(mul_signed(63 downto 32)) when M_MULH,

					Std_logic_vector(mulu_unsigned(63 downto 32)) when M_MULHU,
					Std_logic_vector(mulu_unsigned(63 downto 32)) when M_MULHSU,

					Std_logic_vector(div_signed) when M_DIV,
					Std_logic_vector(divu_unsigned) when M_DIVU,

					Std_logic_vector(rem_signed) when M_REM,
					Std_logic_vector(remu_unsigned) when M_REMU,

			        (others => '0') when others;

end architecture;