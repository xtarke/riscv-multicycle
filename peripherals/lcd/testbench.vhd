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
		HEX0       : out   std_logic_vector(7 downto 0);
		HEX1       : out   std_logic_vector(7 downto 0);
		HEX2       : out   std_logic_vector(7 downto 0);
		HEX3       : out   std_logic_vector(7 downto 0);
		HEX4       : out   std_logic_vector(7 downto 0);
		HEX5       : out   std_logic_vector(7 downto 0);
		----------- SW ------------

		SW         : in    std_logic_vector(9 downto 0);
		LEDR       : out   std_logic_vector(9 downto 0);
		---------- ARDUINO IO -----
		ARDUINO_IO : inout std_logic_vector(15 downto 0)
	);
end entity coretestbench;

architecture RTL of coretestbench is
	signal clk : std_logic;
	signal rst : std_logic := '1';
	signal n_rst : std_logic := '0';

	-- Instruction bus signals
	signal idata     : std_logic_vector(31 downto 0);
	signal iaddress  : integer range 0 to IMEMORY_WORDS-1 := 0;
	signal address   : std_logic_vector (9 downto 0);
	
	-- Data bus signals
	signal daddress :  integer range 0 to DMEMORY_WORDS-1;
	signal ddata_r	:  	std_logic_vector(31 downto 0);
	signal ddata_w  :	std_logic_vector(31 downto 0);
	signal dmask    : std_logic_vector(3 downto 0);
	signal dcsel    : std_logic_vector(1 downto 0);
	signal d_we     : std_logic := '0';
	
	signal ddata_r_mem : std_logic_vector(31 downto 0);
	signal d_rd : std_logic;			
	
	-- I/O signals
	signal ddata_r_gpio : std_logic_vector(31 downto 0);
	
	-- PLL signals
	signal locked_sig : std_logic;
	
	-- CPU state signals
	signal state : cpu_state_t;
	signal d_sig : std_logic;
	
	signal char    : std_logic_vector(7 downto 0);
	
	signal debugString : string(1 to 40) := (others => '0');
	
begin

	process
	begin
		wait for 2 us;
		rst <= '0';
	end process;

    process
    begin
		clk <= '0';
        wait for 5 us;
        clk <= '1';
        wait for 5 us;           
    end process;

	n_rst <= NOT rst;
	LEDR(9) <= rst;

	-- IMem shoud be read from instruction and data buses
	-- Not enough RAM ports for instruction bus, data bus and in-circuit programming
	instr_mux: entity work.instructionbusmux
		generic map(
			IMEMORY_WORDS => IMEMORY_WORDS,			
			DMEMORY_WORDS => DMEMORY_WORDS
		)
		port map(
			d_rd     => d_rd,
			dcsel    => dcsel,
			daddress => daddress,
			iaddress => iaddress,
			address  => address
		);
	
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

	process(d_rd, dcsel, daddress, iaddress)
	begin
		if (d_rd = '1') and (dcsel = "00") then
			address <= std_logic_vector(to_unsigned(daddress, 32));
		else
			address <= std_logic_vector(to_unsigned(iaddress, 32));
		end if;
	end process;
	
	-- Data Memory RAM
	dmem: entity work.dmemory
		generic map(
			MEMORY_WORDS => DMEMORY_WORDS
		)
		port map(
			rst => rst,
			clk => clk,
			data => ddata_w,
			address => daddress,
			we => d_we,
			csel => dcsel(0),
			dmask => dmask,
			signal_ext => d_sig,
			q => ddata_r_mem
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
	myRisc: entity work.core
		generic map(
			IMEMORY_WORDS => IMEMORY_WORDS,
			DMEMORY_WORDS => DMEMORY_WORDS
		)
		port map(			
			clk 		=> clk,
			rst 		=> rst,
			iaddress 	=> iaddress,
			idata 		=> idata,
			daddress 	=> daddress,
			ddata_r 	=> ddata_r,
			ddata_w 	=> ddata_w,
			d_we  => d_we,
			d_rd  => d_rd,
			d_sig => d_sig,
			dcsel => dcsel,
			dmask => dmask,
			state => state
		);
	
	process(clk, rst)
	begin		
		if rst = '1' then
			char(7 downto 0) <= (others => '0');
			LEDR(7 downto 0) <= (others => '1');			
		else
			if rising_edge(clk) then		
				if (d_we = '1') and (dcsel = "10")then					
					-- ToDo: Simplify compartors
					-- ToDo: Maybe use byte addressing?  
					--       x"01" (word addressing) is x"04" (byte addressing)
					if to_unsigned(daddress, 32)(8 downto 0) = x"01" then -- LEDS					
						char(7 downto 0) <= ddata_w(7 downto 0);
						LEDR(7 downto 0) <= ddata_w(7 downto 0);
					end if;				
				end if;
			end if;
		end if;		
	end process;
	
	lcd : entity work.lcd	
		port map(
            clk => clk,
            reset => n_rst,
            char => char,
            rst => ARDUINO_IO(0),
            ce => ARDUINO_IO(1),
            dc => ARDUINO_IO(2),
            din => ARDUINO_IO(3),
            serial_clk => ARDUINO_IO(4),
            light => ARDUINO_IO(5)
		);
			
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
