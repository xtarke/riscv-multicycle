---------------------------------------------------------------------
-- Name        : testbench2.vhd
-- Author      : Suzi Yousif
-- Description : A simple testbench for Ultrassonic Sensor HC-SR04.
--				 This test was made to check the state machine and
--				 the variable 'measure_ms'.
--				 To simulate, use testbench2.do file.
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end entity testbench;

architecture RTL of testbench is
	signal clk       : std_logic;
	signal rst       : std_logic;
	signal daddress : natural;
	signal ddata_r  : std_logic_vector(31 downto 0);
	signal ddata_w  : std_logic_vector(31 downto 0);
	signal dmask    : std_logic_vector(3 downto 0);
	signal dcsel    : std_logic_vector(1 downto 0);
	signal d_we     : std_logic := '0';
	signal d_rd : std_logic;
			
	-- I/O signals
	signal echo : std_logic;
	signal Trig : std_logic;
begin

	HCSR04_inst : entity work.HCSR04
		generic map(
			MY_CHIPSELECT   => "10",
			MY_WORD_ADDRESS => x"10"
		)
		port map(
			clk      => clk,
			rst      => rst,
			daddress => daddress,
			ddata_w  => ddata_w,
			ddata_r  => ddata_r,
			d_we     => d_we,
			d_rd     => d_rd,
			dcsel    => dcsel,
			dmask    => dmask,
			echo     => echo,
			Trig     => Trig
		);

	clock_driver : process
		constant period : time := 10000 ns;
	begin
		clk <= '0';
		wait for period / 2;
		clk <= '1';
		wait for period / 2;
	end process clock_driver;

	reset : process is
	begin
		rst <= '1';
		wait for 10000 ns;
		rst <= '0';
		wait;
	end process reset;
	
	echo <= '0', '1' after 800000 ns, '0' after 850000 ns;
	
end architecture RTL;
