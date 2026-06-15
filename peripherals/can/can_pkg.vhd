library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package can_pkg is

    -- Functions prototypes
    
    -- __ MCP2515 Instructions (8 bits) __ -- 
    constant RESET          : std_logic_vector(7 downto 0) := x"C0"; 
    constant READ_RXB0SIDH  : std_logic_vector(7 downto 0) := x"90";
    constant READ_RXB0D0    : std_logic_vector(7 downto 0) := x"92";
    constant READ_RXB1SIDH  : std_logic_vector(7 downto 0) := x"94";
    constant READ_RXB1D0    : std_logic_vector(7 downto 0) := x"96";

    constant WRITE          : std_logic_vector(7 downto 0) := x"02";
    constant LOAD_TXB0SIDH  : std_logic_vector(7 downto 0) := x"40";    -- TX0 ID location
    constant LOAD_TXB0D0    : std_logic_vector(7 downto 0) := x"41";    -- TX0 Data location
    constant LOAD_TXB1SIDH  : std_logic_vector(7 downto 0) := x"42";    -- TX1 ID location
    constant LOAD_TXB1D0    : std_logic_vector(7 downto 0) := x"43";    -- TX1 Data location
    constant LOAD_TXB2SIDH  : std_logic_vector(7 downto 0) := x"44";    -- TX2 ID location
    constant LOAD_TXB2D0    : std_logic_vector(7 downto 0) := x"45";    -- TX2 Data location

    constant RTS_TX0        : std_logic_vector(7 downto 0) := x"81";
    constant RTS_TX1        : std_logic_vector(7 downto 0) := x"82";
    constant RTS_TX2        : std_logic_vector(7 downto 0) := x"84";
    constant RTS_ALL        : std_logic_vector(7 downto 0) := x"87";
    constant READ_STATUS    : std_logic_vector(7 downto 0) := x"A0";
    constant RX_STATUS      : std_logic_vector(7 downto 0) := x"B0";
    constant BIT_MOD        : std_logic_vector(7 downto 0) := x"05";

    -- __ MCP2515 Register Addresses (8 bits) __ --
    constant RXF0SIDH   : std_logic_vector(7 downto 0) := x"00";
    constant RXF0SIDL   : std_logic_vector(7 downto 0) := x"01";
    constant RXF0EID8   : std_logic_vector(7 downto 0) := x"02";
    constant RXF0EID0   : std_logic_vector(7 downto 0) := x"03";
    constant RXF1SIDH   : std_logic_vector(7 downto 0) := x"04";
    constant RXF1SIDL   : std_logic_vector(7 downto 0) := x"05";
    constant RXF1EID8   : std_logic_vector(7 downto 0) := x"06";
    constant RXF1EID0   : std_logic_vector(7 downto 0) := x"07";
    constant RXF2SIDH   : std_logic_vector(7 downto 0) := x"08";
    constant RXF2SIDL   : std_logic_vector(7 downto 0) := x"09";
    constant RXF2EID8   : std_logic_vector(7 downto 0) := x"0A";
    constant RXF2EID0   : std_logic_vector(7 downto 0) := x"0B";
    constant CANSTAT    : std_logic_vector(7 downto 0) := x"0E";
    constant CANCTRL    : std_logic_vector(7 downto 0) := x"0F";

    constant RXF3SIDH   : std_logic_vector(7 downto 0) := x"10";
    constant RXF3SIDL   : std_logic_vector(7 downto 0) := x"11";
    constant RXF3EID8   : std_logic_vector(7 downto 0) := x"12";
    constant RXF3EID0   : std_logic_vector(7 downto 0) := x"13";
    constant RXF4SIDH   : std_logic_vector(7 downto 0) := x"14";
    constant RXF4SIDL   : std_logic_vector(7 downto 0) := x"15";
    constant RXF4EID8   : std_logic_vector(7 downto 0) := x"16";
    constant RXF4EID0   : std_logic_vector(7 downto 0) := x"17";
    constant RXF5SIDH   : std_logic_vector(7 downto 0) := x"18";
    constant RXF5SIDL   : std_logic_vector(7 downto 0) := x"19";
    constant RXF5EID8   : std_logic_vector(7 downto 0) := x"1A";
    constant RXF5EID0   : std_logic_vector(7 downto 0) := x"1B";
    constant TEC        : std_logic_vector(7 downto 0) := x"1C";
    constant REC        : std_logic_vector(7 downto 0) := x"1D";

    constant RXM0SIDH   : std_logic_vector(7 downto 0) := x"20";
    constant RXM0SIDL   : std_logic_vector(7 downto 0) := x"21";
    constant RXM0EID8   : std_logic_vector(7 downto 0) := x"22";
    constant RXM0EID0   : std_logic_vector(7 downto 0) := x"23";
    constant RXM1SIDH   : std_logic_vector(7 downto 0) := x"24";
    constant RXM1SIDL   : std_logic_vector(7 downto 0) := x"25";
    constant RXM1EID8   : std_logic_vector(7 downto 0) := x"26";
    constant RXM1EID0   : std_logic_vector(7 downto 0) := x"27";
    constant CNF3       : std_logic_vector(7 downto 0) := x"28";
    constant CNF2       : std_logic_vector(7 downto 0) := x"29";
    constant CNF1       : std_logic_vector(7 downto 0) := x"2A";
    constant CANINTE    : std_logic_vector(7 downto 0) := x"2B";
    constant CANINTF    : std_logic_vector(7 downto 0) := x"2C";
    constant EFLG       : std_logic_vector(7 downto 0) := x"2D";

    constant TXB0CTRL   : std_logic_vector(7 downto 0) := x"30";
    constant TXB1CTRL   : std_logic_vector(7 downto 0) := x"40";
    constant TXB2CTRL   : std_logic_vector(7 downto 0) := x"50";
    constant RXB0CTRL   : std_logic_vector(7 downto 0) := x"60";
    constant RXB0SIDH   : std_logic_vector(7 downto 0) := x"61";
    constant RXB1CTRL   : std_logic_vector(7 downto 0) := x"70";
    constant RXB1SIDH   : std_logic_vector(7 downto 0) := x"71";

    constant TXB0SIDH   : std_logic_vector(7 downto 0) := x"31";
    constant TXB0SIDL   : std_logic_vector(7 downto 0) := x"32";
    constant TXB1SIDH   : std_logic_vector(7 downto 0) := x"41";
    constant TXB1SIDL   : std_logic_vector(7 downto 0) := x"42";
    constant TXB2SIDH   : std_logic_vector(7 downto 0) := x"51";
    constant TXB2SIDL   : std_logic_vector(7 downto 0) := x"52";

    constant TXB0DLC    : std_logic_vector(7 downto 0) := x"35";
    constant TXB1DLC    : std_logic_vector(7 downto 0) := x"45";
    constant TXB2DLC    : std_logic_vector(7 downto 0) := x"55";

    constant TXB0D0     : std_logic_vector(7 downto 0) := x"36";
    constant TXB0D1     : std_logic_vector(7 downto 0) := x"37";
    constant TXB0D2     : std_logic_vector(7 downto 0) := x"38";
    constant TXB0D3     : std_logic_vector(7 downto 0) := x"39";
    constant TXB0D4     : std_logic_vector(7 downto 0) := x"3A";
    constant TXB0D5     : std_logic_vector(7 downto 0) := x"3B";
    constant TXB0D6     : std_logic_vector(7 downto 0) := x"3C";
    constant TXB0D7     : std_logic_vector(7 downto 0) := x"3D";
    constant TXB1D0     : std_logic_vector(7 downto 0) := x"46";
    constant TXB2D0     : std_logic_vector(7 downto 0) := x"56";

    -- array of 8 registers for TXB0 data bytes (D0 to D7)
    type t_tx_data_regs is array (0 to 7) of std_logic_vector(7 downto 0);

    constant DOMINANT_BIT : std_logic := '0';
    constant RECESSIVE_BIT : std_logic := '1';

end package can_pkg;

package body can_pkg is



end package body can_pkg;
