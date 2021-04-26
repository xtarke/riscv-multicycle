-------------------------------------------------------------------
-- Name        : de0_lite.vhd
-- Author      : Renan Augusto Starke
-- Modified    : Leticia de Oliveira Nunes e Marieli Matos
-- Version     : 0.1
-- Copyright   : Departamento de Eletrônica, Florianópolis, IFSC
-- Description : riscV ADC example
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc_core is
    generic(
        --! Chip selec
        MY_CHIPSELECT : std_logic_vector(1 downto 0) := "10";
        MY_WORD_ADDRESS : unsigned(7 downto 0) := x"10"
    );
    port(
        clk         : in std_logic;
        rst         : in std_logic;
        clk_adc     : in std_logic;
        -- Core data bus signals
        -- ToDo: daddress shoud be unsgined
        daddress    : in  natural;
        ddata_w     : in  std_logic_vector(31 downto 0);
        ddata_r     : out std_logic_vector(31 downto 0);
        d_we        : in std_logic;
        d_rd        : in std_logic;
        dcsel       : in std_logic_vector(1 downto 0);    --! Chip select 
        -- ToDo: Module should mask bytes (Word, half word and byte access)
        dmask       : in std_logic_vector(3 downto 0);    --! Byte enable mask
        debug_adc   : out  std_logic_vector(11 downto 0)
    
        -- hardware input/output signals
--        data_adc  : in std_logic_vector(31 downto 0);
--        output : out std_logic_vector(31 downto 0)
    );
end entity adc_core;

architecture rtl of adc_core is
    
    component adc_qsys is
        port (
            clk_clk                              : in  std_logic                     := 'X';             -- clk
            clock_bridge_sys_out_clk_clk         : out std_logic;                                        -- clk
            modular_adc_0_command_valid          : in  std_logic                     := 'X';             -- valid
            modular_adc_0_command_channel        : in  std_logic_vector(4 downto 0)  := (others => 'X'); -- channel
            modular_adc_0_command_startofpacket  : in  std_logic                     := 'X';             -- startofpacket
            modular_adc_0_command_endofpacket    : in  std_logic                     := 'X';             -- endofpacket
            modular_adc_0_command_ready          : out std_logic;                                        -- ready
            modular_adc_0_response_valid         : out std_logic;                                        -- valid
            modular_adc_0_response_channel       : out std_logic_vector(4 downto 0);                     -- channel
            modular_adc_0_response_data          : out std_logic_vector(11 downto 0);                    -- data
            modular_adc_0_response_startofpacket : out std_logic;                                        -- startofpacket
            modular_adc_0_response_endofpacket   : out std_logic;                                        -- endofpacket
            reset_reset_n                        : in  std_logic                     := 'X'              -- reset_n
        );
    end component adc_qsys;
    
    signal cur_adc_ch                : std_logic_vector(4 downto 0);
    signal adc_sample_data           : std_logic_vector(31 downto 0);  
    
    signal adc_out_clk               : std_logic;
    signal channel_adc               : std_logic_vector(31 downto 0);
    signal command_ready             : std_logic;
    signal response_valid            : std_logic := '1';
    signal response_channel          : std_logic_vector(4 downto 0);
    signal response_data             : std_logic_vector(11 downto 0);
    signal response_startofpacket    : std_logic;
    signal response_endofpacket      : std_logic;   
    signal reset_n                   : std_logic;

    constant ADC_BASE_ADDRESS        : unsigned(15 downto 0) := x"0030";
   
begin
    u0 : component adc_qsys
        port map (
            clk_clk                              => clk_adc,                        -- clk.clk
            clock_bridge_sys_out_clk_clk         => adc_out_clk,                    -- clock_bridge_sys_out_clk.clk
            modular_adc_0_command_valid          => '1',                            -- modular_adc_0_command.valid
            modular_adc_0_command_channel        => channel_adc(4 downto 0),        -- .channel
            modular_adc_0_command_startofpacket  => '1',                            -- .startofpacket
            modular_adc_0_command_endofpacket    => '1',                            -- .endofpacket
            modular_adc_0_command_ready          => command_ready,                  -- .ready
            modular_adc_0_response_valid         => response_valid,                 -- modular_adc_0_response.valid
            modular_adc_0_response_channel       => response_channel,               -- .channel
            modular_adc_0_response_data          => response_data,                  -- .data
            modular_adc_0_response_startofpacket => response_startofpacket,         -- .startofpacket
            modular_adc_0_response_endofpacket   => response_endofpacket,           -- .endofpacket
            reset_reset_n                        => reset_n                         -- reset.reset_n
        );
    reset_n <= not rst;    
    debug_adc <= response_data;
    
    read_adc: process(clk_adc, reset_n) --adc_out_clk
    begin
        if reset_n = '0' then
            adc_sample_data <= (others => '0');
            cur_adc_ch      <= (others => '0');
        else
            if (rising_edge(clk_adc) and response_valid = '1') then --adc_out_clk
                adc_sample_data <= "00000000000000000000" & response_data;
                cur_adc_ch      <= response_channel;
            end if;
        end if;
    end process read_adc;
        
    -- Input register
    process(clk, rst)
    begin
        if rst = '1' then
            ddata_r <= (others => '0');
        else
            if rising_edge(clk) then

                if (d_rd = '1') and (dcsel = MY_CHIPSELECT) then
                    if to_unsigned(daddress, 32)(15 downto 0) = (x"31") then
                        ddata_r <= adc_sample_data ;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
        -- Output register
    process(clk, rst)
    begin       
        if rst = '1' then
            channel_adc<=(others => '0');
        else
            if rising_edge(clk) then        
                if (d_we = '1') and (dcsel = MY_CHIPSELECT)then                 
                    -- ToDo: Simplify comparators
                    -- ToDo: Maybe use byte addressing?  
                    --       x"01" (word addressing) is x"04" (byte addressing)
                    -- Address comparator when more than one word is mapped here
                    --if to_unsigned(daddress, 32)(8 downto 0) = MY_WORD_ADDRESS then
                    --end if;
                    
                    if to_unsigned(daddress, 32)(15 downto 0) = (x"30") then
                        channel_adc <= ddata_w;
                    end if;
                end if;
            end if;
        end if;     
    end process;
end architecture rtl;
