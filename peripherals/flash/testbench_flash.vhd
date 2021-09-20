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

    signal waitrequest : std_logic;
    signal csr_readdata : std_logic_vector(31 downto 0);

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
        dmask => dmask,
        waitrequest => waitrequest
    );

    -- rst
    process
    begin
        rst <= '1';
        wait for 100 us;
        rst <= '0';
        wait;
    end process;

    -- clk
    process
    begin
        clk <= '0';
        wait for 50 us;
        clk <= '1';
        wait for 50 us;
    end process;

    -- write/read
    process
    begin
        wait for 230 us;
        daddress <= (others => '0');
        -- ddata_w(2) <= '1';
        -- ddata_w(3) <= '1';
        -- d_we <= '1';
        -- wait for 11 ms;
        d_rd <= '1';
        wait for 110 us;
        d_rd <= '0';
        wait;
        -- assert waitrequest = '0';

    end process;

end architecture rtl;
