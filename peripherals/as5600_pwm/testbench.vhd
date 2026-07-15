library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_as5600_pwm is
end entity tb_as5600_pwm;

architecture sim of tb_as5600_pwm is

    component as5600_pwm is
        generic(
            MY_CHIPSELECT     : std_logic_vector(1 downto 0) := "10";
            MY_WORD_ADDRESS   : unsigned(15 downto 0)        := x"0160";
            DADDRESS_BUS_SIZE : integer := 32
        );
        port(
            clk      : in  std_logic;
            rst      : in  std_logic;
            daddress : in  unsigned(31 downto 0);
            ddata_w  : in  std_logic_vector(31 downto 0);
            ddata_r  : out std_logic_vector(31 downto 0);
            d_we     : in  std_logic;
            d_rd     : in  std_logic;
            dcsel    : in  std_logic_vector(1 downto 0); 
            dmask    : in  std_logic_vector(3 downto 0); 
            pwm_in   : in  std_logic
        );
    end component;

    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal daddress : unsigned(31 downto 0) := (others => '0');
    signal ddata_w  : std_logic_vector(31 downto 0) := (others => '0');
    signal ddata_r  : std_logic_vector(31 downto 0);
    signal d_we     : std_logic := '0';
    signal d_rd     : std_logic := '0';
    signal dcsel    : std_logic_vector(1 downto 0) := "00";
    signal dmask    : std_logic_vector(3 downto 0) := "0000";
    signal pwm_in   : std_logic := '0';

    constant clk_period : time := 1 us; 
    
begin

    DUT: as5600_pwm
        port map (
            clk      => clk,
            rst      => rst,
            daddress => daddress,
            ddata_w  => ddata_w,
            ddata_r  => ddata_r,
            d_we     => d_we,
            d_rd     => d_rd,
            dcsel    => dcsel,
            dmask    => dmask,
            pwm_in   => pwm_in
        );

    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    rst_process : process
    begin
        rst <= '1';
        wait for 5 us;
        rst <= '0';
        wait;
    end process;

    pwm_process : process
    begin
        wait for 10 us; 
        
        pwm_in <= '1';
        wait for 2304 us;
        pwm_in <= '0';
        wait for 6392 us;
 
        pwm_in <= '1';
        wait for 6392 us;
        pwm_in <= '0';
        wait for 2304 us;

        wait;
    end process;
    
    cpu_process : process
    begin
        wait for 10 ms;

        dcsel <= "10";
        d_rd <= '1';
        daddress <= x"00000160";
        wait for 2 * clk_period;
        d_rd <= '0';
        dcsel <= "00";
        
        wait for 5 us;
        
        dcsel <= "10";
        d_rd <= '1';
        daddress <= x"00000161";
        wait for 2 * clk_period;
        d_rd <= '0';
        dcsel <= "00";
        
        wait for 10 ms;
        
        dcsel <= "10";
        d_rd <= '1';
        daddress <= x"00000160";
        wait for 2 * clk_period;
        d_rd <= '0';
        dcsel <= "00";
        
        wait for 5 us;
        
        dcsel <= "10";
        d_rd <= '1';
        daddress <= x"00000161";
        wait for 2 * clk_period;
        d_rd <= '0';
        dcsel <= "00";

        wait;
    end process;

end architecture sim;
