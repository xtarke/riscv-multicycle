LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity adc_qsysbus is
    port (
        reset_reset_n                        : in  std_logic                     := 'X';             -- reset_nogic 
        clk_clk                              : in  std_logic                     := 'X';             -- clk
        modular_adc_0_command_valid          : in  std_logic                     := 'X';             -- valid
        modular_adc_0_command_channel        : in  std_logic_vector(4 downto 0)  := (others => 'X'); -- channel
        modular_adc_0_command_startofpacket  : in  std_logic                     := 'X';             -- startofpacket
        modular_adc_0_command_endofpacket    : in  std_logic                     := 'X';             -- endofpacket
        modular_adc_0_command_ready          : out std_logic;                                        -- ready
        clock_bridge_sys_out_clk_clk         : out std_logic;                                        -- clk
        modular_adc_0_response_valid         : out std_logic;                                        -- valid
        modular_adc_0_response_channel       : out std_logic_vector(4 downto 0);                     -- channel
        modular_adc_0_response_data          : out std_logic_vector(11 downto 0);                    -- data
        modular_adc_0_response_startofpacket : out std_logic;                                        -- startofpacket
        modular_adc_0_response_endofpacket   : out std_logic                                         -- endofpacket  
    );
    
end entity adc_qsysbus;

architecture RTL of adc_qsysbus is
    signal clk_qsys             :std_logic;
    signal response_channel     :std_logic_vector(4 downto 0);
    signal response_data        :std_logic_vector(11 downto 0);
    
begin  

    clock_driver : process
        constant period : time := 10 ns;
    begin
        clk_qsys <= '0';
        wait for period / 2;
        clk_qsys <= '1';
        wait for period / 2;
    end process clock_driver;    
    
    clock_bridge_sys_out_clk_clk          <= clk_qsys; 
    modular_adc_0_response_valid          <= '1';
    modular_adc_0_response_startofpacket  <= '1';    
    modular_adc_0_response_endofpacket    <= '1';
    modular_adc_0_response_channel        <= response_channel;
    modular_adc_0_response_data           <= response_data;
    
    add_data: process (clk_clk, reset_reset_n)
        variable count_var : unsigned(4 downto 0) := (others => '0');
    begin
        if (reset_reset_n = '0') then
            response_channel <= (others => '0');
        elsif rising_edge(clk_clk) then
            count_var := count_var + 1;
            if (count_var = 16) then
                count_var := (others => '0');
            else
                response_channel <= std_logic_vector(count_var);
            end if;
        end if;
    end process add_data;
    
            -- Selected channel
    with response_channel select response_data <=
        --data         when channel
        "000000000001" when "00001",
        "000000000010" when "00010",
        "000000000011" when "00011",
        "000000000100" when "00100",
        "000000000101" when "00101",
        "000000000110" when "00110",
        "000000000111" when "00111",
        "000000001000" when "01000",
        "000000001001" when "01001",
        "000000001010" when "01010",
        "000000001011" when "01011",
        "000000001100" when "01100",
        "000000001101" when "01101",
        "000000001110" when "01110",
        "000000001111" when "01111",
        "000000010000" when "10000",
        (others => '0') when others;      
      
end architecture; 


