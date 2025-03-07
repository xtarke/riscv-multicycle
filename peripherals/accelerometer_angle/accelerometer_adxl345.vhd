-- source: https://www.digikey.com/eewiki/download/attachments/90243412/pmod_accelerometer_adxl345.vhd?version=1&modificationDate=1568909638756&api=v2
-- format beautify: https://g2384.github.io/work/VHDLformatter.html

library ieee;
use ieee.std_logic_1164.all;

entity accelerometer_adxl345 is
  port (
    clk            : in STD_LOGIC; --system clock
    rst            : in STD_LOGIC; --active low asynchronous reset
    miso           : in STD_LOGIC; --SPI bus: master in, slave out
    sclk           : buffer STD_LOGIC; --SPI bus: serial clock
    ss_n           : buffer STD_LOGIC_VECTOR(0 downto 0); --SPI bus: slave select
    mosi           : out STD_LOGIC; --SPI bus: master out, slave in
    --
    axi_x : out STD_LOGIC_VECTOR(15 downto 0);  --x-axis acceleration data
    axi_y : out STD_LOGIC_VECTOR(15 downto 0);  --y-axis acceleration data
    axi_z : out STD_LOGIC_VECTOR(15 downto 0)); --z-axis acceleration data
end accelerometer_adxl345;

