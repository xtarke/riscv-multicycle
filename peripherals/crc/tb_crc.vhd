library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end entity testbench;

architecture RTL of testbench is
    signal daddress : unsigned(31 downto 0);
    signal ddata_w  : std_logic_vector(31 downto 0);
    signal ddata_r  : std_logic_vector(31 downto 0);
    signal d_we     : std_logic;
    signal d_rd     : std_logic;
    signal dcsel    : std_logic_vector(1 downto 0);
    signal dmask    : std_logic_vector(3 downto 0);
    signal clk      : std_logic;
    signal rst      : std_logic;
    
    constant MY_WORD_ADDRESS   : unsigned(15 downto 0)        := x"00E0";
begin
    crc : entity work.crc
    	generic map(
	    MY_WORD_ADDRESS => MY_WORD_ADDRESS
	)
        port map(
            clk      => clk,
            rst      => rst,
            daddress => daddress,
            ddata_w  => ddata_w,
            ddata_r  => ddata_r,
            d_we     => d_we,
            d_rd     => d_rd,
            dcsel    => dcsel,
            dmask    => dmask
        );

    process is
        constant PERIOD : time := 4 ns;
    begin
        clk <= '0';
        wait for PERIOD / 2;
        clk <= '1';
        wait for PERIOD / 2;
    end process;

    process is
        type data_array is array (0 to 7) of std_logic_vector(31 downto 0);
        constant data : data_array := (
            x"000000A1",
            x"00000002",
            x"000000F3",
            x"00000034",
            x"00000065",
            x"00000006",
            x"000000B7",
            x"000000C8"
        );
    begin
        dcsel <= "10";
        dmask <= "1111";
        d_we  <= '1';
        d_rd  <= '1';

        rst <= '1';
        wait until falling_edge(clk);
        rst <= '0';

        daddress <= x"0040" & MY_WORD_ADDRESS + 1;
        ddata_w  <= x"FFFFFFFF";
        wait until falling_edge(clk);
        
        
        daddress <= x"0040" & MY_WORD_ADDRESS + 0;
        for i in data'range loop
            ddata_w <= data(i);
            wait until falling_edge(clk);
        end loop;
        
        d_we     <= '0';
        d_rd     <= '1';
        wait;
    end process;

end architecture RTL;
