LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY tristate IS
PORT (
	mybidir 		: INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	myinput 		: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	myenable 	: IN STD_LOGIC
);
END tristate;

ARCHITECTURE rtl OF tristate IS
BEGIN
	mybidir <= (mybidir'range => 'Z' ) WHEN (myenable = '0') ELSE myinput;
END rtl;