architecture behavior of accelerometer_adxl345 is

  constant clk_freq   : INTEGER := 50;                --system clock frequency in MHz
  constant data_rate  : STD_LOGIC_VECTOR := "0100";   --data rate code to configure the accelerometer
  constant data_range : STD_LOGIC_VECTOR := "00";     --data range code to configure the accelerometer

  type machine is(start, pause, configure, read_data, output_result); --needed states
  signal state              : machine := start; --state machine
  signal parameter_a        : integer range 0 to 3; --parameter being configured
  signal parameter_addr     : STD_LOGIC_VECTOR(5 downto 0); --register address of configuration parameter
  signal parameter_data     : STD_LOGIC_VECTOR(3 downto 0); --value of configuration parameter
  signal spi_busy_prev      : STD_LOGIC; --previous value of the SPI component's busy signal
  signal spi_busy           : STD_LOGIC; --busy signal from SPI component
  signal spi_ena            : STD_LOGIC; --enable for SPI component
  signal spi_cont           : STD_LOGIC; --continuous mode signal for SPI component
  signal spi_tx_data        : STD_LOGIC_VECTOR(7 downto 0); --transmit data for SPI component
  signal spi_rx_data        : STD_LOGIC_VECTOR(7 downto 0); --received data from SPI component
  signal axi_x_int : STD_LOGIC_VECTOR(15 downto 0); --internal x-axis acceleration data buffer
  signal axi_y_int : STD_LOGIC_VECTOR(15 downto 0); --internal y-axis acceleration data buffer
  signal axi_z_int : STD_LOGIC_VECTOR(15 downto 0); --internal z-axis acceleration data buffer

  begin

  -- instatiation: spi master
  e_spi_master : entity work.spi_master
    port map(
      clock   => clk,
      rst     => rst,
      enable  => spi_ena,
      cont    => spi_cont,
      clk_div => clk_freq/10,
      addr    => 0,
      tx_data => spi_tx_data,
      miso    => miso,
      sclk    => sclk,
      ss_n    => ss_n,
      mosi    => mosi,
      busy    => spi_busy,
      rx_data => spi_rx_data
    );

  -- logic adxl345
  process (clk, rst)
    variable count : integer := 0; --universal counter
    begin
    if (rst = '1') then --reset activated
      spi_ena        <= '0'; --clear SPI component enable
      spi_cont       <= '0'; --clear SPI component continuous mode signal
      spi_tx_data    <= (others => '0'); --clear SPI component transmit data
      axi_x <= (others => '0'); --clear x-axis acceleration data
      axi_y <= (others => '0'); --clear y-axis acceleration data
      axi_z <= (others => '0'); --clear z-axis acceleration data
      state          <= start; --restart state machine
    elsif (clk'EVENT and clk = '1') then --rising edge of system clock
      case state is --state machine

        --entry state
        when start => 
          count       := 0; --clear universal counter
          parameter_a <= 0; --clear parameter indicator
          state       <= pause;
 
          --pauses 200ns between SPI transactions and selects SPI transaction
        when pause => 
          if (spi_busy = '0') then --SPI component not busy
            if (count < clk_freq/5) then --less than 200ns
              count := count + 1; --increment counter
              state <= pause; --remain in pause state
            else --200ns has elapsed
              count := 0; --clear counter
              case parameter_a is --select SPI transaction
                when 0 => --SPI transaction to set range
                  parameter_a    <= parameter_a + 1; --increment parameter for next transaction
                  parameter_addr <= "110001"; --register address with range setting
                  parameter_data <= "10" & data_range; --data to set specified range
                  state          <= configure; --proceed to SPI transaction
                when 1 => --SPI transaction to set data rate
                  parameter_a      <= parameter_a + 1; --increment parameter for next transaction
                  parameter_addr <= "101100"; --register address with data rate setting
                  parameter_data <= data_rate; --code to set specified data rate
                  state          <= configure; --proceed to SPI transaction
                when 2 => --SPI transaction to enable measuring
                  parameter_a      <= parameter_a + 1; --increment parameter for next transaction
                  parameter_addr <= "101101"; --register address with enable measurement setting
                  parameter_data <= "1000"; --data to enable measurement
                  state          <= configure; --proceed to SPI transaction
                when 3 => --SPI transaction to read data
                  state <= read_data; --proceed to SPI transaction
                when others => null;
              end case; 
            end if;
          end if;

          --performs SPI transactions that write to configuration registers 
        when configure => 
          spi_busy_prev <= spi_busy; --capture the value of the previous spi busy signal
          if (spi_busy_prev = '1' and spi_busy = '0') then --spi busy just went low
            count := count + 1; --counts times busy goes from high to low during transaction
          end if;
          case count is --number of times busy has gone from high to low
            when 0 => --no busy deassertions
              if (spi_busy = '0') then --transaction not started
                
                -- 0: yes read in config.
                -- 1: not read in config.
                -- rx_req <= not spi_cont
                spi_cont    <= '1'; --set to continuous mode
                spi_ena     <= '1'; --enable SPI transaction
                spi_tx_data <= "00" & parameter_addr; --first information to send
              else --transaction has started
                spi_tx_data <= "0000" & parameter_data; --second information to send (first has been latched in)
              end if;
            when 1 => --first busy deassertion
              spi_cont <= '0'; --clear continous mode to end transaction
              spi_ena  <= '0'; --clear SPI transaction enable
              count := 0; --clear universal counter
              state <= pause; --return to pause state
            when others => null;
        end case;

        --performs SPI transactions that read acceleration data registers 
        when read_data => 
          spi_busy_prev <= spi_busy; --capture the value of the previous spi busy signal
          if (spi_busy_prev = '1' and spi_busy = '0') then --spi busy just went low
            count := count + 1; --counts the times busy goes from high to low during transaction
          end if; 
          case count is --number of times busy has gone from high to low
            when 0 => --no busy deassertions
              if (spi_busy = '0') then --transaction not started
                -- continuos yes, ss_n continuos
                -- continuos not, ss_n pulse
                spi_cont    <= '1'; --set SPI continuous mode 
                spi_ena     <= '1'; --enable SPI transaction
                spi_tx_data <= "11110010"; --first information to send
              else --transaction has started
                spi_tx_data <= "00000000"; --second information to send (first has been latched in) 
              end if;
            when 2 => --2nd busy deassertion
              axi_x_int(7 downto 0) <= spi_rx_data; --latch in first received acceleration data
            when 3 => --3rd busy deassertion
              axi_x_int(15 downto 8) <= spi_rx_data; --latch in second received acceleration data
            when 4 => --4th busy deassertion
              axi_y_int(7 downto 0) <= spi_rx_data; --latch in third received acceleration data
            when 5 => --5th busy deassertion
              axi_y_int(15 downto 8) <= spi_rx_data; --latch in fourth received acceleration data
            when 6 => --6th busy deassertion
              spi_cont                       <= '0'; --clear continuous mode to end transaction
              spi_ena                        <= '0'; --clear SPI transaction enable
              axi_z_int(7 downto 0) <= spi_rx_data; --latch in fifth received acceleration data
            when 7 => --7th busy deassertion
              axi_z_int(15 downto 8) <= spi_rx_data; --latch in sixth received acceleration data
              count := 0; --clear universal counter
              state <= output_result; --proceed to output result state
            when others => null;
        end case;
 
        --outputs acceleration data
        when output_result => 
          axi_x <= axi_x_int; --output x-axis data
          axi_y <= axi_y_int; --output y-axis data
          axi_z <= axi_z_int; --output z-axis data
          state          <= pause; --return to pause state
      end case; 
    end if;
  end process;

end behavior;