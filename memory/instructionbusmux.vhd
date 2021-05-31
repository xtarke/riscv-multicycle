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
		 --! Num of 2^2 32-bits memory words
        IADDRESS_BUS_SIZE : integer := 16;
        DADDRESS_BUS_SIZE : integer := 32
	); 
	
	port(
		d_rd  : in std_logic;
		dcsel : in std_logic_vector(1 downto 0);
		
		daddress  : in  unsigned(DADDRESS_BUS_SIZE-1 downto 0);    --! Data address
		iaddress  : in unsigned(IADDRESS_BUS_SIZE-1 downto 0); --! Instruction address
		
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
			address <= std_logic_vector(daddress(9 downto 0));
		else
			address <= std_logic_vector(iaddress(9 downto 0));
		end if;		
	end process;

end architecture RTL;
