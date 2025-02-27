-- format beautify: https://g2384.github.io/work/VHDLformatter.html
-- accel_bus: without spi slave, input values get GSENSOR de10_lite
-- accel_bus_tb (testbench) : with spi slave for input values test

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity accel_bus is
  generic (
    -- chip select
    MY_CHIPSELECT   : std_logic_vector(1 downto 0) := "10"; -- Input/Output generic address space
    MY_WORD_ADDRESS : unsigned(15 downto 0) := x"0120" -- 
  );
  port (
    -- core data bus signals
    daddress : in unsigned(31 downto 0);
    ddata_w  : in  std_logic_vector(31 downto 0);
    ddata_r  : out std_logic_vector(31 downto 0);
    d_we     : in std_logic;
    d_rd     : in std_logic;
    dcsel    : in std_logic_vector(1 downto 0);
    dmask    : in std_logic_vector(3 downto 0);
    -- accelerometer
    clk   : in STD_LOGIC; -- system clock
    rst   : in STD_LOGIC; -- active low asynchronous reset
    miso  : in STD_LOGIC; -- SPI bus: master in, slave out    
	sclk  : buffer STD_LOGIC; -- SPI bus: serial clock    
	ss_n  : buffer STD_LOGIC_VECTOR(0 downto 0); -- SPI bus: slave select	 
    mosi  : out STD_LOGIC; -- SPI bus: master out, slave in
	 -- axis
    axi_x : buffer STD_LOGIC_VECTOR(15 downto 0); -- x_axis acceleration data
    axi_y : buffer STD_LOGIC_VECTOR(15 downto 0); -- y_axis acceleration data
    axi_z : buffer STD_LOGIC_VECTOR(15 downto 0)  -- z_axis acceleration data
    --axi_x_max : buffer STD_LOGIC_VECTOR(15 downto 0); -- x_axis acceleration data
    --axi_y_max : buffer STD_LOGIC_VECTOR(15 downto 0); -- y_axis acceleration data
    --axi_z_max : buffer STD_LOGIC_VECTOR(15 downto 0)  -- z_axis acceleration data
  );
end accel_bus;

architecture rtl of accel_bus is
	 
  signal s_axi_x_max : STD_LOGIC_VECTOR(15 DOWNTO 0);
  signal s_axi_y_max : STD_LOGIC_VECTOR(15 DOWNTO 0);
  signal s_axi_z_max : STD_LOGIC_VECTOR(15 DOWNTO 0);

  begin

  -- instatiation: accelerometer
  e_accelerometer : entity work.accelerometer_adxl345
    port map(
      clk     => clk, 
      rst     => rst,
      miso    => miso, 
      sclk    => sclk, 
      ss_n(0) => ss_n(0), 
      mosi    => mosi,
		-- axis
      axi_x => axi_x, 
      axi_y => axi_y, 
      axi_z => axi_z
    );

  -- insert the values ​​on the core bus
  process (clk, rst)
    begin
    if rst = '1' then
      ddata_r <= (others => '0');
    else		
      if rising_edge(clk) then
			if (d_rd = '1') and (dcsel = MY_CHIPSELECT) then
        -- #define ACCELEROMETER_BASE_ADDRESS (*(_IO32 *) (PERIPH_BASE + 18*16*4))
        -- 18*16 = 244 (decimal) -> 0x0120 (hexadecimal)
				if    daddress(15 downto 0) = (MY_WORD_ADDRESS) then
					ddata_r <= x"0000" & axi_x;
				elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 1) then
					ddata_r <= x"0000" & axi_y;
				elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 2) then
					ddata_r <= x"0000" & axi_z;
				elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 3) then
					ddata_r <= x"0000" & s_axi_x_max;
				elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 4) then
					ddata_r <= x"0000" & s_axi_y_max;
				elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 5) then
					ddata_r <= x"0000" & s_axi_z_max;
				end if;
			end if;
      end if;
    end if;
  end process;

  process (rst, clk)
  begin
      if rst = '1' then
          s_axi_x_max <= (others => '0');
          s_axi_y_max <= (others => '0');
          s_axi_z_max <= (others => '0');
          
      elsif rising_edge(clk) then
        if axi_x > s_axi_x_max then
          s_axi_x_max <= axi_x;
        end if;

        if axi_y > s_axi_y_max then
          s_axi_y_max <= axi_y;
        end if;

        if axi_z > s_axi_z_max then
          s_axi_z_max <= axi_z;
        end if;

      end if;
  end process;
   
end rtl;