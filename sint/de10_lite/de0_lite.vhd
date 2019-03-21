-------------------------------------------------------------------
-- Name        : de0_lite.vhd
-- Author      : 
-- Version     : 0.1
-- Copyright   : Departamento de Eletrônica, Florianópolis, IFSC
-- Description : Projeto base DE10-Lite
-------------------------------------------------------------------
LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity de0_lite is 
	generic (
		--! Num of 32-bits memory words 
		IMEMORY_WORDS : integer := 1024;	--!= 4K (1024 * 4) bytes
		DMEMORY_WORDS : integer := 1024  	--!= 2k (512 * 2) bytes
	);


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
		RAM_WE_N: out std_logic;
		
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
		ARDUINO_RESET_N: inout std_logic
	);
end entity;



architecture rtl of de0_lite is
	
	component pll
	PORT
	(
		areset		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC 
	);
	end component;
	
	component imemory
	generic(MEMORY_WORDS : integer);
		port(
			clk : in std_logic;							--! Clock input
			data: in std_logic_vector (31 downto 0);	--! Write data input
			read_address_a: in integer range 0 to MEMORY_WORDS-1;	--! Address to be written
	    	read_address_b: in integer range 0 to MEMORY_WORDS-1;	--! Address to be read
	    	q_a:  out std_logic_vector (31 downto 0);		--! Read output
	    	csel : in std_logic;    	
	    	q_b:  out std_logic_vector (31 downto 0)		--! Read output
		);
	end component imemory;
	
	component iram_quartus
	port
	(
		address		: in std_logic_vector (9 downto 0);
		byteena		: in std_logic_vector (3 downto 0) :=  (others => '1');
		clock		: in std_logic  := '1';
		data		: in std_logic_vector (31 downto 0);
		wren		: in std_logic ;
		q		: out std_logic_vector (31 downto 0)
	);
	end component;
	
	    
    component dmemory
    	generic(MEMORY_WORDS : integer);
    	port(
    		rst : in std_logic;
    		clk     : in  std_logic;
    		data    : in  std_logic_vector(31 downto 0);
    		address : in  integer range 0 to MEMORY_WORDS - 1;
    		we      : in  std_logic;
    		csel : in std_logic;	
    		dmask   : in std_logic_vector(3 downto 0);
    		q       : out std_logic_vector(31 downto 0)
    	);
    end component dmemory;
	
	
	component core
		generic (
			--! Num of 32-bits memory words 
			IMEMORY_WORDS : integer := 256; 
			DMEMORY_WORDS : integer := 512
		);
		port(
			clk : in std_logic;
			rst : in std_logic;
			
			iaddress  : out  integer range 0 to IMEMORY_WORDS-1;
			idata	  : in 	std_logic_vector(31 downto 0);
			
			daddress  : out  integer range 0 to DMEMORY_WORDS-1;
			
			ddata_r	  : in 	std_logic_vector(31 downto 0);
			ddata_w   : out	std_logic_vector(31 downto 0);
			d_we      : out std_logic;
			d_rd 	  : out std_logic;
			dcsel	  : out std_logic_vector(1 downto 0);
			dmask     : out std_logic_vector(3 downto 0)	--! Byte enable mask 
		);
	end component core;

	component trace_debug
		generic(MEMORY_WORDS : integer);
		port(
			pc   : in integer range 0 to MEMORY_WORDS - 1;
			data : in std_logic_vector(31 downto 0)
		);
	end component trace_debug;
	
	signal clk : std_logic;
	signal rst : std_logic;
	
	signal idata          : std_logic_vector(31 downto 0);
	
	signal daddress :  integer range 0 to DMEMORY_WORDS-1;
	signal ddata_r	:  	std_logic_vector(31 downto 0);
	signal ddata_w  :	std_logic_vector(31 downto 0);
	signal dmask         : std_logic_vector(3 downto 0);
	signal dcsel : std_logic_vector(1 downto 0);
	signal d_we            : std_logic := '0';
	
	signal RAMaddress :  integer range 0 to 256 - 1;
	
	
	signal iaddress  : integer range 0 to IMEMORY_WORDS-1 := 0;

	signal q             : std_logic_vector(31 downto 0);
	signal address : std_logic_vector (9 downto 0);
	signal locked_sig : std_logic;
	signal d_rd : std_logic;
	signal ddata_r_mem : std_logic_vector(31 downto 0);
	signal input_out : std_logic_vector(31 downto 0);
	
begin

	pll_inst : pll PORT MAP (
		areset	 => SW(0),
		inclk0	 => MAX10_CLK1_50,
		c0	 		=> clk,
		locked	 => locked_sig
	);
	
	rst <= SW(0);
	
	-- IMem shoud be read from instruction and data buses
	-- Not enough RAM ports for instruction bus, data bus and in-circuit programming
	--with dcsel select 
	--	address <= std_logic_vector(to_unsigned(daddress,10)) when "01",
	--			   std_logic_vector(to_unsigned(iaddress,10)) when others;				   
	process(d_rd, dcsel, daddress, iaddress)
	begin
		if (d_rd = '1') and (dcsel = "00") then
			address <= std_logic_vector(to_unsigned(daddress,10));
		else
			address <= std_logic_vector(to_unsigned(iaddress,10));
		end if;		
	end process;

	iram_quartus_inst : iram_quartus PORT MAP (
			address	 => address,
			byteena	 => "1111",
			clock	 => clk,
			data	 => (others => '0'),
			wren	 => '0',
			q	 => idata
	);
	
	
	dmem: component dmemory
		generic map(
			MEMORY_WORDS => DMEMORY_WORDS
		)
		port map(
			rst => rst,
			clk     => clk,
			data    => ddata_w,
			address => daddress, --RAMaddress,
			csel	=> dcsel(0),
			we      => d_we,
			dmask   => dmask,
			q       => ddata_r_mem
		);

	with dcsel select 
		ddata_r <= idata when "00",
		           ddata_r_mem when "01",
		           input_out when "10",
		           (others => '0') when others;
	
	
	process(clk, rst)
	begin		
		if rst = '1' then
			LEDR(0) <= '0';
		else
			if rising_edge(clk) then		
				if (d_we = '1') and (dcsel = "10") then
					LEDR(0) <= 	ddata_w(0);				
				end if;
			end if;
		end if;		
	end process;
	
	
	DRAM_DQ <= ddata_r(15 downto 0);
	ARDUINO_IO <= ddata_r(31 downto 16);
	
	
	LEDR(9) <= SW(9);
	
	

	myRiscv: component core
		generic map(
			IMEMORY_WORDS => IMEMORY_WORDS,
			DMEMORY_WORDS => DMEMORY_WORDS
		)
		port map(
			clk      => clk,
			rst      => rst,
			iaddress => iaddress,
			idata    => idata,
			daddress => daddress,
			ddata_r  => ddata_r,
			ddata_w  => ddata_w,
			dcsel	 => dcsel,
			d_we     => d_we,
			d_rd 	 => d_rd,
			dmask    => dmask
		);
		
		
		

end;

