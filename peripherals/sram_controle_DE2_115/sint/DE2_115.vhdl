library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

use work.decoder_types.all;

entity DE2_115 is
	generic(
		--! Num of 32-bits memory words 
		IMEMORY_WORDS : integer := 1024; --!= 4K (1024 * 4) bytes
		DMEMORY_WORDS : integer := 1024 --!= 2k (512 * 2) bytes
	);
	port(
		CLOCK_50      : in    std_logic;
		CLOCK2_50     : in    std_logic;
		CLOCK3_50     : in    std_logic;
		SMA_CLKIN     : in    std_logic;
		SMA_CLKOUT    : out   std_logic;
		LEDG          : out   std_logic_vector(8 downto 0);
		LEDR          : out   std_logic_vector(17 downto 0);
		KEY           : in    std_logic_vector(3 downto 0);
		EX_IO         : inout std_logic_vector(6 downto 0);
		SW            : in    std_logic_vector(17 downto 0);
		HEX0          : out   std_logic_vector(6 downto 0);
		HEX1          : out   std_logic_vector(6 downto 0);
		HEX2          : out   std_logic_vector(6 downto 0);
		HEX3          : out   std_logic_vector(6 downto 0);
		HEX4          : out   std_logic_vector(6 downto 0);
		HEX5          : out   std_logic_vector(6 downto 0);
		HEX6          : out   std_logic_vector(6 downto 0);
		HEX7          : out   std_logic_vector(6 downto 0);
		LCD_BLON      : out   std_logic;
		LCD_DATA      : inout std_logic_vector(7 downto 0);
		LCD_EN        : out   std_logic;
		LCD_ON        : out   std_logic;
		LCD_RS        : out   std_logic;
		LCD_RW        : out   std_logic;
		UART_CTS      : in    std_logic;
		UART_RTS      : out   std_logic;
		UART_RXD      : in    std_logic;
		UART_TXD      : out   std_logic;
		PS2_CLK       : inout std_logic;
		PS2_CLK2      : inout std_logic;
		PS2_DAT       : inout std_logic;
		PS2_DAT2      : inout std_logic;
		SD_CLK        : out   std_logic;
		SD_CMD        : inout std_logic;
		SD_DAT        : inout std_logic_vector(3 downto 0);
		SD_WP_N       : in    std_logic;
		VGA_B         : out   std_logic_vector(7 downto 0);
		VGA_BLANK_N   : out   std_logic;
		VGA_CLK       : out   std_logic;
		VGA_G         : out   std_logic_vector(7 downto 0);
		VGA_HS        : out   std_logic;
		VGA_R         : out   std_logic_vector(7 downto 0);
		VGA_SYNC_N    : out   std_logic;
		VGA_VS        : out   std_logic;
		AUD_ADCDAT    : in    std_logic;
		AUD_ADCLRCK   : inout std_logic;
		AUD_BCLK      : inout std_logic;
		AUD_DACDAT    : out   std_logic;
		AUD_DACLRCK   : inout std_logic;
		AUD_XCK       : out   std_logic;
		EEP_I2C_SCLK  : out   std_logic;
		EEP_I2C_SDAT  : inout std_logic;
		I2C_SCLK      : out   std_logic;
		I2C_SDAT      : inout std_logic;
		ENET0_GTX_CLK : out   std_logic;
		ENET0_INT_N   : in    std_logic;
		ENET0_LINK100 : in    std_logic;
		ENET0_MDC     : out   std_logic;
		ENET0_MDIO    : inout std_logic;
		ENET0_RST_N   : out   std_logic;
		ENET0_RX_CLK  : in    std_logic;
		ENET0_RX_COL  : in    std_logic;
		ENET0_RX_CRS  : in    std_logic;
		ENET0_RX_DATA : in    std_logic_vector(3 downto 0);
		ENET0_RX_DV   : in    std_logic;
		ENET0_RX_ER   : in    std_logic;
		ENET0_TX_CLK  : in    std_logic;
		ENET0_TX_DATA : out   std_logic_vector(3 downto 0);
		ENET0_TX_EN   : out   std_logic;
		ENET0_TX_ER   : out   std_logic;
		ENETCLK_25    : in    std_logic;
		ENET1_GTX_CLK : out   std_logic;
		ENET1_INT_N   : in    std_logic;
		ENET1_LINK100 : in    std_logic;
		ENET1_MDC     : out   std_logic;
		ENET1_MDIO    : inout std_logic;
		ENET1_RST_N   : out   std_logic;
		ENET1_RX_CLK  : in    std_logic;
		ENET1_RX_COL  : in    std_logic;
		ENET1_RX_CRS  : in    std_logic;
		ENET1_RX_DATA : in    std_logic_vector(3 downto 0);
		ENET1_RX_DV   : in    std_logic;
		ENET1_RX_ER   : in    std_logic;
		ENET1_TX_CLK  : in    std_logic;
		ENET1_TX_DATA : out   std_logic_vector(3 downto 0);
		ENET1_TX_EN   : out   std_logic;
		ENET1_TX_ER   : out   std_logic;
		TD_CLK27      : in    std_logic;
		TD_DATA       : in    std_logic_vector(7 downto 0);
		TD_HS         : in    std_logic;
		TD_RESET_N    : out   std_logic;
		TD_VS         : in    std_logic;
		OTG_ADDR      : out   std_logic_vector(1 downto 0);
		OTG_CS_N      : out   std_logic;
		OTG_DATA      : inout std_logic_vector(15 downto 0);
		OTG_INT       : in    std_logic;
		OTG_RD_N      : out   std_logic;
		OTG_RST_N     : out   std_logic;
		OTG_WE_N      : out   std_logic;
		IRDA_RXD      : in    std_logic;
		DRAM_ADDR     : out   std_logic_vector(12 downto 0);
		DRAM_BA       : out   std_logic_vector(1 downto 0);
		DRAM_CAS_N    : out   std_logic;
		DRAM_CKE      : out   std_logic;
		DRAM_CLK      : out   std_logic;
		DRAM_CS_N     : out   std_logic;
		DRAM_DQ       : inout std_logic_vector(31 downto 0);
		DRAM_DQM      : out   std_logic_vector(3 downto 0);
		DRAM_RAS_N    : out   std_logic;
		DRAM_WE_N     : out   std_logic;
		SRAM_ADDR     : out   std_logic_vector(19 downto 0);
		SRAM_CE_N     : out   std_logic;
		SRAM_DQ       : inout std_logic_vector(15 downto 0);
		SRAM_LB_N     : out   std_logic;
		SRAM_OE_N     : out   std_logic;
		SRAM_UB_N     : out   std_logic;
		SRAM_WE_N     : out   std_logic;
		FL_ADDR       : out   std_logic_vector(22 downto 0);
		FL_CE_N       : out   std_logic;
		FL_DQ         : inout std_logic_vector(7 downto 0);
		FL_OE_N       : out   std_logic;
		FL_RST_N      : out   std_logic;
		FL_RY         : in    std_logic;
		FL_WE_N       : out   std_logic;
		FL_WP_N       : out   std_logic
	);
