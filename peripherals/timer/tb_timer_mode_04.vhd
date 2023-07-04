library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------
entity testbench_timer_mode_04 is
end entity testbench_timer_mode_04;
------------------------------

architecture stimulus of testbench_timer_mode_04 is

    constant prescaler_size_for_test : integer := 16;
    constant compare_size_for_test   : integer := 16;
    constant clock_period : time := 10 ns;
    constant TIMER_BASE_ADDRESS : unsigned(15 downto 0):=x"0050";
    
    signal clock : std_logic;
    signal reset : std_logic;
    signal daddress : unsigned(15 downto 0);
    signal ddata_w : std_logic_vector(31 downto 0);
    signal ddata_r : std_logic_vector(31 downto 0);
    signal d_we : std_logic;
    signal d_rd : std_logic;
    signal dcsel : std_logic_vector(1 downto 0);
    signal dmask : std_logic_vector(3 downto 0);
    signal timer_interrupt : std_logic_vector(5 downto 0);
    signal ifcap : std_logic;
    
begin
    
    timer: entity work.Timer
        generic map(
            DADDRESS_BUS_SIZE => compare_size_for_test,
            prescaler_size    => prescaler_size_for_test,
            compare_size      => compare_size_for_test
        )
        port map(
            clock           => clock,
            reset           => reset,
            daddress        => daddress,
            ddata_w         => ddata_w,
            ddata_r         => ddata_r,
            d_we            => d_we,
            d_rd            => d_rd,
            dcsel           => dcsel,
            dmask           => dmask,
            timer_interrupt => timer_interrupt,
            ifcap => ifcap
        );

    test_clock : process
    begin
        clock <= '0';
        wait for clock_period/2;
        clock <= '1';
        wait for clock_period/2;
    end process;

    test : process
    begin
        ddata_w <= (others => '0');
        timer_interrupt <= (others => '0');
        ifcap <= '0';
        
        reset <= '1';       
        wait for clock_period;

        -- run timer:
        reset <= '0';
        wait for clock_period;
        
        -- set mode
        d_we <= '1';
        dcsel <= "10";
        daddress <= TIMER_BASE_ADDRESS + x"0001";
        ddata_w(2 downto 0) <= "100";
        wait for clock_period;

        -- set prescaler:
        daddress <= TIMER_BASE_ADDRESS + x"0002";
        ddata_w(15 downto 0) <= x"0001";
        wait for clock_period;
        
        -- reset timer
        daddress <= TIMER_BASE_ADDRESS;
        wait for clock_period;
        
        ddata_w(15 downto 0) <= x"0000";
        daddress <= TIMER_BASE_ADDRESS;
        wait for clock_period;
        
        d_we <= '0';
        d_rd <= '1';
        daddress <= TIMER_BASE_ADDRESS+ x"000c";
        wait for 10*clock_period;
        
        ifcap <= '1';
        wait for 2* clock_period;
        
        ifcap <= '0';
        wait for 15*clock_period;
        
        ifcap <= '1';
        wait for 2* clock_period;
        
        ifcap <= '0';
        wait for 5*clock_period;
        
        ifcap <= '1';
        wait for 2* clock_period;
        
        ifcap <= '0';
        wait for clock_period;

        wait;
    end process;

end architecture stimulus;
