-- source: https://www.digikey.com/eewiki/download/attachments/4096096/spi_master.vhd?version=2&modificationDate=1365698337120&api=v2
-- format beautify: https://g2384.github.io/work/VHDLformatter.html

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity spi_master is
  port (
    clock   : in STD_LOGIC; --system clock
    rst     : in STD_LOGIC; --asynchronous reset
    enable  : in STD_LOGIC; --initiate transaction
    cont    : in STD_LOGIC; --continuous mode command
    clk_div : in integer; --system clock cycles per 1/2 period of sclk
    addr    : in integer; --address of slave
    tx_data : in STD_LOGIC_VECTOR(7 downto 0); --data to transmit
    miso    : in STD_LOGIC; --master in, slave out
    sclk    : buffer STD_LOGIC; --spi clock
    ss_n    : buffer STD_LOGIC_VECTOR(0 downto 0); --slave select
    mosi    : out STD_LOGIC; --master out, slave in
    busy    : out STD_LOGIC; --busy / data ready signal
    rx_data : out STD_LOGIC_VECTOR(7 downto 0)  --data received
  );
end spi_master;

architecture logic of spi_master is

	constant cpol      : STD_LOGIC := '1'; --spi clock polarity mode
	constant cpha      : STD_LOGIC := '1'; --spi clock phase mode
	constant d_width   : integer   :=  8;  --data bus width
	constant n_slaves  : integer   :=  1; --number of spi slaves

  type machine is(ready, execute); --state machine data type
  signal state       : machine; --current state
  signal slave       : integer; --slave selected for current transaction
  signal clk_ratio   : integer; --current clk_div
  signal count       : integer; --counter to trigger sclk from system clock
  signal clk_toggles : integer range 0 to d_width * 2 + 1; --count spi clock toggles
  signal assert_data : STD_LOGIC; --'1' is tx sclk toggle, '0' is rx sclk toggle
  signal continue    : STD_LOGIC; --flag to continue transaction
  signal rx_buffer   : STD_LOGIC_VECTOR(d_width - 1 downto 0); --receive data buffer
  signal tx_buffer   : STD_LOGIC_VECTOR(d_width - 1 downto 0); --transmit data buffer
  signal last_bit_rx : integer range 0 to d_width * 2; --last rx data bit location
begin
  process (clock, rst)
  begin
    if (rst = '1') then --reset system
      busy    <= '1'; --set busy signal
      ss_n    <= (others => '1'); --deassert all slave select lines
      mosi    <= 'Z'; --set master out to high impedance
      rx_data <= (others => '0'); --clear receive data port
      state   <= ready; --go to ready state when reset is exited

    elsif (clock'EVENT and clock = '1') then
      case state is --state machine

        when ready => 
          busy     <= '0'; --clock out not busy signal
          ss_n     <= (others => '1'); --set all slave select outputs high
          mosi     <= 'Z'; --set mosi output high impedance
          continue <= '0'; --clear continue flag

          --user input to initiate transaction
          if (enable = '1') then 
            busy <= '1'; --set busy signal
            if (addr < n_slaves) then --check for valid slave address
              slave <= addr; --clock in current slave selection if valid
            else
              slave <= 0; --set to first slave if not valid
            end if;
            if (clk_div = 0) then --check for valid spi speed
              clk_ratio <= 1; --set to maximum speed if zero
              count     <= 1; --initiate system-to-spi clock counter
            else
              clk_ratio <= clk_div; --set to input selection if valid
              count     <= clk_div; --initiate system-to-spi clock counter
            end if;
            sclk        <= cpol; --set spi clock polarity
            assert_data <= not cpha; --set spi clock phase
            tx_buffer   <= tx_data; --clock in data for transmit into buffer
            clk_toggles <= 0; --initiate clock toggle counter
            last_bit_rx <= d_width * 2 + conv_integer(cpha) - 1; --set last rx data bit
            state       <= execute; --proceed to execute state
          else
            state <= ready; --remain in ready state
          end if;

        when execute => 
          busy        <= '1'; --set busy signal
          ss_n(slave) <= '0'; --set proper slave select output
 
          --system clock to sclk ratio is met
          if (count = clk_ratio) then 
            count       <= 1; --reset system-to-spi clock counter
            assert_data <= not assert_data; --switch transmit/receive indicator
            if (clk_toggles = d_width * 2 + 1) then
              clk_toggles <= 0; --reset spi clock toggles counter
            else
              clk_toggles <= clk_toggles + 1; --increment spi clock toggles counter
            end if;
 
            --spi clock toggle needed
            if (clk_toggles <= d_width * 2 and ss_n(slave) = '0') then
              sclk            <= not sclk; --toggle spi clock
            end if;
 
            --receive spi clock toggle
            if (assert_data = '0' and clk_toggles < last_bit_rx + 1 and ss_n(slave) = '0') then
              rx_buffer <= rx_buffer(d_width - 2 downto 0) & miso; --shift in received bit
            end if;
 
            --transmit spi clock toggle
            if (assert_data = '1' and clk_toggles < last_bit_rx) then
              mosi      <= tx_buffer(d_width - 1); --clock out data bit
              tx_buffer <= tx_buffer(d_width - 2 downto 0) & '0'; --shift data transmit buffer
            end if;
 
            --last data receive, but continue
            if (clk_toggles = last_bit_rx and cont = '1') then
              tx_buffer   <= tx_data; --reload transmit buffer
              clk_toggles <= last_bit_rx - d_width * 2 + 1; --reset spi clock toggle counter
              continue    <= '1'; --set continue flag
            end if;
 
            --normal end of transaction, but continue
            if (continue = '1') then 
              continue <= '0'; --clear continue flag
              busy     <= '0'; --clock out signal that first receive data is ready
              rx_data  <= rx_buffer; --clock out received data to output port 
            end if;
 
            --end of transaction
            if ((clk_toggles = d_width * 2 + 1) and cont = '0') then 
              busy    <= '0'; --clock out not busy signal
              ss_n    <= (others => '1'); --set all slave selects high
              mosi    <= 'Z'; --set mosi output high impedance
              rx_data <= rx_buffer; --clock out received data to output port
              state   <= ready; --return to ready state
            else --not end of transaction
              state <= execute; --remain in execute state
            end if;
 
          else --system clock to sclk ratio not met
            count <= count + 1; --increment counter
            state <= execute; --remain in execute state
          end if;

      end case;
    end if;
  end process;
end logic;