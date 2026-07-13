-------------------------------------------------------
--! @file   tb_riscv.vhd
--! @brief  Testbench mínimo para o controlador CAN
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.decoder_types.all;

entity tb_riscv is
end entity tb_riscv;

architecture sim of tb_riscv is
    constant CLK_PERIOD   : time := 1000 ns;
    constant CLK32_PERIOD : time := 20 ns;

    signal clk       : std_logic := '0';
    signal clk_32x   : std_logic := '0';
    signal rst       : std_logic;

    signal address  : std_logic_vector(9 downto 0);
    signal iaddress : unsigned(15 downto 0);
    signal idata    : std_logic_vector(31 downto 0);

    signal daddress : unsigned(31 downto 0);
    signal ddata_w  : std_logic_vector(31 downto 0);
    signal ddata_r  : std_logic_vector(31 downto 0);
    signal d_we     : std_logic;
    signal d_rd     : std_logic;
    signal d_sig    : std_logic;
    signal dcsel    : std_logic_vector(1 downto 0);	--"00" = memória de dados, "01" = instruções, "10" = periféricos
    signal dmask    : std_logic_vector(3 downto 0);
    signal ddata_r_mem : std_logic_vector(31 downto 0);
    signal ddata_r_periph : std_logic_vector(31 downto 0);

    signal ddata_r_sdram : std_logic_vector(31 downto 0) := (others => '0');
    signal ddata_r_can   : std_logic_vector(31 downto 0);

    signal interrupts : std_logic_vector(31 downto 0) := (others => '0');

    signal can_rx    : std_logic := '1';
    signal can_tx    : std_logic;
    signal can_sel   : std_logic;
    signal can_wr_en : std_logic;

    signal cpu_state : cpu_state_t;
    signal debugString : string(1 to 40) := (others => '0');
	signal can_reg_addr : unsigned(7 downto 0);

	signal tmp : unsigned(31 downto 0);
begin
	-- Cálculo: word address → byte address → subtrai base → offset
	-- tmp <= resize(daddress sll 2, 32) - x"04000640";
	tmp <= daddress - x"01000190";
	-- can_reg_addr <= tmp(7 downto 0);
	can_reg_addr <= tmp(7 downto 0) when (dcsel = "10") else (others => '0');
    can_wr_en <= '1' when (dcsel = "10" and daddress(19 downto 4) = x"0019") else '0';
	-- can_reg_addr <= tmp(7 downto 0) when (dcsel = "10" and daddress(19 downto 4) = x"0019") else (others => '0');

    -----------------------------------------------------------------
    -- CAN
    -----------------------------------------------------------------

	can_inst: entity work.can_top
    port map (
        clk        => clk,
        rst        => rst,
        bus_addr   => can_reg_addr,
        reg_wr_en  => can_wr_en,
        bus_wdata  => ddata_w,
        bus_rdata  => ddata_r_can,
        can_rx     => can_rx,
        can_tx     => can_tx
    );

		entity can_top is
			port(
				clk : in std_logic;     -- faster clock from CPU
				rst : in std_logic;     -- reset from CPU

				-- Data interface with CPU
				bus_addr      : in  unsigned(7 downto 0);  -- only the lowest 8 bits is read (target register addr)
				reg_wr_en     : in  std_logic;      -- instead a instruction like in SPI, this pin allows the can peripheral registers write
				bus_wdata     : in  std_logic_vector(31 downto 0);  -- only the lowest 8 bits is read (data to be read)
				bus_rdata     : out std_logic_vector(31 downto 0); -- Data read from the target register @TODO

				-- Transceiver CAN interface
				can_rx        : in  std_logic;  -- Receives serial data
				can_tx        : out std_logic   -- Sends serial data
			);
    -- clocks
    clk <= not clk after CLK_PERIOD/2;
    clk_32x <= not clk_32x after CLK32_PERIOD/2;

    -- reset
    process begin
        rst <= '1';
        wait for 150 ns;
        rst <= '0';
        wait;
    end process;

    -----------------------------------------------------------------
    -- Barramento de instrução
    -----------------------------------------------------------------
    instr_mux: entity work.instructionbusmux
        port map (d_rd, dcsel, daddress, iaddress, address);

    iram_inst: entity work.iram_quartus
        generic map (init_file => "./software/can/can_main.hex")
        port map (address, "1111", clk, (others => '0'), '0', idata);

    -----------------------------------------------------------------
    -- Memória de dados (com associação explícita)
    -----------------------------------------------------------------
    dmem_inst: entity work.dmemory
        generic map (MEMORY_WORDS => 1024)
        port map (
            rst        => rst,
            clk        => clk,
            data       => ddata_w,
            address    => daddress,
            we         => d_we,
            csel       => dcsel(0),
            dmask      => dmask,
            signal_ext => d_sig,
            q          => ddata_r_mem
        );

    -----------------------------------------------------------------
    -- Multiplexador principal do barramento
    -----------------------------------------------------------------
    data_bus_mux: entity work.databusmux
        port map (dcsel, idata, ddata_r_mem, ddata_r_periph, ddata_r_sdram, ddata_r);

    -----------------------------------------------------------------
    -- Multiplexador de periféricos (apenas CAN)
    -----------------------------------------------------------------
    io_mux: entity work.iodatabusmux
        port map (
            daddress         => daddress,
            ddata_r_gpio     => (others => '0'),
            ddata_r_segments => (others => '0'),
            ddata_r_uart     => (others => '0'),
            ddata_r_adc      => (others => '0'),
            ddata_r_i2c      => (others => '0'),
            ddata_r_timer    => (others => '0'),
            ddata_r_dif_fil  => (others => '0'),
            ddata_r_stepmot  => (others => '0'),
            ddata_r_lcd      => (others => '0'),
            ddata_r_nn_accelerator => (others => '0'),
            ddata_r_fir_fil  => (others => '0'),
            ddata_r_spwm     => (others => '0'),
            ddata_r_crc      => (others => '0'),
            ddata_r_key      => (others => '0'),
            ddata_r_accelerometer => (others => '0'),
            ddata_r_cordic   => (others => '0'),
            ddata_r_RS485    => (others => '0'),
            ddata_r_rgb      => (others => '0'),
            ddata_r_morse    => (others => '0'),
            ddata_r_can      => ddata_r_can,
            ddata_r_periph   => ddata_r_periph
        );

    -----------------------------------------------------------------
    -- Core RISC-V
    -----------------------------------------------------------------
    core_inst: entity work.core
        port map (clk, rst, clk_32x, iaddress, idata, daddress, ddata_r, ddata_w,
                   d_we, d_rd, d_sig, dcsel, dmask, interrupts, cpu_state);


    -----------------------------------------------------------------
    -- Debug
    -----------------------------------------------------------------
    debug_inst: entity work.trace_debug
        generic map (MEMORY_WORDS => 1024)
        port map (iaddress, idata, debugString);

end architecture sim;