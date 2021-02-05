library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity periphdatabusmux is
    generic(
    DMEMORY_WORDS : integer := 1024    --!= 2k (512 * 2) bytes        
    );
    port(
       
        daddress: in  integer range 0 to DMEMORY_WORDS-1;
        -- Adjust inputs accordingly peripherals 
        ddata_r_gpio       : in    std_logic_vector(31 downto 0);
        ddata_r_segments : in std_logic_vector(31 downto 0);
        ddata_r_uart: in std_logic_vector(31 downto 0);
        ddata_r_adc: in std_logic_vector(31 downto 0);
        ddata_r_i2c: in std_logic_vector(31 downto 0);
        ddata_r_timer: in std_logic_vector(31 downto 0);
        
        
        -- Mux 
        ddata_r_periph     : out   std_logic_vector(31 downto 0)
    );
end entity periphdatabusmux;

architecture RTL of periphdatabusmux is
        
    
begin
    
    with to_unsigned(daddress,16)(15 downto 4) select 
        ddata_r_periph <= ddata_r_gpio when x"000",
                          ddata_r_segments when x"001",
                          ddata_r_uart when x"002",
                          ddata_r_adc when x"003",
                          ddata_r_i2c when x"004",
                          ddata_r_timer when x"005",
                          (others => '0')when others;
              

end architecture RTL;
