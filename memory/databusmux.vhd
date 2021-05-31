-------------------------------------------------------
--! @file
--! @brief RISCV Simple data bux mux.
--         Multiplex ddata_r accordingly to address space
--
-- Adress space mux ((check sections.ld) -> Data chip select:
    -- 0x00000    ->    Instruction memory
    -- 0x20000    ->    Data memory
    -- 0x40000    ->    Input/Output generic address space  
    -- 0x60000    ->    SDRAM   
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity databusmux is
	port(
		dcsel 		: in std_logic_vector(1 downto 0);        --! Chip select
		
		idata 		: in 	std_logic_vector(31 downto 0);    --! Data from instruction memory
		ddata_r_mem : in std_logic_vector(31 downto 0);       --! Data from data memory
		ddata_r_periph: in std_logic_vector(31 downto 0);     --! Data from generic i/o
		ddata_r_sdram: in std_logic_vector(31 downto 0);      --! Data from external SDRAM chip
		
		-- Mux 
		ddata_r		: out 	std_logic_vector(31 downto 0)     --! Connect to RISC-V data bus 
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
