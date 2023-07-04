library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spwm is
    generic (
        MY_CHIPSELECT       : std_logic_vector(1 downto 0)    := "10"; --  ddata_r_periph when "10" -- ver databusmux
        MY_WORD_ADDRESS     : unsigned(15 downto 0)          := x"0110"; 
	    DADDRESS_BUS_SIZE   : integer := 32;
        INPUT_CLK_FREQ     : natural := 50e6
    );
    port(
        -- hardware input/output
        clock           : in std_logic;
        reset           : in std_logic;
        sine_pwm1       : out std_logic;

        -- Core data bus signals
        daddress        : in unsigned(DADDRESS_BUS_SIZE-1 downto 0);
        ddata_w         : in std_logic_vector(31 downto 0);
        ddata_r         : out std_logic_vector(31 downto 0);
        d_we            : in  std_logic;
        d_rd            : in  std_logic;
        dcsel           : in std_logic_vector(1 downto 0);
        dmask           : in std_logic_vector(3 downto 0)

    );
end entity spwm;

architecture RTL of spwm is
    
    -- Value used for modulator counter limits 
    constant MOD_FULL_SCALE : natural   := 125;                                                    

------
    -- SPWM Inputs
    signal sine_freq                : unsigned(31 downto 0);
    signal mod_freq                 : unsigned(31 downto 0);
    -- Amplitude modulation ratio (percentage)
    -- signal amp_mod_ratio            : natural range 1 to 100;
    signal amp_mod_ratio            : unsigned(31 downto 0);

    -- SPWM Output
    signal switching_sine           : std_logic;
------

------
    -- SPWM Constants : assigned by input logic 
    signal sine_clkdiv_top_value    : natural ;
    signal mod_clkdiv_top_value     : natural ;
    signal scaling_factor : natural ;
------

------
    -- Component logic signals
    signal clk_mod : std_logic;
    signal clk_sine : std_logic;
    signal clk_enable : std_logic;
    signal mod_count : signed(15 downto 0);
    signal mod_direction : std_logic;
