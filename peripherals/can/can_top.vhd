-------------------------------------------------------
--! @file   can_top.vhdl
--! @author Christopher Costa
--! @date   29/06/2026
--! @brief  VHDL implementation of CAN 2.0A controller as
--          a RISC-V peripheral
--                     | TOP ENTITY |
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.can_pkg.t_tx_data_regs;

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
end entity can_top;

architecture RTL of can_top is

    -- Signals to connect multiple entities
    signal clk_out          : std_logic;
    signal current_state    : std_logic_vector(3 downto 0);

    -- Signals to connect register_map.vhd <-> can_engine.vhd
    signal baud_reg_out    : std_logic_vector(7 downto 0);

    -- Signals to connect register_map.vhd <-> can_fsm.vhd
    signal txb0ctrl_out    : std_logic_vector(7 downto 0);
    signal txb0sidh_out    : std_logic_vector(7 downto 0);
    signal txb0sidl_out    : std_logic_vector(7 downto 0);
    signal txb0dlc_out     : std_logic_vector(7 downto 0);
    signal canctrl_reg     : std_logic_vector(7 downto 0);
    signal r_TXB0Dn        : t_tx_data_regs;
    signal core_canstat_s  : std_logic_vector(7 downto 0);
    signal core_canstat_we : std_logic;

    -- Signals to connect can_fsm.vhd <-> can_engine.vhd
    signal tx_bit_in     : std_logic;
    signal rx_bit_out    : std_logic;
    signal tx_abort      : std_logic;
    signal stuff_nxt_bit : std_logic;
	signal bus_addr_vec     : std_logic_vector(7 downto 0);

	signal tx_done : std_logic;
begin
	bus_addr_vec <=std_logic_vector(bus_addr);
    -- Instantiate register_map.vhd
    register_map_inst : entity work.register_map
        port map(
            clk             => clk,
            rst             => rst,
            bus_addr        => bus_addr_vec,
            bus_wdata       => bus_wdata,
            bus_rdata       => bus_rdata,
            bus_we          => reg_wr_en,
            baud_reg_out    => baud_reg_out,
            canctrl_out     => canctrl_reg,
            txb0ctrl_out    => txb0ctrl_out,
            txb0sidh_out    => txb0sidh_out,
            txb0sidl_out    => txb0sidl_out,
            txb0dlc_out     => txb0dlc_out,
            txb0dn_out      => r_TXB0Dn,
            core_canstat_in => core_canstat_s,
            core_canstat_we => core_canstat_we,
			tx_done			=> tx_done
            --core_tec_in     => core_tec_in,
            --core_rec_in     => core_rec_in,
            --core_eflg_in    => core_eflg_in,
            --core_status_we  => core_status_we
        );

    -- Instantiate can_fsm.vhd
    can_fsm_inst : entity work.can_fsm
        port map(
            clk               => clk_out,
            rst               => rst,
            tx_abort          => tx_abort,
            current_state_out => current_state,
            canctrl_reg       => canctrl_reg,
            txb0ctrl_reg      => txb0ctrl_out,
            txb0sidh_reg      => txb0sidh_out,
            txb0sidl_reg      => txb0sidl_out,
            txb0dlc_reg       => txb0dlc_out,
            r_TXB0Dn          => r_TXB0Dn,
            can_rx            => rx_bit_out,
            can_tx            => tx_bit_in,
            core_canstat_out  => core_canstat_s,
            core_canstat_we   => core_canstat_we,
            stuff_nxt_bit     => stuff_nxt_bit,
			tx_done			=> tx_done
            --debug             => debug
        );


    -- Instantiate can_engine.vhd
    can_engine_inst : entity work.can_engine
        port map(
            clk               => clk,
            clk_out           => clk_out,
            rst               => rst,
            baud_reg          => baud_reg_out,
            current_state     => current_state,
            tx_bit_in         => tx_bit_in,
            rx_bit_out        => rx_bit_out,
            tx_abort          => tx_abort,
            stuff_nxt_bit_out => stuff_nxt_bit,
            can_rx            => can_rx,
            can_tx            => can_tx
        );

end architecture RTL;