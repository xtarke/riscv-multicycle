library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
generic (
        DADDRESS_OFFSET : integer := 16#10#
);
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

    -- integer DADDRESS_OFFSET : integer := 16#10#;

begin

    -- dcsel <= daddress(26 downto 25);
    dcsel <= std_logic_vector(daddress(24 downto 23));

    dut: entity work.flash_bus
    generic map (
        MY_CHIPSELECT => "11",
        DADDRESS_BUS_SIZE => 32,
        DADDRESS_OFFSET => DADDRESS_OFFSET
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
        wait for 2 us;
        rst <= '0';
        wait;
    end process;

    -- clk
    process
    begin
        clk <= '0';
        wait for 3 us;
        clk <= '1';
        wait for 3 us;
    end process;

    -- write/read
    process
    begin

        wait for 1 us;
        -- read arbitrary flash address to check if it was initialized
        d_we <= '0';
        d_rd <= '1';
        daddress <= to_unsigned(DADDRESS_OFFSET + 123, daddress'length);
        daddress(24 downto 23) <= "11";
        wait for 4 us;
        d_rd <= '0';

        wait for 30 us;

        -- test write value out of boundaries
        ddata_w(7 downto 0) <= "11111111";
        daddress <= to_unsigned(DADDRESS_OFFSET - 1, daddress'length);
        daddress(24 downto 23) <= "11";
        d_we <= '1';
        d_rd <= '0';

        wait for 10 us;

        -- test write value out of boundaries
        -- 16#57FFF# is the end of last sector in flash
        daddress <= to_unsigned(1 + 16#57FFF# + DADDRESS_OFFSET, daddress'length);
        daddress(24 downto 23) <= "11";

        wait for 20 us;

        -- test write and read value within boundaries

        daddress <= to_unsigned(DADDRESS_OFFSET, daddress'length);
        daddress(24 downto 23) <= "11";

        wait for 10 us;

        d_we <= '0';
        d_rd <= '1';

        wait;
    end process;

end architecture rtl;