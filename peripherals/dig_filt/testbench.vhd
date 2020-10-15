library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.decoder_types.all;

entity coretestbench is
	generic(
		--! Num of 32-bits memory words 
		IMEMORY_WORDS : integer := 1024;	--!= 4K (1024 * 4) bytes
		DMEMORY_WORDS : integer := 1024  	--!= 2k (512 * 2) bytes
	);

	port(
		----------- SEG7 ------------
		HEX0 : out std_logic_vector(7 downto 0);
		HEX1 : out std_logic_vector(7 downto 0);
		HEX2 : out std_logic_vector(7 downto 0);
		HEX3 : out std_logic_vector(7 downto 0);
		HEX4 : out std_logic_vector(7 downto 0);
		HEX5 : out std_logic_vector(7 downto 0);
		----------- SW ------------

		SW: in std_logic_vector(9 downto 0);		
		LEDR: out std_logic_vector(9 downto 0);
		
		---------- ARDUINO IO -----
		ARDUINO_IO: inout std_logic_vector(15 downto 0)
	);	
	
	
end entity coretestbench;

architecture RTL of coretestbench is
	signal clk       : std_logic;
	signal rst       : std_logic;
	signal idata : std_logic_vector(31 downto 0);

	signal daddress : natural;
	signal ddata_r  : std_logic_vector(31 downto 0);
	signal ddata_w  : std_logic_vector(31 downto 0);
	signal dmask    : std_logic_vector(3 downto 0);
	signal dcsel    : std_logic_vector(1 downto 0);
	signal d_we     : std_logic := '0';

	signal iaddress : integer range 0 to IMEMORY_WORDS - 1 := 0;

	signal address     : std_logic_vector(9 downto 0);

	signal ddata_r_mem : std_logic_vector(31 downto 0);
	signal d_rd : std_logic;
			
	signal cpu_state    : cpu_state_t;	
	signal debugString  : string(1 to 40) := (others => '0');
	
	signal dmemory_address : natural;
	signal d_sig : std_logic;
	
	-- I/O signals
	signal ddata_r_gpio : std_logic_vector(31 downto 0);
	signal gpio_input : std_logic_vector(31 downto 0);
	signal gpio_output : std_logic_vector(31 downto 0);

	
	signal debug_leds	  : 	std_logic_vector(7 downto 0);
	signal debug_hex0	  : 	std_logic_vector(3 downto 0);
	signal debug_hex1	  : 	std_logic_vector(3 downto 0);
	signal debug_hex2	  : 	std_logic_vector(3 downto 0);
	signal debug_hex3	  : 	std_logic_vector(3 downto 0);
	signal debug_hex4	  : 	std_logic_vector(3 downto 0);
	signal debug_hex5	  : 	std_logic_vector(3 downto 0);

begin

	clock_driver : process
		constant period : time := 1000 ns;
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

	-- IMem shoud be read from instruction and data buses
	-- Not enough RAM ports for instruction bus, data bus and in-circuit programming
	-- with dcsel select 
	-- address <= std_logic_vector(to_unsigned(daddress,10)) when "01",
	--			   std_logic_vector(to_unsigned(iaddress,10)) when others;				   
	process(d_rd, dcsel, daddress, iaddress)
	begin
		if (d_rd = '1') and (dcsel = "00") then
			address <= std_logic_vector(to_unsigned(daddress, 10));
		else
			address <= std_logic_vector(to_unsigned(iaddress, 10));
		end if;
	end process;
--	instr_mux: entity work.instructionbusmux
--		generic map(
--			IMEMORY_WORDS => IMEMORY_WORDS,			
--			DMEMORY_WORDS => DMEMORY_WORDS
--		)
--		port map(
--			d_rd     => d_rd,
--			dcsel    => dcsel,
--			daddress => daddress,
--			iaddress => iaddress,
--			address  => address
--		);
	

	-- 32-bits x 1024 words quartus RAM (dual port: portA -> riscV, portB -> In-System Mem Editor
	iram_quartus_inst : entity work.iram_quartus
		port map(
			address => address(9 downto 0),
			byteena => "1111",
			clock   => clk,
			data    => (others => '0'),
			wren    => '0',
			q       => idata
		);

	dmemory_address <= to_integer(to_unsigned(daddress, 10));
	-- Data Memory RAM
	dmem : entity work.dmemory
		generic map(
			MEMORY_WORDS => DMEMORY_WORDS
		)
		port map(
			rst 	=> rst,
			clk 	=> clk,
			data 	=> ddata_w,
			address => dmemory_address,
			we 		=> d_we,
			csel 	=> dcsel(0),
			dmask 	=> dmask,
			signal_ext => d_sig,
			q 		=> ddata_r_mem
		);

	-- Adress space mux ((check sections.ld) -> Data chip select:
	-- 0x00000    ->    Instruction memory
	-- 0x20000    ->    Data memory
	-- 0x40000    ->    Input/Output generic address space
	-- ( ... )    ->    ( ... )
	datamux: entity work.databusmux
		port map(
			dcsel        => dcsel,
			idata        => idata,
			ddata_r_mem  => ddata_r_mem,
			ddata_r_gpio => ddata_r_gpio,
			ddata_r      => ddata_r
		);

	-- Softcore instatiation
	myRiscv : entity work.core
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
			d_sig	 => d_sig,
			dcsel    => dcsel,
			dmask    => dmask,
			state    => cpu_state
		);

	-- dig_filt instance
	dig_filt: entity work.dig_filt
		generic map(
			MY_CHIPSELECT => "10"
		)
		port map(			
			clk 		=> clk,
			rst 		=> rst,

			-- databus interface
			daddress 	=> daddress,
			ddata_r 	=> ddata_r_gpio,
			ddata_w 	=> ddata_w,
			d_we  => d_we,
			d_rd  => d_rd,
			dcsel => dcsel,
			dmask => dmask,

			-- Debug signals
			debug_leds => debug_leds,
			debug_hex0 => debug_hex0,
			debug_hex1 => debug_hex1,
			debug_hex2 => debug_hex2,
			debug_hex3 => debug_hex3,
			debug_hex4 => debug_hex4,
			debug_hex5 => debug_hex5
		);
	
	-- Connect input hardware to gpio data
	gpio_input <= (others => '0'), x"00000010" after 600000 ns;
	
	-- FileOutput DEBUG	
	debug : entity work.trace_debug
		generic map(
			MEMORY_WORDS => IMEMORY_WORDS
		)
		port map(
			pc   => iaddress,
			data => idata,
			inst => debugString
		);

end architecture RTL;
