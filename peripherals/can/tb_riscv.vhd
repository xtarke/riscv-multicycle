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
    signal can_wr_en : std_logic;
	signal tx_done   : std_logic;

    signal cpu_state : cpu_state_t;
    signal debugString : string(1 to 40) := (others => '0');
	signal can_reg_addr : unsigned(7 downto 0);

    -- signal can_sel   : std_logic;
	signal tmp : unsigned(31 downto 0);
	signal offset : unsigned(7 downto 0);
	constant BASE_ADDR : unsigned(31 downto 0) := x"01000000"; -- base do espaço
	constant BLOCK_OFFSET : unsigned(31 downto 0) := x"00000700";
begin
	-- Cálculo: word address → byte address → subtrai base → offset
	-- tmp <= resize(daddress sll 2, 32) - x"04000800";
	tmp <= daddress - BASE_ADDR;               -- diferença em relação à base
    offset <= tmp(7 downto 0);                 -- bytes internos do bloco
    -- Verifica se a parte alta (acima do byte) é exatamente BLOCK_OFFSET
    can_wr_en <= '1' when (tmp(15 downto 8) = BLOCK_OFFSET(15 downto 8)) else '0';
    -- ou, mantendo sua forma: (tmp - offset) = BLOCK_OFFSET
    -- can_sel <= '1' when ((tmp - offset) = BLOCK_OFFSET) else '0';

    can_reg_addr <= offset when (dcsel = "10" and can_wr_en = '1') else (others => '0');

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
        can_tx     => can_tx,
		tx_done   => tx_done
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
	-- IMem shoud be read from instruction and data buses
    -- Not enough RAM ports for instruction bus, data bus and in-circuit programming
    instr_mux: entity work.instructionbusmux
        port map(
            d_rd     => d_rd,
            dcsel    => dcsel,
            daddress => daddress,
            iaddress => iaddress,
            address  => address
    );

    iram_inst: entity work.iram_quartus
        -- generic map (init_file => "../../software/can/can_main.hex")
		port map(
			address => address(9 downto 0),
			byteena => "1111",
			clock   => clk,
			data    => (others => '0'),
			wren    => '0',
			q       => idata
		);

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
	-- Adress space mux ((check sections.ld) -> Data chip select:
	-- 0x00000    ->    Instruction memory
	-- 0x20000    ->    Data memory
	-- 0x40000    ->    Input/Output generic address space
	-- 0x60000    ->    SDRAM address space
	data_bus_mux: entity work.databusmux
	    port map(
	        dcsel          => dcsel,
	        idata          => idata,
	        ddata_r_mem    => ddata_r_mem,
	        ddata_r_periph => ddata_r_periph,
	        ddata_r_sdram  => ddata_r_sdram,
	        ddata_r        => ddata_r
	    );

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
            ddata_r_can      => ddata_r_can,
            ddata_r_periph   => ddata_r_periph
        );

    -----------------------------------------------------------------
    -- Core RISC-V
    -----------------------------------------------------------------
	-- Softcore instatiation
	myRiscv : entity work.core
		port map(
			clk      => clk,
			rst      => rst,
			clk_32x  => clk_32x,
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
			interrupts=>interrupts,
			state    => cpu_state
		);
    -----------------------------------------------------------------
    -- Debug
    -----------------------------------------------------------------
    debug_inst: entity work.trace_debug
        generic map (MEMORY_WORDS => 1024)
        port map (iaddress, idata, debugString);

end architecture sim;