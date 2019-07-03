LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY hw_image_generator IS
	PORT(
		disp_ena : IN  STD_LOGIC;       --display enable ('1' = display time, '0' = blanking time)
		rgb_in   : in  std_logic_vector(15 downto 0); -- RAM data in
		red      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0'); --red magnitude output to R2R
		green    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0'); --green magnitude output to R2R
		blue     : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0')); --blue magnitude output to R2R
END hw_image_generator;

ARCHITECTURE behavior OF hw_image_generator IS
BEGIN
	PROCESS(disp_ena, rgb_in)
	BEGIN
		IF (disp_ena = '1') THEN        --display time
			red   <= rgb_in(3 downto 0);
			green <= rgb_in(7 downto 4);
			blue  <= rgb_in(11 downto 8);
		ELSE                            --blanking time
			red   <= (OTHERS => '0');
			green <= (OTHERS => '0');
			blue  <= (OTHERS => '0');
		END IF;

	END PROCESS;
END behavior;
