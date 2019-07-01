library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.decoder_types.all;

entity testbench is
	generic (
		--! Num of 32-bits memory words 
		IMEMORY_WORDS : integer := 1024;	--!= 4K (1024 * 4) bytes
		DMEMORY_WORDS : integer := 1024  	--!= 2k (512 * 2) bytes
	);
	
end entity testbench;

architecture RTL of testbench is
	signal clk : std_logic;
	signal rst : std_logic;
	
	signal idata          : std_logic_vector(31 downto 0);
	
	signal daddress :  integer range 0 to DMEMORY_WORDS-1;
	signal ddata_r	:  	std_logic_vector(31 downto 0);
	signal ddata_w  :	std_logic_vector(31 downto 0);
	signal dmask         : std_logic_vector(3 downto 0);
	signal dcsel : std_logic_vector(1 downto 0);
	signal d_we            : std_logic := '0';	
		
	signal iaddress  : integer range 0 to IMEMORY_WORDS-1 := 0;	
	
	signal address : std_logic_vector(9 downto 0);
	signal ddata_r_mem : std_logic_vector(31 downto 0);
	signal d_rd : std_logic;
		
	signal input_out	: std_logic_vector(31 downto 0);
	signal cpu_state    : cpu_state_t;
	--=======================================
	signal LEDR : std_logic_vector (8 downto 0); 
	--=======================================
begin
	
	clock_driver : process
		constant period : time := 10 ns;
	begin
		clk <= '0';
		wait for period / 2;
		clk <= '1';
		wait for period / 2;
	end process clock_driver;
	
	reset : process is
	begin
		rst <= '1';
		wait for 5 ns;
		rst <= '0';
		wait;
	end process reset;
	
--	imem: component imemory
--		generic map(
--			MEMORY_WORDS => IMEMORY_WORDS
--		)
--		port map(
--			clk           => clk,
--			data          => idata,
--			write_address => 0,
--			read_address  => iaddress,
--			we            => '0',
--			q             => idata 
--	);

	-- IMem shoud be read from instruction and data buses
	-- Not enough RAM ports for instruction bus, data bus and in-circuit programming
	-- with dcsel select 
	-- address <= std_logic_vector(to_unsigned(daddress,10)) when "01",
	--			   std_logic_vector(to_unsigned(iaddress,10)) when others;				   
	process(d_rd, dcsel, daddress, iaddress)
	begin
		if (d_rd = '1') and (dcsel = "00") then
			address <= std_logic_vector(to_unsigned(daddress,10));
		else
			address <= std_logic_vector(to_unsigned(iaddress,10));
		end if;		
	end process;

	
	-- 32-bits x 1024 words quartus RAM (dual port: portA -> riscV, portB -> In-System Mem Editor
	iram_quartus_inst: entity work.iram_quartus
		port map(
			address => address,
			byteena => "1111",
			clock   => clk,
			data    => (others => '0'),
			wren    => '0',
			q       => idata
		);
	

	-- Data Memory RAM
	dmem: entity work.dmemory
		generic map(
			MEMORY_WORDS => DMEMORY_WORDS
		)
		port map(
			rst     => rst,
			clk     => clk,
			data    => ddata_w,
			address => daddress,
			we      => d_we,
			csel    => dcsel(0),
			dmask   => dmask,
			q       => ddata_r_mem
		);
	
	-- Adress space mux ((check sections.ld) -> Data chip select:
	-- 0x00000    ->    Instruction memory
	-- 0x20000    ->    Data memory
	-- 0x40000    ->    Input/Output generic address space		
	with dcsel select 
		ddata_r <= idata when "00",
		           ddata_r_mem when "01",
		           input_out when "10",
		           (others => '0') when others;
				   
	--================================
	input_out <= (others => '1');
	
	--================================
	
	-- Softcore instatiation
	myRiscv: entity work.core
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
			d_we     => d_we,
			d_rd     => d_rd,
			dcsel    => dcsel,
			dmask    => dmask,
			state    => cpu_state
		);
	
	
	-- FileOutput DEBUG	
	debug: entity work.trace_debug
		generic map(
			MEMORY_WORDS => IMEMORY_WORDS
		)
		port map(
			pc   => iaddress,
			data => idata
		);
		
		
	
	--====================================================================
			-- Output register (Dummy LED blinky)
	process(clk, rst)
	begin		
		if rst = '1' then
			LEDR(8 downto 0) <= (others => '0');
		else
			if rising_edge(clk) then		
				if (d_we = '1') and (dcsel = "10") then
					LEDR(8 downto 0) <= ddata_w(8 downto 0);
						
				end if;
			end if;
		end if;		
	end process;
	--====================================================================

end architecture RTL;
