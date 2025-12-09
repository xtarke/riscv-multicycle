---------------------------------------------------------------------
--! @file
--! @brief DE10-Lite Simple binary to seven segment display decoder
--!        This hardware should be connected to RISC-V data bus           
--------------------------------------------------------------------

--! Use standard library
library ieee;
    --! Use standard logic elements
    use ieee.std_logic_1164.all;
    --! Use conversion functions
    use ieee.numeric_std.all;

-------------------------------------
entity led_displays is
    generic (
        --! Chip selec
        MY_CHIPSELECT : std_logic_vector(1 downto 0) := "10";   --! Chip select of this device
        MY_WORD_ADDRESS : unsigned(15 downto 0) := x"0010";     --! Address of this device
        DADDRESS_BUS_SIZE : integer := 32                       --! Data bus size
    );
	port 
	(
		clk : in std_logic;
        rst : in std_logic;
        
        -- Core data bus signals
        -- ToDo: daddress shoud be unsgined
        daddress  : in  unsigned(DADDRESS_BUS_SIZE-1 downto 0);
        ddata_w   : in  std_logic_vector(31 downto 0);
        ddata_r   : out std_logic_vector(31 downto 0);
        d_we      : in std_logic;
        d_rd      : in std_logic;
        dcsel     : in std_logic_vector(1 downto 0);    --! Chip select 
        -- ToDo: Module should mask bytes (Word, half word and byte access)
        dmask     : in std_logic_vector(3 downto 0);    --! Byte enable mask
        
        -- hardware input/output signals
        hex0 : out std_logic_vector(7 downto 0);
        hex1 : out std_logic_vector(7 downto 0);
        hex2 : out std_logic_vector(7 downto 0);
        hex3 : out std_logic_vector(7 downto 0);
        hex4 : out std_logic_vector(7 downto 0);
        hex5 : out std_logic_vector(7 downto 0);
        hex6 : out std_logic_vector(7 downto 0);
        hex7 : out std_logic_vector(7 downto 0)
	);
end entity led_displays;
------------------------------

architecture rtl of led_displays is
    
    function decode (data: std_logic_vector(3 downto 0)) return std_logic_vector is
        variable dec : std_logic_vector(7 downto 0);
    begin
        --! Data conversion function
        --! Could be done using RAM
        case data is
            when x"0" => dec := "11000000";
            when x"1" => dec := "11111001";
            when x"2" => dec := "10100100";
            when x"3" => dec := "10110000";
            when x"4" => dec := "10011001";
            when x"5" => dec := "10010010";
            when x"6" => dec := "10000010";
            when x"7" => dec := "11111000";
            when x"8" => dec := "10000000";
            when x"9" => dec := "10010000";
            when x"A" => dec := "10001000";
            when x"B" => dec := "10000011";
            when x"C" => dec := "10100111";
            when x"D" => dec := "10100001";
            when x"E" => dec := "10000110";
            when others => dec := "10001110";
        end case;    

        return dec;
    end function;
    
    signal raw_data : std_logic_vector(31 downto 0);
	
begin
	
	-- Input register
	-- This register allows readings from the core
	-- raw_data is not converted to display format
    process(clk, rst)
    begin
        if rst = '1' then
            ddata_r <= (others => '0');            
        else
            if rising_edge(clk) then
                if (d_rd = '1') and (dcsel = MY_CHIPSELECT) then
                    if daddress(15 downto 0) = MY_WORD_ADDRESS then
                        ddata_r <= raw_data; 
                    end if;
                end if;
            end if;
        end if;
    end process;
		
	-- Output register
    process(clk, rst)
    begin       
        if rst = '1' then
            --! All displays resets to zero
            hex0 <= "11000000";
            hex1 <= "11000000"; 
            hex2 <= "11000000"; 
            hex3 <= "11000000"; 
            hex4 <= "11000000"; 
            hex5 <= "11000000"; 
            hex6 <= "11000000"; 
            hex7 <= "11000000"; 
            raw_data <= (others => '0');     
        else
            if rising_edge(clk) then
                if (d_we = '1') and (dcsel = MY_CHIPSELECT) then                
                    if (daddress(15 downto 0)) = MY_WORD_ADDRESS then
                        -- Save raw data to allow readings from CPU
                        raw_data <= ddata_w;
                        
                        hex0 <= decode(ddata_w(3 downto 0));
                        hex1 <= decode(ddata_w(7 downto 4));
                        hex2 <= decode(ddata_w(11 downto 8));
                        hex3 <= decode(ddata_w(15 downto 12));
                        hex4 <= decode(ddata_w(19 downto 16));
                        hex5 <= decode(ddata_w(23 downto 20));
                        hex6 <= decode(ddata_w(27 downto 24));
                        hex7 <= decode(ddata_w(31 downto 28));
                    end if;
                end if;
            end if;
        end if;     
    end process;
end architecture rtl;
