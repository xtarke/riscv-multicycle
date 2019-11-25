-------------------------------------------------------------------
-- Name        : 
-- Author      : 
-- Version     : 
-- Copyright   : 
-- Description : 
-------------------------------------------------------------------

-- Bibliotecas e clásulas
LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Entidade e portas
entity mux32 IS
	PORT ( a,b: IN	unsigned (31 downto 0);
		   sel: IN 	std_logic;
		     S: OUT	unsigned (31 downto 0)
		  );
end entity;

-- Arquitetura e
architecture rtl of mux32 IS
begin

	S <= a when sel ='0' else b;
	
end architecture;