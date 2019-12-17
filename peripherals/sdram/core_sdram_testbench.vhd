library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.decoder_types.all;

entity core_sdram_testbench is
	generic(
		--! Num of 32-bits memory words 
		IMEMORY_WORDS : integer := 1024;	--!= 4K (1024 * 4) bytes
		DMEMORY_WORDS : integer := 1024;  	--!= 2k (512 * 2) bytes
		constant SIZE : integer := 8		-- 8 bytes UART package
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
	
	
end entity core_sdram_testbench;

architecture RTL of core_sdram_testbench is
	signal clk       : std_logic;
	signal clk_sdram : std_logic;
	signal clk_vga   : std_logic;
	signal rst       : std_logic;
	signal rst_n     : std_logic;

	signal idata : std_logic_vector(31 downto 0);

	signal daddress : natural;
	signal ddata_r  : std_logic_vector(31 downto 0);
	signal ddata_w  : std_logic_vector(31 downto 0);
	signal dmask    : std_logic_vector(3 downto 0);
	signal dcsel    : std_logic_vector(1 downto 0);
	signal d_we     : std_logic := '0';

	signal iaddress : integer range 0 to IMEMORY_WORDS - 1 := 0;

	signal address     : std_logic_vector(31 downto 0);

	signal ddata_r_mem : std_logic_vector(31 downto 0);
	signal d_rd : std_logic;
		
	signal input_in	: std_logic_vector(31 downto 0);
	signal cpu_state    : cpu_state_t;
	
	signal debugString  : string(1 to 40) := (others => '0');
	

	-- UART Signals
	signal clk_baud : std_logic;
	signal data_in : std_logic_vector(7 downto 0);
	signal tx : std_logic;
	signal start : std_logic;
	signal tx_cmp : std_logic;
	signal data_out : std_logic_vector(SIZE-1 downto 0);
	signal rx : std_logic;
	signal rx_cmp : std_logic;
	
	signal csel_uart : std_logic;

	signal dmemory_address : natural;

	-- SDRAM Signals
	signal DRAM_ADDR         : std_logic_vector(12 downto 0);
	signal DRAM_BA           : std_logic_vector(1 downto 0);
	signal DRAM_CAS_N        : std_logic;
	signal DRAM_CKE          : std_logic;
	signal DRAM_CLK          : std_logic;
	signal DRAM_CS_N         : std_logic;
	signal DRAM_DQ           : std_logic_vector(15 downto 0);
	signal DRAM_DQM          : std_logic_vector(1 downto 0);
	signal DRAM_RAS_N        : std_logic;
	signal DRAM_WE_N         : std_logic;
	signal daddress_to_sdram : std_logic_vector(31 downto 0);
	signal sdram_addr        : std_logic_vector(31 downto 0);
	signal chipselect_sdram  : std_logic;
	signal sdram_d_rd        : std_logic;
	signal waitrequest       : std_logic;
	signal sdram_read        : std_logic_vector(15 DOWNTO 0);
	signal sdram_read_16     : std_logic_vector(31 downto 0);
	signal burst             : std_logic;

	-- VGA Signals
	signal VGA_B    : std_logic_vector(3 downto 0);
	signal VGA_G    : std_logic_vector(3 downto 0);
	signal VGA_HS   : std_logic;
	signal VGA_R    : std_logic_vector(3 downto 0);
	signal VGA_VS   : std_logic;
	signal vga_addr : std_logic_vector(31 downto 0);
	signal disp_ena : std_logic;
	signal n_blank  : std_logic;
	signal n_sync   : std_logic;
	signal column   : integer;
	signal row      : integer;
	signal vga_data_read : std_logic;
	signal buffer_to_sdram_addr : std_logic_vector(31 downto 0);
	signal sel : std_logic;
	signal cs : std_logic;
	signal clk_sdram_ctrl : std_logic;

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

	
	-- Dummy out signals
	-- ARDUINO_IO <= ddata_r(31 downto 16);
	
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


	rst_n <= not rst;

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
			address <= std_logic_vector(to_unsigned(daddress, 32));
		else
			address <= std_logic_vector(to_unsigned(iaddress, 32));
		end if;
	end process;

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
			rst     => rst,
			clk     => clk,
			data    => ddata_w,
			address => dmemory_address,
			we      => d_we,
			csel    => dcsel(0),
			dmask   => dmask,
			q       => ddata_r_mem
		);

	-- Adress space mux ((check sections.ld) -> Data chip select:
	-- 0x00000    ->    Instruction memory
	-- 0x20000    ->    Data memory
	-- 0x40000    ->    Input/Output generic address space
	-- 0x60000    ->    SDRAM address space	
	with dcsel select ddata_r <=
		idata when "00",
		ddata_r_mem when "01",
		input_in when "10",
		(others => '0') when others;

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
			dcsel    => dcsel,
			dmask    => dmask,
			state    => cpu_state
		);

	-- Output register (Dummy LED blinky)
	process(clk, rst)
	begin
		if rst = '1' then
			LEDR(7 downto 0) <= (others => '0');			
			HEX0 <= (others => '1');
			HEX1 <= (others => '1');
			HEX2 <= (others => '1');
			HEX3 <= (others => '1');
			HEX4 <= (others => '1');
			HEX5 <= (others => '1');		
		else
			if rising_edge(clk) then
				if (d_we = '1') and (dcsel = "10") then
					-- ToDo: Simplify compartors
					-- ToDo: Maybe use byte addressing?  
					--       x"01" (word addressing) is x"04" (byte addressing)
					if to_unsigned(daddress, 32)(8 downto 0) = x"01" then										
						LEDR(7 downto 0) <= ddata_w(7 downto 0);				
					elsif to_unsigned(daddress, 32)(8 downto 0) = x"02" then
						HEX0 <= ddata_w(7 downto 0);
						HEX1 <= ddata_w(15 downto 8);
						HEX2 <= ddata_w(23 downto 16);
						HEX3 <= ddata_w(31 downto 24);
						-- HEX4 <= ddata_w(7 downto 0);
						-- HEX5 <= ddata_w(7 downto 0);
					end if;
				end if;
			end if;
		end if;
	end process;

	-- Input register
	process(clk, rst)
	begin
		if rst = '1' then
			input_in <= (others => '0');
		else

			if rising_edge(clk) then		
				if (d_rd = '1') and (dcsel = "10") then
					if to_unsigned(daddress, 32)(8 downto 0) = x"00" then		
						input_in(4 downto 0) <= SW(4 downto 0);	
					elsif to_unsigned(daddress, 32)(8 downto 0) = x"04" then								
						input_in(7 downto 0) <= data_out;
					end if;
				end if;
			end if;
		end if;	

	end process;

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
		
	
	sel <= '1';
	cs <= dcsel(1) and dcsel(0);
	
	-- CORE, VGA and SDRAM muxes
	with sel select sdram_addr <=
		daddress_to_sdram when '1',
		buffer_to_sdram_addr when others;

	with sel select sdram_d_rd <=
		d_rd when '1',
		vga_data_read when others;

	with sel select chipselect_sdram <=
		cs when '1',
		vga_data_read when others;
		
	with sel select burst <=
		'0' when '1',
		'1' when others;

	-- SDRAM instatiation
	sdram_controller : entity work.sdram_controller
		port map(
			address     => sdram_addr,
			byteenable  => "11",
			chipselect  => chipselect_sdram,
			clk         => clk_sdram_ctrl,
			clken       => '1',
			reset       => rst,
			reset_req   => rst,
			write       => d_we,
			read        => sdram_d_rd,
			writedata   => ddata_w,
			burst       => burst,
			-- outputs:
			readdata    => sdram_read,
			waitrequest => waitrequest,
			DRAM_ADDR   => DRAM_ADDR,
			DRAM_BA     => DRAM_BA,
			DRAM_CAS_N  => DRAM_CAS_N,
			DRAM_CKE    => DRAM_CKE,
			DRAM_CLK    => DRAM_CLK,
			DRAM_CS_N   => DRAM_CS_N,
			DRAM_DQ     => DRAM_DQ,
			DRAM_DQM    => DRAM_DQM,
			DRAM_RAS_N  => DRAM_RAS_N,
			DRAM_WE_N   => DRAM_WE_N
		);

	-- SDRAM Signals
	daddress_to_sdram <= std_logic_vector(to_unsigned(daddress, 32));

	-- SDRAM model instatiation
	sdram : entity work.mt48lc8m16a2
		generic map(
			addr_bits => 13
		)
		port map(
			Dq    => DRAM_DQ,
			Addr  => DRAM_ADDR,
			Ba    => DRAM_BA,
			Clk   => clk_sdram,
			Cke   => DRAM_CKE,
			Cs_n  => DRAM_CS_N,
			Ras_n => DRAM_RAS_N,
			Cas_n => DRAM_CAS_N,
			We_n  => DRAM_WE_N,
			Dqm   => DRAM_DQM
		);

	clk_sdram_ctrl_driver : process
		constant period : time := 10 ns;
	begin
		clk_sdram_ctrl <= '0';
		wait for period / 2;
		clk_sdram_ctrl <= '1';
		wait for period / 2;
	end process clk_sdram_ctrl_driver;

	clk_sdram_driver : process
	begin
		clk_sdram <= '0';
         wait for 4000 ps;
         clk_sdram <= '1';
         wait for 5000 ps;
         clk_sdram <= '0';
         wait for 1000 ps;
	end process clk_sdram_driver;

	

end architecture RTL;