end entity;

architecture rtl of DE2_115 is

	signal clk : std_logic;
	signal rst : std_logic;

	-- Instruction bus signals
	signal idata    : std_logic_vector(31 downto 0);
	signal iaddress : integer range 0 to IMEMORY_WORDS - 1 := 0;
	signal address  : std_logic_vector(9 downto 0);

	-- Data bus signals
	signal daddress : integer range 0 to DMEMORY_WORDS - 1;
	signal ddata_r  : std_logic_vector(31 downto 0);
	signal ddata_w  : std_logic_vector(31 downto 0);
	signal dmask    : std_logic_vector(3 downto 0);
	signal dcsel    : std_logic_vector(1 downto 0);
	signal d_we     : std_logic := '0';

	signal ddata_r_mem : std_logic_vector(31 downto 0);
	signal d_sig       : std_logic;
	signal d_rd        : std_logic;

	-- I/O signals
	signal input_in : std_logic_vector(31 downto 0);

	-- PLL signals
	signal locked_sig : std_logic;

	-- CPU state signals
	signal state         : cpu_state_t;
	signal chipselect    : STD_LOGIC;
	signal write         : STD_LOGIC;
	signal read_address  : unsigned(15 downto 0);
	signal write_address : unsigned(15 downto 0);
	signal q             : STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal addressram    : std_logic_vector(19 downto 0);
	signal data_out      : STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal data_in       : STD_LOGIC_VECTOR(15 DOWNTO 0);

	signal clk_ram : std_logic;

	signal data_out_SRAM : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal data_in_SRAM  : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal teste         : std_logic;