------

    -- Sine table with 15bit signed values
    constant sine_resolution    : natural := 1000;

    type sine_table_t is array (natural range 0 to (sine_resolution-1)) of integer range -32768 to 32768;
    constant sine_table : sine_table_t := (0,   206,   412,   618,   823,  1029,  1235,  1441,  1646,  1852,
   2057,  2263,  2468,  2673,  2879,  3084,  3289,  3493,  3698,  3902,
   4107,  4311,  4515,  4719,  4922,  5126,  5329,  5532,  5735,  5938,
   6140,  6342,  6544,  6746,  6947,  7148,  7349,  7549,  7749,  7949,
   8149,  8348,  8547,  8746,  8944,  9142,  9339,  9536,  9733,  9930,
  10126, 10321, 10516, 10711, 10905, 11099, 11293, 11486, 11679, 11871,
  12062, 12254, 12444, 12634, 12824, 13013, 13202, 13390, 13578, 13765,
  13952, 14138, 14323, 14508, 14692, 14876, 15059, 15242, 15424, 15605,
  15786, 15966, 16145, 16324, 16502, 16680, 16857, 17033, 17208, 17383,
  17557, 17731, 17904, 18076, 18247, 18418, 18588, 18757, 18925, 19093,
  19260, 19426, 19592, 19756, 19920, 20083, 20245, 20407, 20568, 20727,
  20886, 21045, 21202, 21359, 21514, 21669, 21823, 21976, 22129, 22280,
  22431, 22580, 22729, 22877, 23024, 23170, 23315, 23459, 23602, 23745,
  23886, 24027, 24166, 24305, 24442, 24579, 24715, 24849, 24983, 25116,
  25247, 25378, 25508, 25637, 25764, 25891, 26017, 26141, 26265, 26388,
  26509, 26630, 26749, 26867, 26985, 27101, 27216, 27330, 27443, 27555,
  27666, 27776, 27885, 27992, 28099, 28204, 28308, 28411, 28513, 28614,
  28714, 28813, 28910, 29006, 29102, 29196, 29289, 29380, 29471, 29560,
  29648, 29736, 29821, 29906, 29990, 30072, 30153, 30233, 30312, 30390,
  30466, 30541, 30615, 30688, 30759, 30830, 30899, 30967, 31034, 31099,
  31163, 31226, 31288, 31349, 31408, 31466, 31523, 31578, 31633, 31686,
  31738, 31788, 31837, 31886, 31932, 31978, 32022, 32065, 32107, 32147,
  32187, 32225, 32261, 32297, 32331, 32364, 32395, 32425, 32454, 32482,
  32509, 32534, 32558, 32580, 32602, 32622, 32640, 32658, 32674, 32689,
  32702, 32715, 32726, 32735, 32744, 32751, 32757, 32761, 32764, 32766,
  32767, 32766, 32764, 32761, 32757, 32751, 32744, 32735, 32726, 32715,
  32702, 32689, 32674, 32658, 32640, 32622, 32602, 32580, 32558, 32534,
  32509, 32482, 32454, 32425, 32395, 32364, 32331, 32297, 32261, 32225,
  32187, 32147, 32107, 32065, 32022, 31978, 31932, 31886, 31837, 31788,
  31738, 31686, 31633, 31578, 31523, 31466, 31408, 31349, 31288, 31226,
  31163, 31099, 31034, 30967, 30899, 30830, 30759, 30688, 30615, 30541,
  30466, 30390, 30312, 30233, 30153, 30072, 29990, 29906, 29821, 29736,
  29648, 29560, 29471, 29380, 29289, 29196, 29102, 29006, 28910, 28813,
  28714, 28614, 28513, 28411, 28308, 28204, 28099, 27992, 27885, 27776,
  27666, 27555, 27443, 27330, 27216, 27101, 26985, 26867, 26749, 26630,
  26509, 26388, 26265, 26141, 26017, 25891, 25764, 25637, 25508, 25378,
  25247, 25116, 24983, 24849, 24715, 24579, 24442, 24305, 24166, 24027,
  23886, 23745, 23602, 23459, 23315, 23170, 23024, 22877, 22729, 22580,
  22431, 22280, 22129, 21976, 21823, 21669, 21514, 21359, 21202, 21045,
  20886, 20727, 20568, 20407, 20245, 20083, 19920, 19756, 19592, 19426,
  19260, 19093, 18925, 18757, 18588, 18418, 18247, 18076, 17904, 17731,
  17557, 17383, 17208, 17033, 16857, 16680, 16502, 16324, 16145, 15966,
  15786, 15605, 15424, 15242, 15059, 14876, 14692, 14508, 14323, 14138,
  13952, 13765, 13578, 13390, 13202, 13013, 12824, 12634, 12444, 12254,
  12062, 11871, 11679, 11486, 11293, 11099, 10905, 10711, 10516, 10321,
  10126,  9930,  9733,  9536,  9339,  9142,  8944,  8746,  8547,  8348,
   8149,  7949,  7749,  7549,  7349,  7148,  6947,  6746,  6544,  6342,
   6140,  5938,  5735,  5532,  5329,  5126,  4922,  4719,  4515,  4311,
   4107,  3902,  3698,  3493,  3289,  3084,  2879,  2673,  2468,  2263,
   2057,  1852,  1646,  1441,  1235,  1029,   823,   618,   412,   206,
      0,  -206,  -412,  -618,  -823, -1029, -1235, -1441, -1646, -1852,
  -2057, -2263, -2468, -2673, -2879, -3084, -3289, -3493, -3698, -3902,
  -4107, -4311, -4515, -4719, -4922, -5126, -5329, -5532, -5735, -5938,
  -6140, -6342, -6544, -6746, -6947, -7148, -7349, -7549, -7749, -7949,
  -8149, -8348, -8547, -8746, -8944, -9142, -9339, -9536, -9733, -9930,
 -10126,-10321,-10516,-10711,-10905,-11099,-11293,-11486,-11679,-11871,
 -12062,-12254,-12444,-12634,-12824,-13013,-13202,-13390,-13578,-13765,
 -13952,-14138,-14323,-14508,-14692,-14876,-15059,-15242,-15424,-15605,
 -15786,-15966,-16145,-16324,-16502,-16680,-16857,-17033,-17208,-17383,
 -17557,-17731,-17904,-18076,-18247,-18418,-18588,-18757,-18925,-19093,
 -19260,-19426,-19592,-19756,-19920,-20083,-20245,-20407,-20568,-20727,
 -20886,-21045,-21202,-21359,-21514,-21669,-21823,-21976,-22129,-22280,
 -22431,-22580,-22729,-22877,-23024,-23170,-23315,-23459,-23602,-23745,
 -23886,-24027,-24166,-24305,-24442,-24579,-24715,-24849,-24983,-25116,
 -25247,-25378,-25508,-25637,-25764,-25891,-26017,-26141,-26265,-26388,
 -26509,-26630,-26749,-26867,-26985,-27101,-27216,-27330,-27443,-27555,
 -27666,-27776,-27885,-27992,-28099,-28204,-28308,-28411,-28513,-28614,
 -28714,-28813,-28910,-29006,-29102,-29196,-29289,-29380,-29471,-29560,
 -29648,-29736,-29821,-29906,-29990,-30072,-30153,-30233,-30312,-30390,
 -30466,-30541,-30615,-30688,-30759,-30830,-30899,-30967,-31034,-31099,
 -31163,-31226,-31288,-31349,-31408,-31466,-31523,-31578,-31633,-31686,
 -31738,-31788,-31837,-31886,-31932,-31978,-32022,-32065,-32107,-32147,
 -32187,-32225,-32261,-32297,-32331,-32364,-32395,-32425,-32454,-32482,
 -32509,-32534,-32558,-32580,-32602,-32622,-32640,-32658,-32674,-32689,
 -32702,-32715,-32726,-32735,-32744,-32751,-32757,-32761,-32764,-32766,
 -32767,-32766,-32764,-32761,-32757,-32751,-32744,-32735,-32726,-32715,
 -32702,-32689,-32674,-32658,-32640,-32622,-32602,-32580,-32558,-32534,
 -32509,-32482,-32454,-32425,-32395,-32364,-32331,-32297,-32261,-32225,
 -32187,-32147,-32107,-32065,-32022,-31978,-31932,-31886,-31837,-31788,
 -31738,-31686,-31633,-31578,-31523,-31466,-31408,-31349,-31288,-31226,
 -31163,-31099,-31034,-30967,-30899,-30830,-30759,-30688,-30615,-30541,
 -30466,-30390,-30312,-30233,-30153,-30072,-29990,-29906,-29821,-29736,
 -29648,-29560,-29471,-29380,-29289,-29196,-29102,-29006,-28910,-28813,
 -28714,-28614,-28513,-28411,-28308,-28204,-28099,-27992,-27885,-27776,
 -27666,-27555,-27443,-27330,-27216,-27101,-26985,-26867,-26749,-26630,
 -26509,-26388,-26265,-26141,-26017,-25891,-25764,-25637,-25508,-25378,
 -25247,-25116,-24983,-24849,-24715,-24579,-24442,-24305,-24166,-24027,
 -23886,-23745,-23602,-23459,-23315,-23170,-23024,-22877,-22729,-22580,
 -22431,-22280,-22129,-21976,-21823,-21669,-21514,-21359,-21202,-21045,
 -20886,-20727,-20568,-20407,-20245,-20083,-19920,-19756,-19592,-19426,
 -19260,-19093,-18925,-18757,-18588,-18418,-18247,-18076,-17904,-17731,
 -17557,-17383,-17208,-17033,-16857,-16680,-16502,-16324,-16145,-15966,
 -15786,-15605,-15424,-15242,-15059,-14876,-14692,-14508,-14323,-14138,
 -13952,-13765,-13578,-13390,-13202,-13013,-12824,-12634,-12444,-12254,
 -12062,-11871,-11679,-11486,-11293,-11099,-10905,-10711,-10516,-10321,
 -10126, -9930, -9733, -9536, -9339, -9142, -8944, -8746, -8547, -8348,
  -8149, -7949, -7749, -7549, -7349, -7148, -6947, -6746, -6544, -6342,
  -6140, -5938, -5735, -5532, -5329, -5126, -4922, -4719, -4515, -4311,
  -4107, -3902, -3698, -3493, -3289, -3084, -2879, -2673, -2468, -2263,
  -2057, -1852, -1646, -1441, -1235, -1029,  -823,  -618,  -412,  -206);
    
    signal sine_value : signed(15 downto 0);
    signal sine_index : natural := sine_resolution-1;

