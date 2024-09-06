-------------------------------------------------------------------
-- Name        : simple_serial_transmitter.vhd                   --
-- Author      : Gabriel Romero e Yuri Marques                   --
-- Description : Simple Serial Transmitter                       --
-------------------------------------------------------------------

--! Use standard library
library ieee;
--! Use standard logic elements
use ieee.std_logic_1164.all;
--! Use conversion functions
use ieee.numeric_std.all;

entity simple_serial_transmitter is
    generic (
        --! Chip selec
        MY_CHIPSELECT : std_logic_vector(1 downto 0) := "10";   --! Chip select of this device
        MY_WORD_ADDRESS : unsigned(15 downto 0) := x"0130";     --! Address of this device
        DADDRESS_BUS_SIZE : integer := 32                       --! Data bus size
    );
    port
(
        clk : in std_logic;
        rst : in std_logic;

        -- Core data bus signals
        -- ToDo: daddress shoud be unsgined
        daddress  : in  unsigned(DADDRESS_BUS_SIZE-1 downto 0);
        ddata_w   : in  std_logic_vector(31 downto 0);
        ddata_r   : out std_logic_vector(31 downto 0);
        d_we      : in std_logic;
        d_rd      : in std_logic;
        dcsel     : in std_logic_vector(1 downto 0);    --! Chip select 
        -- ToDo: Module should mask bytes (Word, half word and byte access)
        dmask     : in std_logic_vector(3 downto 0);    --! Byte enable mask

        -- hardware input/output signals
        sdata     : out std_logic
    );
end entity simple_serial_transmitter;

architecture rtl of Simple_Serial_Transmitter is

    type state_type is (IDLE, ADDR_TR, DATA_TR, DONE);
    signal state                : state_type := IDLE;
    signal start_w              : std_logic; 
    signal addr_w               : std_logic_vector(7 downto 0);
    signal data_w               : std_logic_vector(7 downto 0);
    signal databit_transmission : unsigned(0 to 7);
    signal sregister            : std_logic_vector(15 downto 0) := (others => '0');

begin

    process(clk, rst)
    begin
        if rst = '1' then
            start_w <= '0';
            addr_w <= (others => '0');
            data_w <= (others => '0');
        elsif rising_edge(clk) then
            if (d_we = '1') and (dcsel = MY_CHIPSELECT) then
                if daddress(15 downto 0) = (MY_WORD_ADDRESS + x"0000") then -- addr
                    addr_w <= ddata_w(7 downto 0);
                elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + x"0001") then -- data
                    data_w <= ddata_w(7 downto 0);
                elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + x"0002") then -- start
                    start_w <= ddata_w(0);
                end if;
            end if;
        end if;
    end process;
    
    
    process(clk, rst)
    begin
        if rst = '1' then
            databit_transmission <= (others => '0');
            state <= IDLE;
        else
            if rising_edge(clk) then
                case state is
                    when IDLE =>
                        databit_transmission <= (others => '0');
                        if start_w = '1' then
                            state <= ADDR_TR;
                        end if;
                    when ADDR_TR =>
                        if databit_transmission = 7 then
                            databit_transmission <= (others => '0');
                            state <= DATA_TR;
                        else
                            databit_transmission <= databit_transmission + 1;
                        end if;
                    when DATA_TR =>
                        if databit_transmission = 7 then
                            state <= DONE;
                        else
                            databit_transmission <= databit_transmission + 1;
                        end if;
                    when DONE =>
                        if start_w = '0' then
                            state <= IDLE;
                        end if;
                    end case;
                end if;
            end if;
    end process;

    process(state, start_w, databit_transmission)
        constant NO_TRANSMISSION : std_logic := '1';
    begin

        sdata <= NO_TRANSMISSION; -- no transmission: sdata = 1;

        case state is
            when IDLE =>
                if start_w = '1' then
                    sregister <= addr_w & data_w;  
                    sdata <= '0'; -- send start bit = 0;
                end if;
            when ADDR_TR =>
                sdata <= sregister(15 - To_integer(databit_transmission));
            when DATA_TR =>
                sdata <= sregister(7 - To_integer(databit_transmission));
            when DONE =>
        end case;
    end process;

end architecture rtl;