begin

	pll_inst : entity work.pll
		port map(
			areset => '0',
			inclk0 => CLOCK_50,
			c0     => clk,
			locked => locked_sig
		);

	rst <= SW(9);

	-- Dummy out signals
	DRAM_DQ               <= ddata_r(31 downto 0);
	--DRAM_DQ <= ddata_r(31 downto 16);
	--LEDR(9) <= SW(9);
	DRAM_ADDR(9 downto 0) <= address;

	-- IMem shoud be read from instruction and data buses
	-- Not enough RAM ports for instruction bus, data bus and in-circuit programming
	process(d_rd, dcsel, daddress, iaddress)
	begin
		if (d_rd = '1') and (dcsel = "00") then
			address <= std_logic_vector(to_unsigned(daddress, 10));
		else
			address <= std_logic_vector(to_unsigned(iaddress, 10));
		end if;
	end process;
	------------------------------------
	addressram <= std_logic_vector(to_unsigned(daddress, 32)(19 downto 0));

	sram : entity work.sram
		port map(
			SRAM_OE_N  => SRAM_OE_N,
			SRAM_WE_N  => SRAM_WE_N,
			SRAM_CE_N  => SRAM_CE_N,
			SRAM_ADDR  => SRAM_ADDR,
			SRAM_DQ    => SRAM_DQ,
			SRAM_UB_N  => SRAM_UB_N,
			SRAM_LB_N  => SRAM_LB_N,
			clk        => clk,
			chipselect => dcsel(0),
			write      => write,
			data_out   => data_out_SRAM(15 downto 0),
			address    => addressram,
			data_in    => data_in_SRAM(15 downto 0)
		);

	process(clk)
	begin
		if rising_edge(clk) then

			if (dcsel = "11") then
				--chipselect <= '1';

				write         <= d_we;
				data_out_SRAM <= ddata_w;
				--LEDR(15 DOWNTO 0) <= data_out_SRAM(15 downto 0);

				--ddata_r <= data_in_SRAM;
				--LEDR(15 DOWNTO 0) <= data_in_SRAM;
			end if;
		end if;
	end process;

	------------------------------------

	-- 32-bits x 1024 words quartus RAM (dual port: portA -> riscV, portB -> In-System Mem Editor
	iram_quartus_inst : entity work.iram_quartus
		port map(
			address => address,
			byteena => "1111",
			clock   => clk,
			data    => (others => '0'),
			wren    => '0',
			q       => idata
		);

	-- Data Memory RAM
	dmem : entity work.dmemory
		generic map(
			MEMORY_WORDS => DMEMORY_WORDS
		)
		port map(
			rst        => rst,
			clk        => clk,
			data       => ddata_w,
			address    => daddress,
			we         => d_we,
			signal_ext => d_sig,
			csel       => dcsel(0),
			dmask      => dmask,
			q          => ddata_r_mem
		);

	-- Adress space mux ((check sections.ld) -> Data chip select:
	-- 0x00000    ->    Instruction memory
	-- 0x20000    ->    Data memory
	-- 0x40000    ->    Input/Output generic address space		
	with dcsel select ddata_r <=
		idata when "00",
		ddata_r_mem when "01",
     	input_in when "10",
        data_out_SRAM when "11",(others => '0') when others;

	-- Softcore instatiation
	myRisc : entity work.core
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
			d_sig    => d_sig,
			dcsel    => dcsel,
			dmask    => dmask,
			state    => state
		);

	-- Output register (Dummy LED blinky)
	process(clk, rst)
	begin
		if rst = '1' then
			--LEDR(3 downto 0) <= (others => '0');			
			HEX0 <= (others => '1');
			HEX1 <= (others => '1');
			HEX2 <= (others => '1');
			HEX3 <= (others => '1');
			HEX4 <= (others => '1');
			HEX5 <= (others => '1');
		else
			if rising_edge(clk) then
				if (d_we = '1') and (dcsel = "10") then
					-- ToDo: Simplify comparators
					-- ToDo: Maybe use byte addressing?  
					--       x"01" (word addressing) is x"04" (byte addressing)
					if to_unsigned(daddress, 32)(8 downto 0) = x"01" then
					--LEDR(4 downto 0) <= ddata_w(4 downto 0);
					elsif to_unsigned(daddress, 32)(8 downto 0) = x"02" then
						HEX0 <= ddata_w(6 downto 0);
						HEX1 <= ddata_w(13 downto 7);
						HEX2 <= ddata_w(20 downto 14);
						HEX3 <= ddata_w(27 downto 21);
						HEX4 <= (others => '1');
						HEX5 <= (others => '1');
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
				input_in <= (others => '0');
				if (d_rd = '1') and (dcsel = "10") then
					input_in(4 downto 0) <= SW(4 downto 0);
				end if;
			end if;
		end if;
	end process;

end;
