-- dig_filt.vhd
--  Created on: out 12, 2020
--     Author: Tarcis Becher
--      Instituto Federal de Santa Catarina
--
-- Digital filter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dig_filt is
    generic (
        --! Chip selec
        MY_CHIPSELECT : std_logic_vector(1 downto 0) := "10";
        MY_WORD_ADDRESS : unsigned(15 downto 0) := x"0080";
        DADDRESS_BUS_SIZE : integer := 32;
        G_NBIT                     : integer := 32;
        G_AVG_LEN_LOG              : integer := 2   --2^2 tamanho filtro
    );

    port(
        clk : in std_logic;
        rst : in std_logic;

        -- Core data bus signals
        -- ToDo: daddress shoud be unsgined
        daddress  : in  unsigned(DADDRESS_BUS_SIZE-1 downto 0);
        ddata_w	  : in 	std_logic_vector(31 downto 0);
        ddata_r   : out	std_logic_vector(31 downto 0);
        d_we      : in std_logic;
        d_rd	  : in std_logic;
        dcsel	  : in std_logic_vector(1 downto 0);	--! Chip select 
        -- ToDo: Module should mask bytes (Word, half word and byte access)
        dmask     : in std_logic_vector(3 downto 0);	--! Byte enable mask

        -- hardware input/output signals	
        data_in : 	in     std_logic_vector(G_NBIT-1 downto 0)


    );
end entity dig_filt;

architecture RTL of dig_filt is

    type reg_array is array (0 to 2**G_AVG_LEN_LOG-1) of signed(G_NBIT-1 downto 0);
    signal registers                        : reg_array;
    signal r_acc                            : signed(G_NBIT+G_AVG_LEN_LOG-1 downto 0);  -- average accumulator
    signal data_ena                         : std_logic;
    signal data_out                         : std_logic_vector(G_NBIT-1 downto 0);
    signal data_reset                       : std_logic;


begin


    -- Process give output value -- processo escritura barramento Barramento
    process(clk, rst)
    begin
        if rst = '1' then
            ddata_r <= (others => '0');
        else
            if rising_edge(clk) then
                if (d_rd = '1') and (dcsel = MY_CHIPSELECT) then
                    if daddress(15 downto 0) = MY_WORD_ADDRESS  then 	-- core reading DIG_FILT_CTRL
                        ddata_r(0)<= data_ena;
                    elsif daddress(15 downto 0) = MY_WORD_ADDRESS + 4 then -- core reading DIG_FILT_IN
                        ddata_r <= data_out ;
                    elsif daddress(15 downto 0) = MY_WORD_ADDRESS + 2 then -- core reading DIG_FILT_OUT
                        --ddata_r <= mem_data_out;
                        -- ED debug_hex5 <= mem_data_out(3 downto 0);
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Process give input value -- processo leitura barramento Barramento
    process(clk, rst)
    begin
        if rst = '1' then
            data_ena <= '0';
            data_reset <= '0';
        else

            if rising_edge(clk) then
                if (d_we = '1') and (dcsel = MY_CHIPSELECT) then
                    if daddress(15 downto 0) = (MY_WORD_ADDRESS) then
                        data_ena <= ddata_w(0);
                        data_reset <= ddata_w(1);
                    end if;

                end if;
            end if;
        end if;
    end process;

   
    p_average : process(clk,rst)


    begin
        if(rst='1' or data_reset='1') then
            r_acc                <= (others=>'0');
            registers   <= (others=>(others=>'0'));
            data_out             <= (others=>'0');
            
        elsif(rising_edge(clk)) then

            if(data_ena='1') then
               registers   <= signed(data_in)& registers(0 to registers'length-2);                
               r_acc              <= r_acc + signed(data_in) - signed(registers(registers'length-1));
            
            end if;
            data_out  <= std_logic_vector(r_acc(G_NBIT+G_AVG_LEN_LOG-1 downto G_AVG_LEN_LOG));  -- divide by 2^G_AVG_LEN_LOG

        end if;
    end process p_average;




end architecture RTL;
