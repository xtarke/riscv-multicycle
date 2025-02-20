library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cordic_bus_tb is
end entity;

architecture testbench of cordic_bus_tb is
    constant CLK_PERIOD : time := 10 ns;
    
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal daddress : unsigned(31 downto 0) := (others => '0');
    signal ddata_w : std_logic_vector(31 downto 0) := (others => '0');
    signal ddata_r : std_logic_vector(31 downto 0);
    signal d_we : std_logic := '0';
    signal d_rd : std_logic := '0';
    signal dcsel : std_logic_vector(1 downto 0) := "10";
    signal dmask : std_logic_vector(3 downto 0) := "1111";
    
    signal start_bus : std_logic := '0';
    signal valid_bus : std_logic;

begin
    -- Clock process
    clk_process : process
    begin
        while now < 1 us loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;
    
    rst_process : process
    begin
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait;
    end process;
    
    dut : entity work.cordic_bus
        generic map (
            MY_CHIPSELECT => "10",
            MY_WORD_ADDRESS => x"0000",
            DADDRESS_BUS_SIZE => 32,
            DATA_WIDTH_BUS => 16
        )
        port map (
            clk => clk,
            rst => rst,
            daddress => daddress,
            ddata_w => ddata_w,
            ddata_r => ddata_r,
            d_we => d_we,
            d_rd => d_rd,
            dcsel => dcsel,
            dmask => dmask,
            start_bus => start_bus,
            valid_bus => valid_bus
        );
    
    -- Test process
    test_process : process
        function to_q214(angle: real) return signed is
        begin
            return to_signed(integer(angle * 2.0**14 / 1.0), 16);
        end function;

    begin
        wait for 30 ns;
        
        -- Write angle
        d_we <= '1';
        daddress(15 downto 0) <= x"0001";
        dcsel <= "10";
        ddata_w <= x"0000" & std_logic_vector(to_q214(0.5236));
        wait for CLK_PERIOD;
        d_we <= '0';
        
        -- Start computation
        start_bus <= '1';
        wait for CLK_PERIOD;
        start_bus <= '0';
        
        -- Wait for valid signal
        wait until valid_bus = '1';
        
        -- Read results
        daddress(15 downto 0) <= x"0000";
        d_rd <= '1';
        wait for 2*CLK_PERIOD;
        d_rd <= '0';

        wait for 30 ns;
        
        -- Write angle
        d_we <= '1';
        daddress(15 downto 0) <= x"0001";
        dcsel <= "10";
        ddata_w <= x"0000" & std_logic_vector(to_q214(0.7854));
        wait for CLK_PERIOD;
        d_we <= '0';
        
        -- Start computation
        start_bus <= '1';
        wait for CLK_PERIOD;
        start_bus <= '0';
        
        -- Wait for valid signal
        wait until valid_bus = '1';
        
        -- Read results
        daddress(15 downto 0) <= x"0000";
        d_rd <= '1';
        wait for 2*CLK_PERIOD;
        d_rd <= '0';

        wait;
    end process;
end architecture;