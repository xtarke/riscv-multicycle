-------------------------------------------------------
--! @file
--! @brief RISCV Simple data bux mux.
--         Multiplex ddata_r accordingly peripherals   
--
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity databusmux is
	port(
		dcsel 		: in std_logic_vector(1 downto 0);
		
		-- Adjust inputs accordingly peripherals 
		idata 		: in 	std_logic_vector(31 downto 0);
		ddata_r_mem : in std_logic_vector(31 downto 0);
		ddata_r_periph: in std_logic_vector(31 downto 0);
		ddata_r_sdram: in std_logic_vector(31 downto 0);
		
		
		-- Mux 
		ddata_r		: out 	std_logic_vector(31 downto 0)
	);
end entity databusmux;

architecture RTL of databusmux is
	
begin
	-- Adress space mux ((check sections.ld) -> Data chip select:
	-- 0x00000    ->    Instruction memory
	-- 0x20000    ->    Data memory
	-- 0x40000    ->    Input/Output generic address space	
	-- 0x60000    ->    SDRAM	
	
	with dcsel select 
		ddata_r <= idata when "00",
		           ddata_r_mem when "01",
		           ddata_r_periph when "10",
		           ddata_r_sdram when "11",
		           (others => '0') when others;

end architecture RTL;
