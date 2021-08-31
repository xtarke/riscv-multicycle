library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end entity testbench;

architecture rtl of testbench is

    signal clk, rst : std_logic;
    signal dout : std_logic_vector(6 downto 0);

    -- core data bus signals
    signal daddress  : unsigned(31 downto 0) := (others => '0');
    signal ddata_w   : std_logic_vector(31 downto 0) := (others => '0');
    signal ddata_r	 : std_logic_vector(31 downto 0) := (others => '0');
    signal d_we      : std_logic := '0';
    signal d_rd	     : std_logic := '0';
    signal dcsel	 : std_logic_vector(1 downto 0) := (others => '0');
    signal dmask     : std_logic_vector(3 downto 0) := (others => '0');	 

begin

    dut: entity work.flash_bus
    generic map (
        MY_CHIPSELECT => "00",
        DADDRESS_BUS_SIZE => 32,
        DADDRESS_OFFSET => 0
    )
    port map (
        clk => clk,
        rst => rst,

        -- core data bus signals
        daddress => daddress,
        ddata_w => ddata_w,
        ddata_r => ddata_r,
        d_we => d_we,
        d_rd => d_rd,
        dcsel => dcsel,
        dmask => dmask
    );

    -- rst
    process
    begin
        rst <= '1';
        wait for 1 ms;
        rst <= '0';
        wait;
    end process;

    -- clk
    process
    begin
        clk <= '0';
        wait for 500 us;
        clk <= '1';
        wait for 500 us;
    end process;

    -- write/read
    process
    begin
        wait for 9 ms;
        daddress(1) <= '1';
        ddata_w(2) <= '1';
        ddata_w(3) <= '1';
        -- d_we <= '1';
        wait for 11 ms;
        d_rd <= '1';
        wait for 1 ms;
        d_rd <= '0';
        wait;

    end process;

end architecture rtl;