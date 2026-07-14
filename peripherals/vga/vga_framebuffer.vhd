--------------------------------------------------------------------------------
--  VGA framebuffer top entity
--------------------------------------------------------------------------------
--
-- VGA framebuffer backed by SDRAM through sdram_cache.
--
-- What it does:
--   - Reads pixels from SDRAM through sdram_cache and drives the VGA rgb output.
--   - Pops one cache word per active pixel and registers it as rgb.
--   - Exposes a write port so the CPU can write into the framebuffer.
--   - Flushes the cache read side each vsync so prefetch restarts at pixel 0.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sdram_pkg.all;

entity vga_framebuffer is
	generic(
		FRAME_WORDS : natural := 307200;   -- 640x480, 1 word/pixel
		DATA_AVAL   : integer := 2
	);

	port(
		-- inputs:
		clk       : in std_logic;          -- 125 MHz sdram/cache domain
		reset     : in std_logic;
		pixel_en  : in std_logic;
		disp_ena  : in std_logic;          -- active video
		vsync     : in std_logic;          -- frame start (neg polarity)
		-- CPU write port (one 16-bit pixel per commit, throttle on write_busy):
		write_commit  : in std_logic;
		write_address : in std_logic_vector(31 downto 0);
		write_data    : in std_logic_vector(15 downto 0);
		-- outputs:
		rgb        : out std_logic_vector(15 downto 0);
		write_busy : out std_logic;        -- write fifo almost full
		DRAM_ADDR  : out   std_logic_vector(12 downto 0);
		DRAM_BA    : out   std_logic_vector(1 downto 0);
		DRAM_CAS_N : out   std_logic;
		DRAM_CKE   : out   std_logic;
		DRAM_CLK   : out   std_logic;
		DRAM_CS_N  : out   std_logic;
		DRAM_DQ    : inout std_logic_vector(15 downto 0);
		DRAM_LDQM  : out   std_logic;
		DRAM_RAS_N : out   std_logic;
		DRAM_UDQM  : out   std_logic;
		DRAM_WE_N  : out   std_logic
	);
end entity vga_framebuffer;

architecture rtl of vga_framebuffer is

	-- cache user side
	signal read_enable  : std_logic;
	signal read_address : std_logic_vector(31 downto 0);
	signal read_data    : std_logic_vector(15 downto 0);
	signal read_lock    : std_logic;

	-- cache <-> controller
	signal c_addr       : std_logic_vector(31 downto 0);
	signal c_read       : std_logic;
	signal c_write      : std_logic;
	signal c_cs         : std_logic;
	signal c_write_data : io_buffer_t;
	signal c_read_data  : io_buffer_t;
	signal c_valid_cnt  : integer range 0 to 8;
	signal c_wait       : std_logic;
	signal DRAM_DQM     : std_logic_vector(1 downto 0);

	signal ridx       : integer range 0 to FRAME_WORDS;  -- pixel counter
	signal vsync_d    : std_logic;
	signal read_flush : std_logic;

begin

	cache : entity work.sdram_cache
		port map(
			clk          => clk,
			reset        => reset,
			read_enable  => read_enable,
			read_address => read_address,
			read_data    => read_data,
			read_lock    => read_lock,
			read_flush   => read_flush,
			write_commit           => write_commit,
			write_address          => write_address,
			write_data             => write_data,
			write_fifo_almost_full => write_busy,
			read_used              => open,
			sdram_read_buffer      => c_read_data,
			sdram_read_valid_count => c_valid_cnt,
			sdram_wait_request     => c_wait,
			sdram_addr             => c_addr,
			sdram_read             => c_read,
			sdram_write            => c_write,
			sdram_write_data       => c_write_data,
			sdram_chip_select      => c_cs
		);

	sdram_controller : entity work.sdram_controller
		generic map(
			DATA_AVAL => DATA_AVAL
		)
		port map(
			address          => c_addr,
			byteenable       => "11",
			chipselect       => c_cs,
			clk              => clk,
			clken            => '1',
			reset            => reset,
			reset_req        => reset,
			write            => c_write,
			read             => c_read,
			write_data       => c_write_data,
			read_data        => c_read_data,
			read_valid_count => c_valid_cnt,
			waitrequest      => c_wait,
			DRAM_ADDR        => DRAM_ADDR,
			DRAM_BA          => DRAM_BA,
			DRAM_CAS_N       => DRAM_CAS_N,
			DRAM_CKE         => DRAM_CKE,
			DRAM_CLK         => DRAM_CLK,
			DRAM_CS_N        => DRAM_CS_N,
			DRAM_DQ          => DRAM_DQ,
			DRAM_DQM         => DRAM_DQM,
			DRAM_RAS_N       => DRAM_RAS_N,
			DRAM_WE_N        => DRAM_WE_N
		);

	DRAM_UDQM <= DRAM_DQM(1);
	DRAM_LDQM <= DRAM_DQM(0);

	-- Scanout: the display address is the pixel counter
	read_address <= std_logic_vector(to_unsigned(ridx, 32));
	read_enable  <= pixel_en and disp_ena;

	process(clk, reset)
	begin
		if reset = '1' then
			ridx <= 0;
			rgb <= (others => '0');
			vsync_d <= '1';
			read_flush <= '0';
		elsif rising_edge(clk) then
			read_flush <= '0';
			vsync_d <= vsync;

			-- Frame start (vsync assert): restart the scan and flush the cache
			-- read side (pending CPU writes survive), so it prefetches pixel 0..
			-- during the remaining vblank
			if vsync = '0' and vsync_d = '1' then
				ridx <= 0;
				read_flush <= '1';
			elsif pixel_en = '1' and disp_ena = '1' then
				if read_lock = '0' then
					-- this cycle pops pixel ridx
					rgb <= read_data;
					if ridx < FRAME_WORDS then
						ridx <= ridx + 1;
					end if;
				end if;
			end if;
		end if;
	end process;

end architecture rtl;
