-- source: https://www.digikey.com/eewiki/download/attachments/7569477/spi_slave.vhd?version=7&modificationDate=1557248563824&api=v2
-- format beautify: https://g2384.github.io/work/VHDLformatter.html

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity spi_slave is
  generic (
    l_cpol    : STD_LOGIC := '1'; --spi clock polarity mode
    l_cpha    : STD_LOGIC := '1'; --spi clock phase mode
    d_width   : integer   :=  8; --data width in bits
    n_slaves  : integer   :=  1 --number of spi slaves
  );
  port (
    
    rst          : in STD_LOGIC; --active low reset
    miso         : out STD_LOGIC;
    sclk         : in STD_LOGIC; --spi clk from master
    ss_n         : in STD_LOGIC; --active low slave select
    mosi         : in STD_LOGIC; --master out, slave in
    --
    rx_req       : in STD_LOGIC; --'1' while busy = '0' moves data to the rx_data output
    st_load_en   : in STD_LOGIC; --asynchronous load enable
    st_load_trdy : in STD_LOGIC; --asynchronous trdy load input
    st_load_rrdy : in STD_LOGIC; --asynchronous rrdy load input
    st_load_roe  : in STD_LOGIC; --asynchronous roe load input
    tx_load_en   : in STD_LOGIC; --asynchronous transmit buffer load enable
    tx_load_data : in STD_LOGIC_VECTOR(d_width - 1 downto 0); --asynchronous tx data to load
    trdy         : buffer STD_LOGIC := '0'; --transmit ready bit
    rrdy         : buffer STD_LOGIC := '0'; --receive ready bit
    roe          : buffer STD_LOGIC := '0'; --receive overrun error bit
    rx_data      : out STD_LOGIC_VECTOR(d_width - 1 downto 0) := (others => '0'); --receive register output to logic
    busy         : out STD_LOGIC := '0'; --busy signal to logic ('1' during transaction)
    
    debug        : out std_logic
  ); --master in, slave out
  end spi_slave;

  architecture logic of spi_slave is
    signal mode    : STD_LOGIC; --groups modes by clock polarity relation to data
    signal clk     : STD_LOGIC; --clock
    signal bit_cnt : STD_LOGIC_VECTOR(d_width + 8 downto 0); --'1' for active transaction bit
    signal wr_add  : STD_LOGIC; --address of register to write ('0' = receive, '1' = status)
    signal rd_add  : STD_LOGIC; --address of register to read ('0' = transmit, '1' = status)
    signal rx_buf  : STD_LOGIC_VECTOR(d_width - 1 downto 0) := (others => '0'); --receiver buffer
    signal tx_buf  : STD_LOGIC_VECTOR(d_width - 1 downto 0) := (others => '0'); --transmit buffer
  begin
    busy <= not ss_n; --high during transactions
 
    --adjust clock so writes are on rising edge and reads on falling edge
    mode <= l_cpol xor l_cpha; --'1' for modes that write on rising edge
    with mode select
    clk <= sclk when '1', 
           not sclk when others;

    --keep track of miso/mosi bit counts for data alignmnet
    process (ss_n, clk)
    begin
      if (ss_n = '1' or rst = '1') then --this slave is not selected or being reset
        bit_cnt <= (conv_integer(not l_cpha) => '1', others => '0'); --reset miso/mosi bit count
      else --this slave is selected
        if (rising_edge(clk)) then --new bit on miso/mosi
          bit_cnt <= bit_cnt(d_width + 8 - 1 downto 0) & '0'; --shift active bit indicator
        end if;
      end if;
    end process;

    process (ss_n, clk, st_load_en, tx_load_en, rx_req)
      begin
        --write address register ('0' for receive, '1' for status)
        if (bit_cnt(1) = '1' and falling_edge(clk)) then
          wr_add <= mosi;
        end if;

        --read address register ('0' for transmit, '1' for status)
        if (bit_cnt(2) = '1' and falling_edge(clk)) then
          rd_add <= mosi;
          debug  <= mosi;
        end if;
 
        --trdy register
        if ((ss_n = '1' and st_load_en = '1' and st_load_trdy = '0') or rst = '1') then 
          trdy <= '0'; --cleared by user logic or reset
        elsif (ss_n = '1' and ((st_load_en = '1' and st_load_trdy = '1') or tx_load_en = '1')) then
          trdy <= '1'; --set when tx buffer written or set by user logic
        elsif (falling_edge(clk)) then
          if (wr_add = '1' and bit_cnt(9) = '1') then
            trdy <= mosi; --new value written over spi bus
          elsif (rd_add = '0' and bit_cnt(d_width + 8) = '1') then
            trdy <= '0'; --clear when transmit buffer read
          end if;
        end if;
 
        --rrdy register
        if ((ss_n = '1' and ((st_load_en = '1' and st_load_rrdy = '0') or rx_req = '1')) or rst = '1') then
          rrdy <= '0'; --cleared by user logic or rx_data has been requested or reset
        elsif (ss_n = '1' and st_load_en = '1' and st_load_rrdy = '1') then
          rrdy <= '1'; --set when set by user logic
        elsif (falling_edge(clk)) then
          if (wr_add = '1' and bit_cnt(10) = '1') then
            rrdy <= mosi; --new value written over spi bus
          elsif (wr_add = '0' and bit_cnt(d_width + 8) = '1') then
            rrdy <= '1'; --set when new data received
          end if;
        end if;
 
        --roe register
        if ((ss_n = '1' and st_load_en = '1' and st_load_roe = '0') or rst = '1') then
          roe <= '0'; --cleared by user logic or reset
        elsif (ss_n = '1' and st_load_en = '1' and st_load_roe = '1') then
          roe <= '1'; --set by user logic
        elsif (falling_edge(clk)) then
          if (rrdy = '1' and wr_add = '0' and bit_cnt(d_width + 8) = '1') then
            roe <= '1'; --set by actual overrun
          elsif (wr_add = '1' and bit_cnt(11) = '1') then
            roe <= mosi; --new value written by spi bus
          end if;
        end if;
 
        --receive registers
        --write to the receive register from master
        if (rst = '1') then
          rx_buf <= (others => '0');
        else
          for i in 0 to d_width - 1 loop 
            if (wr_add = '0' and bit_cnt(i + 9) = '1' and falling_edge(clk)) then
              rx_buf(d_width - 1 - i) <= mosi;
            end if;
          end loop;
        end if;

        --fulfill user logic request for receive data
        if (rst = '1') then
          rx_data <= (others => '0');
        elsif (ss_n = '1' and rx_req = '1') then 
          rx_data <= rx_buf;
        end if;

        --transmit registers
        if (rst = '1') then
          tx_buf <= (others => '0');
        elsif (ss_n = '1' and tx_load_en = '1') then --load transmit register from user logic
          tx_buf <= tx_load_data;
        elsif ( bit_cnt(d_width) = '0' and rising_edge(clk)) then
          tx_buf(d_width - 1 downto 0) <= tx_buf(d_width - 2 downto 0) & tx_buf(d_width - 1); --shift through tx data
        end if;

        --miso output register
        if (ss_n = '1' or rst = '1') then --no transaction occuring or reset
          miso <= 'Z';
        ELSIF(rising_edge(clk)) THEN
            miso <= tx_buf(d_width-1);                  --send transmit register data to master
        END IF;
 
      end process;
end logic;