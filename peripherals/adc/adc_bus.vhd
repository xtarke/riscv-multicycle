-------------------------------------------------------------------
-- Name        : de0_lite.vhd
-- Author      : Renan Augusto Starke
-- Modified    : Leticia de Oliveira Nunes e Marieli Matos
--             : Renan Augusto Starke
-- Version     : 0.2
-- Copyright   : Departamento de Eletrônica, Florianópolis, IFSC
-- Description : riscV ADC 
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc_bus is
    generic(
        MY_CHIPSELECT : std_logic_vector(1 downto 0)    := "10"; --  ddata_r_periph when "10" -- ver databusmux
        MY_WORD_ADDRESS : unsigned(15 downto 0)          := x"0030"; 
        DADDRESS_BUS_SIZE : integer := 32
    );
    port(
        clk         : in std_logic;
        rst         : in std_logic;
        clk_adc     : in std_logic;
        
        -- Core data bus signals
        daddress  : in  unsigned(DADDRESS_BUS_SIZE-1 downto 0);
        ddata_w     : in  std_logic_vector(31 downto 0);  --! Data to write
        ddata_r     : out std_logic_vector(31 downto 0); --! Data from memory bus
        d_we        : in std_logic; --! Write signal
        d_rd        : in std_logic;--! Read signal
        dcsel       : in std_logic_vector(1 downto 0);    --! Chip select 
        -- ToDo: Module should mask bytes (Word, half word and byte access)
        dmask       : in std_logic_vector(3 downto 0);   --! Byte enable mask
    
        -- hardware input/output signals: ADC module uses hardwire pin (see DE10-LITE Manual)

        --interrupts
        adc_interrupt : out std_logic_vector(1 downto 0)

    );
end entity adc_bus;

architecture rtl of adc_bus is
    
    signal cur_adc_ch                : std_logic_vector(4 downto 0);
    signal adc_sample_data           : std_logic_vector(31 downto 0);  
    
    signal adc_out_clk               : std_logic;
    signal channel_adc               : std_logic_vector(31 downto 0);
    signal command_ready             : std_logic;
    signal response_valid            : std_logic;
    signal response_channel          : std_logic_vector(4 downto 0);
    signal response_data             : std_logic_vector(11 downto 0);
    signal response_startofpacket    : std_logic;
    signal response_endofpacket      : std_logic;   
    signal reset_n                   : std_logic;

    -- Interrupt signal
	signal flag_irq_en : std_logic := '0';
    signal flag_irq_dis: std_logic := '0';
    signal irq_adc : std_logic := '0';

begin
    qsys : entity work.adc_qsysbus
        port map(
            reset_reset_n                        => reset_n,
            clk_clk                              => clk_adc,
            modular_adc_0_command_valid          => '1',
            modular_adc_0_command_channel        => channel_adc(4 downto 0),
            modular_adc_0_command_startofpacket  => '1',
            modular_adc_0_command_endofpacket    => '1',
            modular_adc_0_command_ready          => command_ready,
            clock_bridge_sys_out_clk_clk         => adc_out_clk,
            modular_adc_0_response_valid         => response_valid,             -- modular_adc_0_response.valid
            modular_adc_0_response_channel       => response_channel,           -- channel
            modular_adc_0_response_data          => response_data,              -- data
            modular_adc_0_response_startofpacket => response_startofpacket,     -- startofpacket
            modular_adc_0_response_endofpacket   => response_endofpacket        -- endofpacket
            );   
    
    reset_n <= not rst;                
          
    -- Read ADC
    read_adc: process(clk_adc, reset_n) --adc_out_clk
    begin
        if reset_n = '0' then
            adc_sample_data <= (others => '0');
            cur_adc_ch      <= (others => '0');
        else
            if (rising_edge(clk_adc) and response_valid = '1') then
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
                    if daddress(15 downto 0) = (MY_WORD_ADDRESS + x"0001") then
                        ddata_r <= adc_sample_data;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    -- Output register
    process(clk, rst, flag_irq_en)
    begin       
        if rst = '1' then
            channel_adc<=(others => '0');
            flag_irq_en <= '0';
            flag_irq_dis <= '0';
        else
            if rising_edge(clk) then        
                if (d_we = '1') and (dcsel = MY_CHIPSELECT) then
                    -- ativa a interrupção
                    if daddress(15 downto 0) = (MY_WORD_ADDRESS + x"0002") then
                        flag_irq_en <= ddata_w(0);

                    elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + x"0000")then
                        channel_adc <= ddata_w;
                        flag_irq_dis <= '1';

                    -- desabilita a interrupção
                    elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + x"0003") then
                        flag_irq_dis <= '0'; 
                    end if;
                end if;
            end if;
        end if;     
    end process;


    interrupt_proc: process(clk, rst)
	begin
	    if rst = '1' then 
            adc_interrupt <= (others => '0');	    
		elsif rising_edge(clk) then
		    adc_interrupt(1) <= '0'; 
			if flag_irq_en = '1' and flag_irq_dis = '1' and irq_adc = '0' then
				adc_interrupt(0) <= '1';
			else
                adc_interrupt(0) <= '0'; 
			end if;
            irq_adc <= flag_irq_dis;
		end if;
	end process;
end architecture rtl;
