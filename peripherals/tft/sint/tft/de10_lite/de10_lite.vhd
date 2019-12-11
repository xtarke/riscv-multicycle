-------------------------------------------------------------------
-- Name        : de0_lite.vhd
-- Author      : 
-- Version     : 0.1
-- Copyright   : Departamento de Eletrônica, Florianópolis, IFSC
-- Description : Projeto base DE10-Lite
-------------------------------------------------------------------
LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity de10_lite is 
	port (
		---------- CLOCK ----------
		ADC_CLK_10:	in std_logic;
		MAX10_CLK1_50: in std_logic;
		MAX10_CLK2_50: in std_logic;
		
		----------- SDRAM ------------
		DRAM_ADDR: out std_logic_vector (12 downto 0);
		DRAM_BA: out std_logic_vector (1 downto 0);
		DRAM_CAS_N: out std_logic;
		DRAM_CKE: out std_logic;
		DRAM_CLK: out std_logic;
		DRAM_CS_N: out std_logic;		
		DRAM_DQ: inout std_logic_vector(15 downto 0);
		DRAM_LDQM: out std_logic;
		DRAM_RAS_N: out std_logic;
		DRAM_UDQM: out std_logic;
		DRAM_WE_N: out std_logic;
		
		----------- SEG7 ------------
		HEX0: out std_logic_vector(7 downto 0);
		HEX1: out std_logic_vector(7 downto 0);
		HEX2: out std_logic_vector(7 downto 0);
		HEX3: out std_logic_vector(7 downto 0);
		HEX4: out std_logic_vector(7 downto 0);
		HEX5: out std_logic_vector(7 downto 0);

		----------- KEY ------------
		KEY: in std_logic_vector(1 downto 0);

		----------- LED ------------
		LEDR: out std_logic_vector(9 downto 0);

		----------- SW ------------
		SW: in std_logic_vector(9 downto 0);

		----------- VGA ------------
		VGA_B: out std_logic_vector(3 downto 0);
		VGA_G: out std_logic_vector(3 downto 0);
		VGA_HS: out std_logic;
		VGA_R: out std_logic_vector(3 downto 0);
		VGA_VS: out std_logic;
	
		----------- Accelerometer ------------
		GSENSOR_CS_N: out std_logic;
		GSENSOR_INT: in std_logic_vector(2 downto 1);
		GSENSOR_SCLK: out std_logic;
		GSENSOR_SDI: inout std_logic;
		GSENSOR_SDO: inout std_logic;
	
		----------- Arduino ------------
		ARDUINO_IO: inout std_logic_vector(15 downto 0);
		ARDUINO_RESET_N: inout std_logic;
		
		GPIO: inout std_logic_vector(35 downto 0)
	);
	
	signal clock_100KHz : std_logic;
	signal clock_1KHz : std_logic;
	
	signal output 	: unsigned(7 downto 0);
	signal cs     	: std_logic;
	signal rs     	: std_logic;
	signal wr     	: std_logic;
	signal rst     	: std_logic;
	
	signal input_a 	: unsigned(31 downto 0);
	signal input_b 	: unsigned(31 downto 0);
	signal input_c 	: unsigned(31 downto 0);
	
end entity;


architecture rtl of de10_lite is
begin

 tft_controller_inst : entity work.tft
 	port map(
 		clk     => clock_100KHz,
 		input_a => input_a,
 		input_b => input_b,
 		input_c => input_c,
 		output  => output,
 		cs      => cs,
 		rs      => rs,
 		wr      => wr,
 		rst     => rst
 	);
	
	LEDR(7 downto 0) <= std_logic_vector(input_a(7 downto 0));
	entradas : process (clock_1KHz) is
		variable count : natural := 0;
		
	begin
		if rising_edge(clock_1KHz) then
			count := count + 1;
			
			if (count = 100) then
				count := 0;
				input_a(31) <='0';
				if (SW(9) = '1') then
					input_a(31 downto 0) <= x"FFFF0FF0";
				elsif (SW(8) = '1') then
					input_a(31 downto 0) <= x"8001F800";
				elsif (SW(7) = '1') then
					input_a(31 downto 0) <= x"8002FFC0";
				elsif (SW(6) = '1') then
					input_a(31 downto 0) <= x"8001001F";
				end if;
			end if;
		end if;
	end process;
	
 	input_b <= x"00000000";
	input_c <= x"00100010";
 
 PLL_100KHz_inst : entity work.PLL_100KHz
 	port map(
 		inclk0 => ADC_CLK_10,
 		c0     => clock_100KHz,
 		c1     => clock_1KHz
 	);
 
	ARDUINO_IO(8) <= std_logic(output(0));
	ARDUINO_IO(9) <= std_logic(output(1));
	ARDUINO_IO(2) <= std_logic(output(2));
	ARDUINO_IO(3) <= std_logic(output(3));
	ARDUINO_IO(4) <= std_logic(output(4));
	ARDUINO_IO(5) <= std_logic(output(5));
	ARDUINO_IO(6) <= std_logic(output(6));
	ARDUINO_IO(7) <= std_logic(output(7)); 
	
	GPIO(35) <= cs;
	GPIO(34) <= rs;
	GPIO(33) <= wr;
	
	GPIO(32) <= SW(0);
	GPIO(31) <= '1';
	GPIO(30) <= rst;
end;

