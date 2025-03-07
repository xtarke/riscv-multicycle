library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity disp_data is
    port(
        data_in           : in  std_logic_vector(15 downto 0);
        degree_conversion : in  std_logic;
        HEX_0             : out std_logic_vector(7 downto 0);
        HEX_1             : out std_logic_vector(7 downto 0);
        HEX_2             : out std_logic_vector(7 downto 0)
    );
end entity disp_data;

architecture rlt of disp_data is
    signal data_bcd     : unsigned(15 downto 0);
    signal sensor_val   : signed(15 downto 0);
    signal sensor_abs   : std_logic_vector(7 downto 0);
    signal angle_8bits  : std_logic_vector(7 downto 0);
    signal scaled_word  : std_logic_vector(15 downto 0);

    -- Sinal intermediário que fará a seleção de qual valor 
    -- será enviado para o bin_to_bcd
    signal bcd_input    : std_logic_vector(15 downto 0);

begin
    ----------------------------------------------------------------------------
    -- Conversões e LUT
    ----------------------------------------------------------------------------

    sensor_val <= signed(data_in);
    sensor_abs <= std_logic_vector(resize(unsigned(abs(sensor_val)), 8));

    lookup_inst: entity work.lookup_angle
        port map(
            raw_in     => sensor_abs,   -- magnitude
            signal_bit => data_in(15),  -- bit de sinal
            angle_out  => angle_8bits
        );

    ----------------------------------------------------------------------------
    -- Gera scaled_word (com sinal) via processo
    ----------------------------------------------------------------------------
    process(data_in, angle_8bits)
        variable val : integer;
    begin
        if data_in(15) = '1' then
            val := to_integer(unsigned("00000000" & angle_8bits));
            scaled_word <= std_logic_vector(to_unsigned(65536 - val, 16));
        else
            scaled_word <= "00000000" & angle_8bits;
        end if;
    end process;

    ----------------------------------------------------------------------------
    -- MUX para selecionar se vamos usar scaled_word ou 
    -- "0000000" & data_in(8 downto 2) & "00"
    ----------------------------------------------------------------------------
    with degree_conversion select
        bcd_input <= scaled_word
                    when '1',
                     "0000000" & data_in(8 downto 2) & "00"
                    when others;

    ----------------------------------------------------------------------------
    -- bin_to_bcd recebe o sinal multiplexado
    ----------------------------------------------------------------------------
    bcd : entity work.bin_to_bcd    
        port map(
            num_bin    => bcd_input,
            num_signal => data_in(15), 
            num_bcd    => data_bcd
        );

    ----------------------------------------------------------------------------
    -- Exibe a saída nos displays 7 segmentos
    ----------------------------------------------------------------------------
    seg7_hex1 : entity work.bcd_to_7seg 
        port map(
            input      => data_bcd( 3 downto  0),
            num_signal => '0',
            seg7       => HEX_0
        );

    seg7_hex2 : entity work.bcd_to_7seg 
        port map(
            input      => data_bcd( 7 downto  4),
            num_signal => '0',
            seg7       => HEX_1
        );

    seg7_hex3 : entity work.bcd_to_7seg 
        port map(
            input      => data_bcd(11 downto  8),
            num_signal => data_in(15),
            seg7       => HEX_2
        );

end architecture rlt;
