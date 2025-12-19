library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity tb_pwm_bldc_tester is
end entity;

architecture behavior of tb_pwm_bldc_tester is

    signal clk_tb     : std_logic := '0';
    signal pwm_out_tb : std_logic;
    signal stop_tb    : std_logic := '0';
    signal mode_tb    : std_logic_vector(2 downto 0) := (others => '0');
    signal enter_tb   : std_logic := '0';
    signal weight_tb  : unsigned(19 downto 0) := to_unsigned(500, 20);
    signal fault_tb   : std_logic;

begin

    -- DUT
    dut : entity work.motor_test_bldc
        port map (
            clk     => clk_tb,
            mode    => mode_tb,
            enter   => enter_tb,
            motor_emergency_stop => stop_tb,
            weight  => weight_tb,
            pwm_out => pwm_out_tb,
            fault   => fault_tb
        );

    --------------------------------------------------------------------
    -- Clock 50 MHz
    --------------------------------------------------------------------
    clk_process : process
    begin
        loop
            clk_tb <= '0';
            wait for 10 ns;
            clk_tb <= '1';
            wait for 10 ns;
        end loop;
    end process;

    --------------------------------------------------------------------
    -- Estímulos FSM
    --------------------------------------------------------------------
    stim_process : process
    begin
        -- Reset inicial
        stop_tb <= '1';
        wait for 20 ms;

        stop_tb <= '0';
        mode_tb <= "011";  -- A_10
        wait for 5 ms;

        enter_tb <= '1';
        wait for 2 ms;
        enter_tb <= '0';

        -- espera atingir duty >= 1100 (~10 s)
        wait for 1.1 sec;

        -- força falha
        weight_tb <= to_unsigned(0, 20);

        wait for 0.5 sec;

        -- valida STOP
        stop_tb <= '1';
        wait for 50 ms;
        stop_tb <= '0';

        wait;
    end process;

end architecture;
