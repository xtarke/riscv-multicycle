library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity display_7seg is
    generic(
        MY_CHIPSELECT   : std_logic_vector(1 downto 0) := "10"; --! Chip select of this device
        MY_WORD_ADDRESS : unsigned(15 downto 0)        := x"01B0" --! Base address of this device
    );
    port(
        clk      : in  std_logic;
        rst      : in  std_logic;
        
        -- Core data bus signals
        daddress : in  unsigned(31 downto 0);
        ddata_w  : in  std_logic_vector(31 downto 0);
        d_we     : in  std_logic;
        dcsel    : in  std_logic_vector(1 downto 0); 
        
        -- DE10-Lite 7-Segment Displays (Active Low)
        HEX0 : out std_logic_vector(7 downto 0);
        HEX1 : out std_logic_vector(7 downto 0);
        HEX2 : out std_logic_vector(7 downto 0);
        HEX3 : out std_logic_vector(7 downto 0);
        HEX4 : out std_logic_vector(7 downto 0);
        HEX5 : out std_logic_vector(7 downto 0)
    );
end entity display_7seg;

architecture RTL of display_7seg is
    signal display_reg : std_logic_vector(31 downto 0);
    
    -- Helper function to decode a 4-bit nibble into a 7-segment active-low output
    function decode_7seg(nibble : std_logic_vector(3 downto 0)) return std_logic_vector is
        variable seg : std_logic_vector(7 downto 0);
    begin
        -- DE10-Lite 7seg is active low. Bit order: DP G F E D C B A
        case nibble is
            when "0000" => seg := "11000000"; -- 0
            when "0001" => seg := "11111001"; -- 1
            when "0010" => seg := "10100100"; -- 2
            when "0011" => seg := "10110000"; -- 3
            when "0100" => seg := "10011001"; -- 4
            when "0101" => seg := "10010010"; -- 5
            when "0110" => seg := "10000010"; -- 6
            when "0111" => seg := "11111000"; -- 7
            when "1000" => seg := "10000000"; -- 8
            when "1001" => seg := "10010000"; -- 9
            when others => seg := "11111111"; -- Off / Blank
        end case;
        return seg;
    end function;

begin

    -- Bus Write Interface
    process(clk, rst)
    begin
        if rst = '1' then
            display_reg <= (others => '0');
        elsif rising_edge(clk) then
            if (d_we = '1') and (dcsel = MY_CHIPSELECT) then
                -- Offset 0: Write packed BCD value for all 6 displays
                if daddress(15 downto 0) = MY_WORD_ADDRESS then
                    display_reg <= ddata_w;
                end if;
            end if;
        end if;
    end process;

    -- Decode and assign to outputs
    HEX0 <= decode_7seg(display_reg(3 downto 0));
    HEX1 <= decode_7seg(display_reg(7 downto 4));
    HEX2 <= decode_7seg(display_reg(11 downto 8));
    HEX3 <= decode_7seg(display_reg(15 downto 12));
    HEX4 <= decode_7seg(display_reg(19 downto 16));
    HEX5 <= decode_7seg(display_reg(23 downto 20));

end architecture RTL;
