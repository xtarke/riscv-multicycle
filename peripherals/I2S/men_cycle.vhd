library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity men_cycle is
    port(
        clk : in std_logic;
        rst : in std_logic;
        data : in std_logic_vector(31 downto 0);
        wren : in std_logic;
        q : out std_logic_vector(31 downto 0)
    );
end entity men_cycle;

architecture RTL of men_cycle is

    signal address : unsigned(13 downto 0) := (others => '0');

    component ram
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;    
begin
    ram_inst : component ram
        port map(
            address => std_logic_vector(address),
            clock   => clk,
            data    => data,
            wren    => wren,
            q       => q
        );

    addr_cycle : process (wren, rst) is
    begin
        if rst = '1' then
            address <= (others => '0');    
        elsif rising_edge(wren) then
            address <= address + 1; 
        end if;
    end process addr_cycle;
    
end architecture RTL;

