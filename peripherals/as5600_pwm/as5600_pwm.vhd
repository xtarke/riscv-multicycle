library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity as5600_pwm is
    generic(
        MY_CHIPSELECT   : std_logic_vector(1 downto 0) := "10"; --! Chip select of this device
        MY_WORD_ADDRESS : unsigned(15 downto 0)        := x"01A0" --! Base address of this device
    );
    port(
        clk      : in  std_logic;
        rst      : in  std_logic;
        
        -- Core data bus signals
        daddress : in  unsigned(31 downto 0);
        ddata_w  : in  std_logic_vector(31 downto 0);
        ddata_r  : out std_logic_vector(31 downto 0);
        d_we     : in  std_logic;
        d_rd     : in  std_logic;
        dcsel    : in  std_logic_vector(1 downto 0); 
        dmask    : in  std_logic_vector(3 downto 0); 
        
        -- hardware input signal
        pwm_in   : in  std_logic
    );
end entity as5600_pwm;

architecture RTL of as5600_pwm is
    signal high_counter   : unsigned(31 downto 0);
    signal period_counter : unsigned(31 downto 0);
    signal t_high_reg     : unsigned(31 downto 0);
    signal t_period_reg   : unsigned(31 downto 0);
    
    -- Signals for synchronizing the asynchronous input to the clock domain
    signal pwm_sync_1 : std_logic;
    signal pwm_sync_2 : std_logic;
begin

    -- Synchronize asynchronous pwm_in to clk domain to avoid metastability
    process(clk, rst)
    begin
        if rst = '1' then
            pwm_sync_1 <= '0';
            pwm_sync_2 <= '0';
        elsif rising_edge(clk) then
            pwm_sync_1 <= pwm_in;
            pwm_sync_2 <= pwm_sync_1;
        end if;
    end process;

    -- Measure high time and total period
    process(clk, rst)
    begin
        if rst = '1' then
            high_counter   <= (others => '0');
            period_counter <= (others => '0');
            t_high_reg     <= (others => '0');
            t_period_reg   <= (others => '0');
        elsif rising_edge(clk) then
            -- Increment period counter continuously
            period_counter <= period_counter + 1;
            
            -- Increment high counter only when PWM is high
            if pwm_sync_2 = '1' then
                high_counter <= high_counter + 1;
            end if;
            
            -- Detect rising edge of PWM signal
            if pwm_sync_1 = '1' and pwm_sync_2 = '0' then
                -- Rising edge detected: save current counter values to registers
                t_period_reg <= period_counter;
                t_high_reg   <= high_counter;
                
                -- Reset counters for the new cycle
                period_counter <= to_unsigned(1, 32); 
                -- If it's already high in this clock cycle, start high counter at 1
                high_counter <= to_unsigned(1, 32);
            end if;
        end if;
    end process;

    -- Bus Read Interface (Memory Mapped I/O)
    process(clk, rst)
    begin
        if rst = '1' then
            ddata_r <= (others => '0');
        elsif rising_edge(clk) then
            if (d_rd = '1') and (dcsel = MY_CHIPSELECT) then
                -- Offset 0: Read t_high
                if daddress(15 downto 0) = MY_WORD_ADDRESS then
                    ddata_r <= std_logic_vector(t_high_reg);
                -- Offset 4: Read t_period
                elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 4) then
                    ddata_r <= std_logic_vector(t_period_reg);
                else
                    ddata_r <= (others => '0');
                end if;
            end if;
        end if;
    end process;

end architecture RTL;
