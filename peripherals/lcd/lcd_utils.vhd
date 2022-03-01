-------------------------------------------------------------------
-- Name        : lcd_utils
-- Author      : Gustavo Vianna França
-- Date        : 28 de fev. de 2022
-- Version     : 0.1
-- Copyright   : Gustavo Vianna França, Departamento de Eletrônica, Florianópolis, IFSC
-- Description : Utilities package for the Nokia 5110 LCD display
-------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package lcd_utils is
    type lcd_din is array (0 to 4) of std_logic_vector(0 to 7);
    procedure LCD_CHARACTER(signal char : in std_logic_vector(7 downto 0);
                        signal din  : out lcd_din);

end package lcd_utils;

package body lcd_utils is
    procedure LCD_CHARACTER(signal char : in std_logic_vector(7 downto 0);
                        signal din  : out lcd_din) is
    begin
        if char(7 downto 0) = x"20" then
            din <= (x"00", x"00", x"00", x"00", x"00"); --! 20 Space
        elsif char(7 downto 0) = x"21" then
            din <= (x"00", x"00", x"5f", x"00", x"00"); --! 21 !
        elsif char(7 downto 0) = x"22" then
            din <= (x"00", x"07", x"00", x"07", x"00"); --! 22 "
        elsif char(7 downto 0) = x"23" then
            din <= (x"14", x"7f", x"14", x"7f", x"14"); --! 23 #
        elsif char(7 downto 0) = x"24" then
            din <= (x"24", x"2a", x"7f", x"2a", x"12"); --! 24 $
        elsif char(7 downto 0) = x"25" then
            din <= (x"23", x"13", x"08", x"64", x"62"); --! 25 %
        elsif char(7 downto 0) = x"26" then
            din <= (x"36", x"49", x"55", x"22", x"50"); --! 26 &
        elsif char(7 downto 0) = x"27" then
            din <= (x"00", x"05", x"03", x"00", x"00"); --! 27 '
        elsif char(7 downto 0) = x"28" then
            din <= (x"00", x"1c", x"22", x"41", x"00"); --! 28 (
        elsif char(7 downto 0) = x"29" then
            din <= (x"00", x"41", x"22", x"1c", x"00"); --! 29 )
        elsif char(7 downto 0) = x"2a" then
            din <= (x"14", x"08", x"3e", x"08", x"14"); --! 2a *
        elsif char(7 downto 0) = x"2b" then
            din <= (x"08", x"08", x"3e", x"08", x"08"); --! 2b +
        elsif char(7 downto 0) = x"2c" then
            din <= (x"00", x"50", x"30", x"00", x"00"); --! 2c ,
        elsif char(7 downto 0) = x"2d" then
            din <= (x"08", x"08", x"08", x"08", x"08"); --! 2d -
        elsif char(7 downto 0) = x"2e" then
            din <= (x"00", x"60", x"60", x"00", x"00"); --! 2e .
        elsif char(7 downto 0) = x"2f" then
            din <= (x"20", x"10", x"08", x"04", x"02"); --! 2f /
        elsif char(7 downto 0) = x"30" then
            din <= (x"3e", x"51", x"49", x"45", x"3e"); --! 30 0
        elsif char(7 downto 0) = x"31" then
            din <= (x"00", x"42", x"7f", x"40", x"00"); --! 31 1
        elsif char(7 downto 0) = x"32" then
            din <= (x"42", x"61", x"51", x"49", x"46"); --! 32 2
        elsif char(7 downto 0) = x"33" then
            din <= (x"21", x"41", x"45", x"4b", x"31"); --! 33 3
        elsif char(7 downto 0) = x"34" then
            din <= (x"18", x"14", x"12", x"7f", x"10"); --! 34 4
        elsif char(7 downto 0) = x"35" then
            din <= (x"27", x"45", x"45", x"45", x"39"); --! 35 5
        elsif char(7 downto 0) = x"36" then
            din <= (x"3c", x"4a", x"49", x"49", x"30"); --! 36 6
        elsif char(7 downto 0) = x"37" then
            din <= (x"01", x"71", x"09", x"05", x"03"); --! 37 7
        elsif char(7 downto 0) = x"38" then
            din <= (x"36", x"49", x"49", x"49", x"36"); --! 38 8
        elsif char(7 downto 0) = x"39" then
            din <= (x"06", x"49", x"49", x"29", x"1e"); --! 39 9
        elsif char(7 downto 0) = x"3a" then
            din <= (x"00", x"36", x"36", x"00", x"00"); --! 3a :
        elsif char(7 downto 0) = x"3b" then
            din <= (x"00", x"56", x"36", x"00", x"00"); --! 3b ;
        elsif char(7 downto 0) = x"3c" then
            din <= (x"08", x"14", x"22", x"41", x"00"); --! 3c <
        elsif char(7 downto 0) = x"3d" then
            din <= (x"14", x"14", x"14", x"14", x"14"); --! 3d =
        elsif char(7 downto 0) = x"3e" then
            din <= (x"00", x"41", x"22", x"14", x"08"); --! 3e >
        elsif char(7 downto 0) = x"3f" then
            din <= (x"02", x"01", x"51", x"09", x"06"); --! 3f ?
        elsif char(7 downto 0) = x"40" then
            din <= (x"32", x"49", x"79", x"41", x"3e"); --! 40 @
        elsif char(7 downto 0) = x"41" then
            din <= (x"7e", x"11", x"11", x"11", x"7e"); --! 41 A
        elsif char(7 downto 0) = x"42" then
            din <= (x"7f", x"49", x"49", x"49", x"36"); --! 42 B
        elsif char(7 downto 0) = x"43" then
            din <= (x"3e", x"41", x"41", x"41", x"22"); --! 43 C
        elsif char(7 downto 0) = x"44" then
            din <= (x"7f", x"41", x"41", x"22", x"1c"); --! 44 D
        elsif char(7 downto 0) = x"45" then
            din <= (x"7f", x"49", x"49", x"49", x"41"); --! 45 E
        elsif char(7 downto 0) = x"46" then
            din <= (x"7f", x"09", x"09", x"09", x"01"); --! 46 F
        elsif char(7 downto 0) = x"47" then
            din <= (x"3e", x"41", x"49", x"49", x"7a"); --! 47 G
        elsif char(7 downto 0) = x"48" then
            din <= (x"7f", x"08", x"08", x"08", x"7f"); --! 48 H
        elsif char(7 downto 0) = x"49" then
            din <= (x"00", x"41", x"7f", x"41", x"00"); --! 49 I
        elsif char(7 downto 0) = x"4a" then
            din <= (x"20", x"40", x"41", x"3f", x"01"); --! 4a J
        elsif char(7 downto 0) = x"4b" then
            din <= (x"7f", x"08", x"14", x"22", x"41"); --! 4b K
        elsif char(7 downto 0) = x"4c" then
            din <= (x"7f", x"40", x"40", x"40", x"40"); --! 4c L
        elsif char(7 downto 0) = x"4d" then
            din <= (x"7f", x"02", x"0c", x"02", x"7f"); --! 4d M
        elsif char(7 downto 0) = x"4e" then
            din <= (x"7f", x"04", x"08", x"10", x"7f"); --! 4e N
        elsif char(7 downto 0) = x"4f" then
            din <= (x"3e", x"41", x"41", x"41", x"3e"); --! 4f O
        elsif char(7 downto 0) = x"50" then
            din <= (x"7f", x"09", x"09", x"09", x"06"); --! 50 P
        elsif char(7 downto 0) = x"51" then
            din <= (x"3e", x"41", x"51", x"21", x"5e"); --! 51 Q
        elsif char(7 downto 0) = x"52" then
            din <= (x"7f", x"09", x"19", x"29", x"46"); --! 52 R
        elsif char(7 downto 0) = x"53" then
            din <= (x"46", x"49", x"49", x"49", x"31"); --! 53 S
        elsif char(7 downto 0) = x"54" then
            din <= (x"01", x"01", x"7f", x"01", x"01"); --! 54 T
        elsif char(7 downto 0) = x"55" then
            din <= (x"3f", x"40", x"40", x"40", x"3f"); --! 55 U
        elsif char(7 downto 0) = x"56" then
            din <= (x"1f", x"20", x"40", x"20", x"1f"); --! 56 V
        elsif char(7 downto 0) = x"57" then
            din <= (x"3f", x"40", x"38", x"40", x"3f"); --! 57 W
        elsif char(7 downto 0) = x"58" then
            din <= (x"63", x"14", x"08", x"14", x"63"); --! 58 X
        elsif char(7 downto 0) = x"59" then
            din <= (x"07", x"08", x"70", x"08", x"07"); --! 59 Y
        elsif char(7 downto 0) = x"5a" then
            din <= (x"61", x"51", x"49", x"45", x"43"); --! 5a Z
        elsif char(7 downto 0) = x"5b" then
            din <= (x"00", x"7f", x"41", x"41", x"00"); --! 5b [
        elsif char(7 downto 0) = x"5c" then
            din <= (x"02", x"04", x"08", x"10", x"20"); --! 5c \
        elsif char(7 downto 0) = x"5d" then
            din <= (x"00", x"41", x"41", x"7f", x"00"); --! 5d ]
        elsif char(7 downto 0) = x"5e" then
            din <= (x"04", x"02", x"01", x"02", x"04"); --! 5e ^
        elsif char(7 downto 0) = x"5f" then
            din <= (x"40", x"40", x"40", x"40", x"40"); --! 5f _
        elsif char(7 downto 0) = x"60" then
            din <= (x"00", x"01", x"02", x"04", x"00"); --! 60 `
        elsif char(7 downto 0) = x"61" then
            din <= (x"20", x"54", x"54", x"54", x"78"); --! 61 a
        elsif char(7 downto 0) = x"62" then
            din <= (x"7f", x"48", x"44", x"44", x"38"); --! 62 b
        elsif char(7 downto 0) = x"63" then
            din <= (x"38", x"44", x"44", x"44", x"20"); --! 63 c
        elsif char(7 downto 0) = x"64" then
            din <= (x"38", x"44", x"44", x"48", x"7f"); --! 64 d
        elsif char(7 downto 0) = x"65" then
            din <= (x"38", x"54", x"54", x"54", x"18"); --! 65 e
        elsif char(7 downto 0) = x"66" then
            din <= (x"08", x"7e", x"09", x"01", x"02"); --! 66 f
        elsif char(7 downto 0) = x"67" then
            din <= (x"0c", x"52", x"52", x"52", x"3e"); --! 67 g
        elsif char(7 downto 0) = x"68" then
            din <= (x"7f", x"08", x"04", x"04", x"78"); --! 68 h
        elsif char(7 downto 0) = x"69" then
            din <= (x"00", x"44", x"7d", x"40", x"00"); --! 69 i
        elsif char(7 downto 0) = x"6a" then
            din <= (x"20", x"40", x"44", x"3d", x"00"); --! 6a j
        elsif char(7 downto 0) = x"6b" then
            din <= (x"7f", x"10", x"28", x"44", x"00"); --! 6b k
        elsif char(7 downto 0) = x"6c" then
            din <= (x"00", x"41", x"7f", x"40", x"00"); --! 6c l
        elsif char(7 downto 0) = x"6d" then
            din <= (x"7c", x"04", x"18", x"04", x"78"); --! 6d m
        elsif char(7 downto 0) = x"6e" then
            din <= (x"7c", x"08", x"04", x"04", x"78"); --! 6e n
        elsif char(7 downto 0) = x"6f" then
            din <= (x"38", x"44", x"44", x"44", x"38"); --! 6f o
        elsif char(7 downto 0) = x"70" then
            din <= (x"7c", x"14", x"14", x"14", x"08"); --! 70 p
        elsif char(7 downto 0) = x"71" then
            din <= (x"08", x"14", x"14", x"18", x"7c"); --! 71 q
        elsif char(7 downto 0) = x"72" then
            din <= (x"7c", x"08", x"04", x"04", x"08"); --! 72 r
        elsif char(7 downto 0) = x"73" then
            din <= (x"48", x"54", x"54", x"54", x"20"); --! 73 s
        elsif char(7 downto 0) = x"74" then
            din <= (x"04", x"3f", x"44", x"40", x"20"); --! 74 t
        elsif char(7 downto 0) = x"75" then
            din <= (x"3c", x"40", x"40", x"20", x"7c"); --! 75 u
        elsif char(7 downto 0) = x"76" then
            din <= (x"1c", x"20", x"40", x"20", x"1c"); --! 76 v
        elsif char(7 downto 0) = x"77" then
            din <= (x"3c", x"40", x"30", x"40", x"3c"); --! 77 w
        elsif char(7 downto 0) = x"78" then
            din <= (x"44", x"28", x"10", x"28", x"44"); --! 78 x
        elsif char(7 downto 0) = x"79" then
            din <= (x"0c", x"50", x"50", x"50", x"3c"); --! 79 y
        elsif char(7 downto 0) = x"7a" then
            din <= (x"44", x"64", x"54", x"4c", x"44"); --! 7a z
        elsif char(7 downto 0) = x"7b" then
            din <= (x"00", x"08", x"36", x"41", x"00"); --! 7b {
        elsif char(7 downto 0) = x"7c" then
            din <= (x"00", x"00", x"7f", x"00", x"00"); --! 7c |
        elsif char(7 downto 0) = x"7d" then
            din <= (x"00", x"41", x"36", x"08", x"00"); --! 7d }
        elsif char(7 downto 0) = x"7e" then
            din <= (x"10", x"08", x"08", x"10", x"08"); --! 7e ~
        elsif char(7 downto 0) = x"7f" then
            din <= (x"78", x"46", x"41", x"46", x"78"); --! 7f DEL
        else
            din <= (x"ff", x"ff", x"ff", x"ff", x"ff");
        end if;
    end procedure LCD_CHARACTER;

end package body lcd_utils;