begin

    clk_enable <= not reset;

    -- Input register
    process(clock, reset)
    begin
        if reset = '1' then
            sine_freq               <= (others => '0'); 
            mod_freq                <= (others => '0');
            amp_mod_ratio           <= (others => '0');
            sine_clkdiv_top_value   <= 0;
            mod_clkdiv_top_value    <= 0;
        else
            if rising_edge(clock) then
                if (d_we = '1') and (dcsel = MY_CHIPSELECT) then
                    if daddress(15 downto 0) =(MY_WORD_ADDRESS + x"0000") then
                        sine_freq <= unsigned(ddata_w);
                        sine_clkdiv_top_value <= INPUT_CLK_FREQ/(sine_resolution*2*to_integer(unsigned(ddata_w)));
                    elsif daddress(15 downto 0) =(MY_WORD_ADDRESS + x"0001") then
                        mod_freq <= unsigned(ddata_w);
                        mod_clkdiv_top_value <= INPUT_CLK_FREQ/(MOD_FULL_SCALE*4*2*to_integer(unsigned(ddata_w)));
                    elsif daddress(15 downto 0) =(MY_WORD_ADDRESS + x"0002") then
                        amp_mod_ratio <= unsigned(ddata_w);
                        scaling_factor <= ((to_integer(amp_mod_ratio))*((32768/MOD_FULL_SCALE)+1))/100; -- +1 avoids errors caused by round down on atribution
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Output register
    process(clock, reset)
    begin
        if reset = '1' then
            ddata_r <= (others => '0');
        else
            if rising_edge(clock) then
			    ddata_r <= (others => '0');
                if (d_rd = '1') and (dcsel = "10") then
                    if daddress(15 downto 0) = (MY_WORD_ADDRESS +x"0000") then
                        ddata_r(31 downto 0) <= std_logic_vector(sine_freq);
                    elsif daddress(15 downto 0) =(MY_WORD_ADDRESS + x"0001")then
                        ddata_r(31 downto 0) <= std_logic_vector(mod_freq);
                    elsif daddress(15 downto 0) =(MY_WORD_ADDRESS + x"0002")then
                        ddata_r(31 downto 0) <= std_logic_vector(amp_mod_ratio);
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Divisor de clock seno
    clock_sine_process: process(clock)
    variable count: natural := 0; --range 0 to sine_clkdiv_top_value := 0;
    variable temp: std_logic := '0';
    begin
        if (rising_edge(clock)) then
            if clk_enable = '1' then
                count := count + 1;
                if (count >= sine_clkdiv_top_value) then
                    temp := not temp;
                    count := 0;
                end if;           
            end if;            
        end if;    
        clk_sine <= temp;        
    end process;

    -- Divisor de clock moduladora
    clock_mod_process: process(clock)
    -- variable count: natural range 0 to mod_clkdiv_top_value := 0;
    variable count: natural  := 0;
    variable temp: std_logic := '0';
    begin
        if (rising_edge(clock)) then
            if clk_enable = '1' then
                count := count + 1;
                if (count >= mod_clkdiv_top_value) then
                    temp := not temp;
                    count := 0;
                end if;           
            end if;            
        end if;    
        clk_mod <= temp;        
    end process;

    -- Processo que atualiza o valor de seno
    sine_process: process (clk_sine, reset)
    variable count_temp : signed(15 downto 0);
    begin
        if reset = '1' then
            count_temp := (others => '0');
            sine_index <= 0;
        elsif (rising_edge(clk_sine)) then
            if sine_index = sine_resolution-1 then
                sine_index <= 0;
            else
                count_temp := to_signed(sine_table(sine_index),16);
                sine_index <= sine_index + 1;
            end if;
        end if;
        sine_value <= count_temp;
    end process;

-- Processo que faz a contagem da moduladora
    modulator_process: process (clk_mod, reset)
        variable count_temp : signed(15 downto 0);
    begin
        if reset = '1' then
            count_temp := (others => '0');
            mod_direction <= '0';
        elsif (rising_edge(clk_mod)) then
            if (mod_direction = '0') then
                if(count_temp < MOD_FULL_SCALE) then
                    count_temp := count_temp+ 1;
                else
                    mod_direction <= '1';
                    count_temp := count_temp -1;
                end if;
            else
                if(count_temp > -MOD_FULL_SCALE) then
                    count_temp := count_temp - 1;
                else
                    mod_direction <= '0';
                    count_temp := count_temp + 1;
                end if;
            end if;
        end if;
        mod_count <= count_temp;
    end process;

-- Processo que comparada seno e moduladora
    spwm_process: process (clk_mod, reset)
    begin
        if reset = '1' then
            sine_pwm1 <= '0';
        elsif (rising_edge(clk_mod)) then
            if(sine_value > (scaling_factor*mod_count)) then
                sine_pwm1 <= '1';
            else
                sine_pwm1 <= '0';
            end if;
        end if;
    end process;

end architecture RTL;
