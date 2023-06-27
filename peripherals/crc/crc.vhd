library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity crc is
    generic(
        --! Chip selec
        MY_CHIPSELECT     : std_logic_vector(1 downto 0) := "10";
        MY_WORD_ADDRESS   : unsigned(15 downto 0)        := x"00F0";
        DADDRESS_BUS_SIZE : integer                      := 32
    );
    port(
        clk      : in  std_logic;
        rst      : in  std_logic;
        -- core data bus signals
        daddress : in  unsigned(DADDRESS_BUS_SIZE - 1 downto 0); --! Data address
        ddata_w  : in  std_logic_vector(31 downto 0); --! Data to memory bus
        ddata_r  : out std_logic_vector(31 downto 0); --! Data from memory bus
        d_we     : in  std_logic;       --! Write Enable
        d_rd     : in  std_logic;       --! Read enable
        dcsel    : in  std_logic_vector(1 downto 0); --! Chip select
        dmask    : in  std_logic_vector(3 downto 0) --! Byte enable mask
    );
end entity crc;

architecture RTL of crc is
    signal data_reg  : std_logic_vector(15 downto 0); -- MY_WORD_ADDRESS + 0
    signal data_init : std_logic_vector(15 downto 0); -- MY_WORD_ADDRESS + 4

begin

    p_in : process(clk, rst) is
        variable next_crc : std_logic_vector(15 downto 0);
    begin
        if rst = '1' then
            data_reg  <= (others => '0');
            data_init <= (others => '0');
        elsif rising_edge(clk) and (dcsel = MY_CHIPSELECT) and (d_we = '1') then
             -- escrita em data_reg
            if daddress(15 downto 0) = MY_WORD_ADDRESS + 0 then
                -- Lógica principal de CRC
                next_crc := data_reg xor ddata_w(15 downto 0);
                for bit in next_crc(7 downto 0)'range loop
                    if next_crc(0) = '1' then
                        next_crc := '0' & next_crc(15 downto 1);
                        next_crc := next_crc xor x"A001";
                    else
                        next_crc := '0' & next_crc(15 downto 1);
                    end if;
                end loop;
                data_reg <= next_crc;
            -- escrita em data_init
            elsif daddress(15 downto 0) = MY_WORD_ADDRESS + 1 then 
                data_reg  <= ddata_w(15 downto 0);
                data_init <= ddata_w(15 downto 0);
            end if;
        end if;
    end process;

    p_out : process(clk, rst) is
    begin
        if rst = '1' then
            ddata_r <= (others => '0');
        elsif rising_edge(clk) and (dcsel = MY_CHIPSELECT) and (d_rd = '1') then
            if daddress(15 downto 0) = MY_WORD_ADDRESS + 0 then -- leitura de data_reg
                ddata_r(15 downto 0)  <= data_reg;
                ddata_r(31 downto 16) <= (others => '0');
            elsif daddress(15 downto 0) = MY_WORD_ADDRESS + 1 then -- leitura de data_init
                ddata_r(15 downto 0)  <= data_init;
                ddata_r(31 downto 16) <= (others => '0');
            end if;
        end if;
    end process;

end architecture RTL;
