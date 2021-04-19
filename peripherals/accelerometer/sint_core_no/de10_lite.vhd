-- -- bibliotecas -- -- 
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all; -- unsigned()

-- -- interfaces de10_lite (entradas, saidas) -- --
entity de10_lite is
   port (
     MAX10_CLK1_50 :  in std_logic;
        KEY :  in std_logic_vector(0 downto 0);
    GSENSOR_SDO :  in std_logic;
   GSENSOR_CS_N : out std_logic;
   GSENSOR_SCLK : out std_logic;
    GSENSOR_SDI : out std_logic;
         HEX0 : out std_logic_vector(7 downto 0); 
       HEX1 : out std_logic_vector(7 downto 0);
       HEX2 : out std_logic_vector(7 downto 0);
       HEX3 : out std_logic_vector(7 downto 0);
       HEX4 : out std_logic_vector(7 downto 0);
       HEX5 : out std_logic_vector(7 downto 0)
   );
end de10_lite;


-- -- interligacoes (entidade e componentes) -- --
architecture rtl of de10_lite is
   component source_and_probe is
      port (         
         source : out std_logic_vector(39 downto 0);
         probe  : in  std_logic_vector(39 downto 0) := (others => 'X')
      );
   end component source_and_probe;

  signal data_bcd_x : unsigned(15 downto 0);
  signal data_bcd_y : unsigned(15 downto 0);  
  
  signal source : std_logic_vector(39 downto 0);
  signal probe  : std_logic_vector(39 downto 0);
  
  signal axi_x : STD_LOGIC_VECTOR(15 DOWNTO 0);
  signal axi_y : STD_LOGIC_VECTOR(15 DOWNTO 0);
  signal axi_z : STD_LOGIC_VECTOR(15 DOWNTO 0);

begin

   -- -- -- instanciar componente -- -- --
   sp_external : component source_and_probe
   port map(
      source => source, --sources.source
      probe  => probe   --probes.probe
   );

  -- instatiation: accelerometer
  e_accelerometer : entity work.accelerometer_adxl345
    port map(
      clk     => MAX10_CLK1_50, 
      rst     => NOT(KEY(0)),
      miso    => GSENSOR_SDO, 	
      sclk    => GSENSOR_SCLK,		
      ss_n(0) => GSENSOR_CS_N, 		
      mosi    => GSENSOR_SDI, 
      axi_x   => axi_x, 
      axi_y   => axi_y, 
      axi_z   => axi_z
    );

  -- bin to bcd
  -- x
  bcd_x : entity work.bin_to_bcd    
    port map( num_bin => "0000000" & axi_x(8 downto 2) & "00", num_signal => axi_x(15), num_bcd  => data_bcd_x );  
  -- y
  bcd_y : entity work.bin_to_bcd 
    port map( num_bin => "0000000" & axi_y(8 downto 2) & "00", num_signal => axi_y(15), num_bcd  => data_bcd_y );  


  -- bcd to display 7 seg.
  -- X
  seg7_hex0 : entity work.bcd_to_7seg 
    port map( input => data_bcd_x( 3 downto  0), num_signal => '0'               , seg7  => HEX0 );  
  seg7_hex1 : entity work.bcd_to_7seg 
    port map( input => data_bcd_x( 7 downto  4), num_signal => '0'               , seg7  => HEX1 );
  seg7_hex2 : entity work.bcd_to_7seg 
    port map( input => data_bcd_x(11 downto  8), num_signal => axi_x(15), seg7  => HEX2 );

  -- Y
  seg7_hex3 : entity work.bcd_to_7seg 
    port map( input => data_bcd_y( 3 downto  0), num_signal => '0'               , seg7  => HEX3 );
  seg7_hex4 : entity work.bcd_to_7seg 
    port map( input => data_bcd_y( 7 downto  4), num_signal => '0'               , seg7  => HEX4 );  
  seg7_hex5_p : entity work.bcd_to_7seg 
    port map( input => data_bcd_y(11 downto  8), num_signal => axi_y(15), seg7  => HEX5 );  
	 
	 probe(0) <= KEY(0);
	 probe(16 downto 1) <= axi_z;

end;