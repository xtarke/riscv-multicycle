library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity e_testbench is
end entity e_testbench;

architecture rtl of e_testbench is
  -- ---- ---- ---- ---- ---- ---- ---- ----
  -- testbench
  type   steps_reg_axes_t is(off, x_low, x_high, y_low, y_high, z_low, z_high);
  signal machine_slave : steps_reg_axes_t := off;

  -- ---- ---- ---- ---- ---- ---- ---- ----
  -- accelerometer
  signal clk            : std_logic;
  signal rst            : std_logic;
  signal miso           : std_logic;
  signal mosi           : std_logic;
  signal sclk           : std_logic;
  signal ss_n           : std_logic;
  signal axi_x : STD_LOGIC_VECTOR(15 downto 0);
  signal axi_y : STD_LOGIC_VECTOR(15 downto 0);
  signal axi_z : STD_LOGIC_VECTOR(15 downto 0);

  -- ---- ---- ---- ---- ---- ---- ---- ----
  -- spi_salve
  signal rx_req: std_logic;
  signal st_load_en: std_logic;
  signal st_load_trdy: std_logic;
  signal st_load_rrdy: std_logic;
  signal st_load_roe: std_logic;
  signal tx_load_en: std_logic;
  signal tx_load_data: STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal trdy: std_logic;
  signal rrdy: std_logic;
  signal roe: std_logic;
  signal rx_data:  STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal busy: std_logic;
  signal debug: std_logic;

  begin
  -- instatiation: accelerometer
  e_accelerometer : entity work.accelerometer_adxl345
    port map(
      clk     => clk, 
      rst     => rst,
      miso    => miso, 
      sclk    => sclk, 
      ss_n(0) => ss_n, 
      mosi    => mosi, 
      -- axis
      axi_x   => axi_x, 
      axi_y   => axi_y, 
      axi_z   => axi_z
    );

  -- instatiation: spi slave
  e_spi_slave : entity work.spi_slave
    port map(
      -- spi
      rst          => rst,
      miso         => miso,      
      sclk         => sclk,
      ss_n         => ss_n,
      mosi         => mosi,
      -- ...
      rx_req       => rx_req,     -- Solicita os últimos dados recebidos do mestre (o escravo não deve estar ocupado).
      st_load_en   => st_load_en,   -- Ativar carregamento de status. Trava dados nos registradores trdy, rrdy e roe da lógica do usuário (o escravo não deve estar ocupado).
      st_load_trdy => st_load_trdy,   -- O valor trdy que é travado por st_load_en.
      st_load_rrdy => st_load_rrdy,   -- O valor rrdy que é travado por st_load_en.
      st_load_roe  => st_load_roe,  -- O valor do roe que é travado por st_load_en.
      tx_load_en   => tx_load_en,   -- Trava tx_load_data no registrador de transmissão (o escravo não deve estar ocupado).
      tx_load_data => tx_load_data,   -- Os dados devem ser travados no registro de transmissão.
      trdy         => trdy,       -- Transmitir pronto. '1' quando o escravo carregou dados no registrador de transmissão, mas ainda não foi enviado.
      rrdy         => rrdy,       -- Receba pronto. '1' quando o escravo recebeu dados do mestre, mas ainda não foram solicitados.
      roe          => roe,      -- Receber erro de ultrapassagem. '1' quando os dados recebidos do mestre são substituídos por novos dados do mestre antes de serem acessados ​​pela lógica do usuário.
      rx_data      => rx_data,    -- Apresenta os últimos dados recebidos do mestre quando solicitado.
      busy         => busy,       -- '1' durante as transações com o dispositivo mestre, '0' quando disponível para a lógica do usuário

      debug        => debug
    );

  -- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
  -- sequential

  clock : process
  begin
    clk <= '0'; wait for 1 ns;
    clk <= '1'; wait for 1 ns;
  end process;

  reset : process is
  begin
    rst <= '1';
    wait for 5 ns;
    rst <= '0';
    wait;
  end process;

  test  : process
    variable tx_init : std_logic := '1';
    begin

    if tx_init = '1' then
      tx_init := '0';
      machine_slave <= off;
      tx_load_en <= '1';
      rx_req <= '1';
    end if;

    -- start data_frame
    wait until debug = '1';
    for j in 0 to 5 loop
      case( j ) is
        when 0 =>
          machine_slave <= x_low;
          tx_load_data  <= x"01";
        when 1 =>
          machine_slave <= x_high;
          tx_load_data  <= x"00";
        when 2 =>
          machine_slave <= y_low;
          tx_load_data  <= x"02";
        when 3 =>
          machine_slave <= y_high;
          tx_load_data  <= x"00";
        when 4 =>
          machine_slave <= z_low;
          tx_load_data  <= x"03";
        when 5 =>
          machine_slave <= z_high;
          tx_load_data  <= x"00";
        when others =>        
      end case ;
      -- next axe
        -- x-> y
        -- y-> z
      wait until busy = '1';
    end loop; -- end data_frame !

  end process;

end architecture rtl;