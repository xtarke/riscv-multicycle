-- format beautify: https://g2384.github.io/work/VHDLformatter.html
-- accel_bus: without spi slave, inptu values get GSENSOR de10_lite
-- accel_bus_tb (testbench) : with spi slave for input values test

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity accel_bus is
  generic (
    -- chip select
    MY_CHIPSELECT   : std_logic_vector(1 downto 0) := "10";
    MY_WORD_ADDRESS : std_logic_vector(7 downto 0) := x"10"
  );
  port (
    -- core data bus signals
    daddress : in natural;
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
  );
end accel_bus;

architecture rtl of accel_bus is
	 
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
        -- #define ACCELEROMETER_BASE_ADDRESS (*(_IO32 *) (PERIPH_BASE + 8*16*4))
        -- 8*16 = 128 (decimal) -> 80 (hexadecimal)
				if    to_unsigned(daddress, 32)(7 downto 0) = x"80" then
					ddata_r <= x"0000" & axi_x;
				elsif to_unsigned(daddress, 32)(7 downto 0) = x"81" then
					ddata_r <= x"0000" & axi_y;
				elsif to_unsigned(daddress, 32)(7 downto 0) = x"82" then
					ddata_r <= x"0000" & axi_z;
				end if;
			end if;
      end if;
    end if;
  end process;
   
end rtl;