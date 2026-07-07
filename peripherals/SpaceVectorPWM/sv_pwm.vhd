-------------------------------------------------------
--! @file sv_pwm.vhd
--! @brief Space Vector PWM Peripheral for RISC-V Multicycle Softcore
--
-- Register Map (MY_WORD_ADDRESS = x"0190", iodatabusmux key = x"0019"):
--
--   Offset | Access | Signal  | Description
--   +0     |  W/R   | v_bar   | DC bus voltage, unsigned 16-bit [V]
--   +1     |  W/R   | u_cmd   | Desired output voltage, signed 16-bit [V]
--   +2     |  W/R   | f_sw    | Switching frequency [Hz], unsigned 32-bit
--   +3     |  R     | status  | Gate states: bit3=gate_s4..bit0=gate_s1
--   +4     |  W/R   | ctrl    | bit0=enable (1=start PWM, 0=stop: gates forced low)
--
-- C driver (add to software/_core/hardware.h):
--   #define SV_PWM_BASE_ADDRESS (*(_IO32 *) (PERIPH_BASE + 25*16*4))
--
-- iodatabusmux update required:
--   - Add port:  ddata_r_sv_pwm : in std_logic_vector(31 downto 0)
--   - Add entry: ddata_r_sv_pwm when x"0019"
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sv_pwm is
    generic (
        MY_CHIPSELECT     : std_logic_vector(1 downto 0) := "10";
        MY_WORD_ADDRESS   : unsigned(15 downto 0)        := x"0190";
        DADDRESS_BUS_SIZE : integer := 32;
        INPUT_CLK_FREQ    : natural := 50000000;
        DEADTIME_CYCLES   : natural := 50
    );
    port (
        clk     : in std_logic;
        rst     : in std_logic;

        -- Core data bus signals
        daddress : in  unsigned(DADDRESS_BUS_SIZE-1 downto 0);
        ddata_w  : in  std_logic_vector(31 downto 0);
        ddata_r  : out std_logic_vector(31 downto 0);
        d_we     : in  std_logic;
        d_rd     : in  std_logic;
        dcsel    : in  std_logic_vector(1 downto 0);
        dmask    : in  std_logic_vector(3 downto 0);

        -- PWM gate outputs (H-bridge)
        gate_s1 : out std_logic;
        gate_s2 : out std_logic;
        gate_s3 : out std_logic;
        gate_s4 : out std_logic
    );
end entity sv_pwm;

architecture RTL of sv_pwm is

    -- Software-configurable registers (32-bit, softcore standard)
    signal reg_v_bar : unsigned(31 downto 0) := to_unsigned(100, 32);
    signal reg_u_cmd : signed(31 downto 0)   := (others => '0');
    signal reg_f_sw  : natural               := 10000;
    signal reg_start : std_logic             := '0';

    -- Switching period in clock cycles (updated when reg_f_sw changes)
    signal ts_cycles : natural := INPUT_CLK_FREQ / 10000;

    -- FSM states
    type state_type is (
        ST_CALCULATE,
        ST_S2_S4_ON_1, ST_DEADTIME_1,
        ST_S1_S4_ON,   ST_S2_S3_ON_1, ST_DEADTIME_2,
        ST_S1_S3_ON,   ST_DEADTIME_3, ST_S1_S4_ON_2,
        ST_S2_S3_ON_2, ST_DEADTIME_4, ST_S2_S4_ON_2
    );
    signal current_state, next_state : state_type;

    -- Timer
    signal timer_count  : natural := 0;
    signal timer_target : natural := 1;
    signal timer_tick   : std_logic := '0';
    signal timer_en     : std_logic := '0';

    -- Timing registers (clock cycles)
    signal t_v0_reg          : natural := 0;
    signal t_v_at_metade_reg : natural := 0;
    signal t_v3_reg          : natural := 0;

    -- Output voltage polarity
    signal vout_is_positive : boolean := true;

    -- Internal gate signals (allows read-back at status register)
    signal i_gate_s1 : std_logic := '0';
    signal i_gate_s2 : std_logic := '0';
    signal i_gate_s3 : std_logic := '0';
    signal i_gate_s4 : std_logic := '0';

