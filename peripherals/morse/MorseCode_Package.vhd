library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package MorseCode_Package is
        type MorseCodeTable is array(integer range 0 to 9) of bit_vector(0 to 4);
        
        function Morse_codes(Morse_value : integer) return bit_vector;
        
        constant MorseCodes : MorseCodeTable := (
    -- Para uma futura implementação:
    -- acrescentar as letra e caracteres especiais
    -- utilizar de "." e "-" no lugar de "0" e "1"
    --    'A' => ".-",       'B' => "-...",     'C' => "-.-.",
    --    'D' => "-..",      'E' => ".",        'F' => "..-.",
    --    'G' => "--.",      'H' => "....",     'I' => "..",
    --    'J' => ".---",     'K' => "-.-",      'L' => ".-..",
    --    'M' => "--",       'N' => "-.",       'O' => "---",
    --    'P' => ".--.",     'Q' => "--.-",     'R' => ".-.",
    --    'S' => "...",      'T' => "-",        'U' => "..-",
    --    'V' => "...-",     'W' => ".--",      'X' => "-..-",
    --    'Y' => "-.--",     'Z' => "--..",
    --     0 => "-----",    1 => ".----",    2 => "..---",
    --     3 => "...--",    4 => " ....-",    5 => ".....",
    --     6 => "-....",    7 => "--...",    8 => "---..",
    --     9 => "----."
    -- ponto e 0 e traço e 1
        0 => "11111",    1 => "01111",    2 => "00111",
        3 => "00011",    4 => "00001",    5 => "00000",
        6 => "10000",    7 => "11000",    8 => "11100",
        9 => "11110"
    );
               
end package MorseCode_Package;

package body MorseCode_Package is
    function Morse_Codes(Morse_value : integer) return bit_vector is
    begin
      return MorseCodes(Morse_value);
    end function Morse_Codes;
    
end package body MorseCode_Package;
