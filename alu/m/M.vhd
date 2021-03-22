------------------------------------------------------------------------
--! @file
--! @brief RISCV "M" Standard Extension for Multiplication and Division
------------------------------------------------------------------------

--! Use standard library
library ieee;
--! Use aritimetic operations
use ieee.numeric_std.all;
--! Use logic elements
use ieee.std_logic_1164.all;

--! Ula define codes
use work.M_types.all;

entity M is
	port(
		clk 		:	in 	std_logic; --! Divider clock
		rst 		: in 	std_logic; --! Divider rest
		M_data 	: in 	M_data_t;  --! Dividend, divisor and operation
		dataOut : out std_logic_vector(31 downto 0) --! Operation result
	);
end entity;

architecture RTL of M is
	-------------------------------------------------------------------

	--! Signed x Signed Multiplication
	signal mul_signed: Signed(63 downto 0);
	--! Unsigned x Unsigned Multiplication
	signal mulu_unsigned: Unsigned(63 downto 0);

	--! Quotient of Signed division
	signal div_signed: Signed(31 downto 0);
	--! Quotient of Unsigned division
	signal divu_unsigned: Unsigned(31 downto 0);

	--! Remainder of Signed division
	signal rem_signed: Signed(31 downto 0);
	--! Remainder of Unsigned division
	signal remu_unsigned: Unsigned(31 downto 0);

	--! Signals used as inputs or outputs of the dividers,
	--! often the inputs and the outputs must be preprocessed (two's complement)
	--! before send to the divison block or return the results.
	signal remainder_sig 	 : Signed(31 downto 0);
	signal quotient_sig	 	 : Signed(31 downto 0);
	signal remainder_unsig : Unsigned(31 downto 0);
	signal quotient_unsig	 : Unsigned(31 downto 0);
	signal divid_signed		 : Unsigned(31 downto 0);
	signal divis_signed		 : Unsigned(31 downto 0);

begin
	--===============================================================--

	mul_signed <= M_data.a*M_data.b;
	mulu_unsigned <= Unsigned(M_data.a)*Unsigned(M_data.b);

	--quick_div_signed : entity work.quick_naive
	--port map (
	--	clk => clk, rst => rst,
	--	dividend => divid_signed, divisor => divis_signed, ready => open,
	--	Signed(remainder) => remainder_sig, Signed(quotient) => quotient_sig
	--);

	--quick_div_unsigned : entity work.quick_naive
	--port map (
	--	clk => clk, rst => rst,
	--	dividend => Unsigned(M_data.a), divisor => Unsigned(M_data.b), ready => open,
	--	remainder => remainder_unsig, quotient => quotient_unsig
	--);

	quick_clz_signed : entity work.quick_clz
	port map (
		clk => clk, rst => rst,
		dividend => divid_signed, divisor => divis_signed, ready => open,
		Signed(remainder) => remainder_sig, Signed(quotient) => quotient_sig
	);

	quick_clz_unsigned : entity work.quick_clz
	port map (
		clk => clk, rst => rst,
		dividend => Unsigned(M_data.a), divisor => Unsigned(M_data.b), ready => open,
		remainder => remainder_unsig, quotient => quotient_unsig
	);

	process(M_data, quotient_unsig, quotient_sig, remainder_sig, remainder_unsig)
	begin
		divid_signed <= Unsigned(M_data.a);
		divis_signed <= Unsigned(M_data.b);
		divu_unsigned <= quotient_unsig;
		remu_unsigned <= remainder_unsig;
		--! Conform to the riscv standard
		--! Division by zero
		if (M_data.b = x"00000000") then
			div_signed <= (others => '1');
			divu_unsigned <= (others => '1');
			rem_signed <= M_data.a;
			remu_unsigned <= Unsigned(M_data.a);
		--! Sub-overflow
		elsif ((M_data.a = x"80000000") and (M_data.b = x"FFFFFFFF")) then
			div_signed <= M_data.a;
			rem_signed <= (others => '0');
		else
			--! Correcting the signs of the inputs and the results
			if ((M_data.a(M_data.a'left) = '1') and (M_data.b(M_data.b'left) = '1')) then
				div_signed <= quotient_sig;
				rem_signed <= (not remainder_sig) + 1;
				divid_signed <= Unsigned((not M_data.a) + 1);
				divis_signed <= Unsigned((not M_data.b) + 1);
			elsif ((M_data.a(M_data.a'left) = '1') and (M_data.b(M_data.b'left) = '0')) then
				div_signed <= (not quotient_sig) + 1;
				rem_signed <= (not remainder_sig) + 1;
				divid_signed <= Unsigned((not M_data.a) + 1);
				divis_signed <= Unsigned(M_data.b);
			elsif ((M_data.a(M_data.a'left) = '0') and (M_data.b(M_data.b'left) = '1')) then
				div_signed <= (not quotient_sig) + 1;
				rem_signed <= remainder_sig;
				divid_signed <= Unsigned(M_data.a);
				divis_signed <= Unsigned((not M_data.b) + 1);
			else
				div_signed <= quotient_sig;
				rem_signed <= remainder_sig;
				divid_signed <= Unsigned(M_data.a);
				divis_signed <= Unsigned(M_data.b);
			end if;
		end if;
	end process;

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