begin

    gate_s1 <= i_gate_s1;
    gate_s2 <= i_gate_s2;
    gate_s3 <= i_gate_s3;
    gate_s4 <= i_gate_s4;

    -- Write process: receive v_bar, u_cmd, f_sw from CPU
    process(clk, rst)
    begin
        if rst = '1' then
            reg_v_bar <= to_unsigned(100, 32);
            reg_u_cmd <= (others => '0');
            reg_f_sw  <= 10000;
            ts_cycles <= INPUT_CLK_FREQ / 10000;
            reg_start <= '0';
        elsif rising_edge(clk) then
            if (d_we = '1') and (dcsel = MY_CHIPSELECT) then
                if daddress(15 downto 0) = MY_WORD_ADDRESS then
                    reg_v_bar <= unsigned(ddata_w);
                elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 1) then
                    reg_u_cmd <= signed(ddata_w);
                elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 2) then
                    if to_integer(unsigned(ddata_w)) > 0 then
                        reg_f_sw  <= to_integer(unsigned(ddata_w));
                        ts_cycles <= INPUT_CLK_FREQ / to_integer(unsigned(ddata_w));
                    end if;
                elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 4) then
                    reg_start <= ddata_w(0);
                end if;
            end if;
        end if;
    end process;

    -- Read process: expose registers and gate status to CPU
    process(clk, rst)
    begin
        if rst = '1' then
            ddata_r <= (others => '0');
        elsif rising_edge(clk) then
            ddata_r <= (others => '0');
            if (d_rd = '1') and (dcsel = MY_CHIPSELECT) then
                if daddress(15 downto 0) = MY_WORD_ADDRESS then
                    ddata_r <= std_logic_vector(reg_v_bar);
                elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 1) then
                    ddata_r <= std_logic_vector(reg_u_cmd);
                elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 2) then
                    ddata_r <= std_logic_vector(to_unsigned(reg_f_sw, 32));
                elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 3) then
                    ddata_r(3 downto 0) <= i_gate_s4 & i_gate_s3 & i_gate_s2 & i_gate_s1;
                elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 4) then
                    ddata_r(0) <= reg_start;
                end if;
            end if;
        end if;
    end process;

    -- Timing calculation: compute SVPWM vector durations from v_bar, u_cmd, ts_cycles
    process(clk, rst)
        variable u_cmd_abs : integer;
        variable delta_t1  : integer;
        variable t_nulo    : integer;
    begin
        if rst = '1' then
            t_v0_reg          <= 0;
            t_v_at_metade_reg <= 0;
            t_v3_reg          <= 0;
            vout_is_positive  <= true;
        elsif rising_edge(clk) then
            if reg_u_cmd >= 0 then
                vout_is_positive <= true;
                u_cmd_abs := to_integer(reg_u_cmd);
            else
                vout_is_positive <= false;
                u_cmd_abs := to_integer(abs(reg_u_cmd));
            end if;

            if to_integer(reg_v_bar) /= 0 then
                delta_t1 := (ts_cycles * u_cmd_abs) / to_integer(reg_v_bar);
            else
                delta_t1 := 0;
            end if;

            -- Clamp delta_t1 to ts_cycles to prevent negative t_nulo
            if delta_t1 > ts_cycles then
                delta_t1 := ts_cycles;
            end if;

            t_nulo := ts_cycles - delta_t1;
            t_v_at_metade_reg <= delta_t1 / 2;
            t_v3_reg          <= t_nulo / 2;
            t_v0_reg          <= (t_nulo / 2) / 2;
        end if;
    end process;

    -- Timer: counts up to timer_target, then asserts timer_tick for one cycle
    process(clk, rst)
    begin
        if rst = '1' then
            timer_count <= 0;
            timer_tick  <= '0';
        elsif rising_edge(clk) then
            if timer_en = '1' then
                if timer_target = 0 or timer_count >= timer_target - 1 then
                    timer_tick  <= '1';
                    timer_count <= 0;
                else
                    timer_tick  <= '0';
                    timer_count <= timer_count + 1;
                end if;
            else
                timer_count <= 0;
                timer_tick  <= '0';
            end if;
        end if;
    end process;

    -- FSM state register
    process(clk, rst)
    begin
        if rst = '1' then
            current_state <= ST_CALCULATE;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    -- FSM combinational logic
    -- Symmetric sequence: V0 -> V_active -> V3 -> V_active -> V0
    process(current_state, timer_tick, vout_is_positive, t_v0_reg, t_v_at_metade_reg, t_v3_reg, reg_start)
    begin
        i_gate_s1    <= '0';
        i_gate_s2    <= '0';
        i_gate_s3    <= '0';
        i_gate_s4    <= '0';
        timer_en     <= '1';
        timer_target <= 1;
        next_state   <= current_state;

        case current_state is

            when ST_CALCULATE =>
                -- Wait one cycle for timing registers to stabilise after reset
                if reg_start = '1' then
                    timer_en   <= '0';
                    next_state <= ST_S2_S4_ON_1;
                end if;
            -- Sequence start: null vector V0 (S2+S4)
            when ST_S2_S4_ON_1 =>
                i_gate_s2    <= '1'; i_gate_s4 <= '1';
                timer_target <= t_v0_reg;
                if timer_tick = '1' then next_state <= ST_DEADTIME_1; end if;
            when ST_DEADTIME_1 =>

                timer_target <= DEADTIME_CYCLES;
                if vout_is_positive then 
                    next_state <= ST_S1_S4_ON;
                    i_gate_s4 <= '1';
                else
                    next_state <= ST_S2_S3_ON_1;
                    i_gate_s2 <= '1';
                end if;
                
                if timer_tick = '1' then
                    if vout_is_positive then 
                        next_state <= ST_S1_S4_ON;
                    else
                        next_state <= ST_S2_S3_ON_1;
                    end if;
                end if;

            -- VOUT > 0: active vector V1 (S1+S4)
            when ST_S1_S4_ON =>
                i_gate_s1    <= '1'; i_gate_s4 <= '1';
                timer_target <= t_v_at_metade_reg;
                if timer_tick = '1' then next_state <= ST_DEADTIME_2; end if;

            -- VOUT <= 0: active vector V2 (S2+S3)
            when ST_S2_S3_ON_1 =>
                i_gate_s2    <= '1'; i_gate_s3 <= '1';
                timer_target <= t_v_at_metade_reg;
                if timer_tick = '1' then next_state <= ST_DEADTIME_2; end if;

            when ST_DEADTIME_2 =>
                i_gate_s1 <= '1';
                timer_target <= DEADTIME_CYCLES;
                if timer_tick = '1' then next_state <= ST_S1_S3_ON; end if;

                if vout_is_positive then
                    i_gate_s1 <= '1';
                else
                    i_gate_s3 <= '1';
                end if;

            -- Middle: null vector V3 (S1+S3)
            when ST_S1_S3_ON =>
                i_gate_s1    <= '1'; i_gate_s3 <= '1';
                timer_target <= t_v3_reg;
                if timer_tick = '1' then next_state <= ST_DEADTIME_3; end if;

            when ST_DEADTIME_3 =>
                timer_target <= DEADTIME_CYCLES;
        
                if vout_is_positive then 
                        i_gate_s1 <= '1';
                else
                        i_gate_s3  <= '1';
                end if;

                if timer_tick = '1' then
                    if vout_is_positive then 
                        next_state <= ST_S1_S4_ON_2;
                    else
                        next_state <= ST_S2_S3_ON_2; 
                    end if;
                end if;

            -- Return: VOUT > 0 active vector V1 (S1+S4)
            when ST_S1_S4_ON_2 =>
                i_gate_s1    <= '1'; i_gate_s4 <= '1';
                timer_target <= t_v_at_metade_reg;
                if timer_tick = '1' then next_state <= ST_DEADTIME_4; end if;

            -- Return: VOUT <= 0 active vector V2 (S2+S3)
            when ST_S2_S3_ON_2 =>
                i_gate_s2    <= '1'; i_gate_s3 <= '1';
                timer_target <= t_v_at_metade_reg;
                if timer_tick = '1' then next_state <= ST_DEADTIME_4; end if;

            when ST_DEADTIME_4 =>
                timer_target <= DEADTIME_CYCLES;
                if timer_tick = '1' then next_state <= ST_S2_S4_ON_2; end if;
                
                if vout_is_positive then
                    i_gate_s4 <= '1';
                else
                    i_gate_s2 <= '1';
                end if;


            -- Sequence end: null vector V0 (S2+S4)
            when ST_S2_S4_ON_2 =>
                i_gate_s2    <= '1'; i_gate_s4 <= '1';
                timer_target <= t_v0_reg;
                if timer_tick = '1' then next_state <= ST_S2_S4_ON_1; end if;

            -- Recovery net
            when others =>
                next_state <= ST_CALCULATE;
        end case;

        -- Stop request: all gates off, return to idle
        if reg_start = '0' then
            i_gate_s1  <= '0';
            i_gate_s2  <= '0';
            i_gate_s3  <= '0';
            i_gate_s4  <= '0';
            timer_en   <= '0';
            next_state <= ST_CALCULATE;
        end if;
    end process;

end architecture RTL;
