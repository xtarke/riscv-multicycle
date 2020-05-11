-------------------------------------------------------
--! @file
--! @brief RISCV Simple instruction bux mux.
--         IMem shoud be read from instruction and data buses         
--
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instructionbusmux is
	generic (
		--! Num of 32-bits memory words 
		IMEMORY_WORDS : integer := 1024;	--!= 4K (1024 * 4) bytes
		DMEMORY_WORDS : integer := 1024  	--!= 2k (512 * 2) bytes
	); 
	
	port(
		d_rd  : in std_logic;
		dcsel : in std_logic_vector(1 downto 0);
		
		daddress : in integer range 0 to DMEMORY_WORDS-1;
		iaddress : in integer range 0 to IMEMORY_WORDS-1;
		
		address  : out std_logic_vector (9 downto 0)
	);
end entity instructionbusmux;

architecture RTL of instructionbusmux is
	
begin	
	-- IMem shoud be read from instruction and data buses
	-- Not enough RAM ports for instruction bus, data bus and in-circuit programming
	
	process(d_rd, dcsel, daddress, iaddress)
	begin
		if (d_rd = '1') and (dcsel = "00") then
			address <= std_logic_vector(to_unsigned(daddress,10));
		else
			address <= std_logic_vector(to_unsigned(iaddress,10));
		end if;		
	end process;

end architecture RTL;
