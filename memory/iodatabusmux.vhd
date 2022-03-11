-------------------------------------------------------
--! @file
--! @brief RISCV Simple io data bux mux.
--         Multiplex io data bus accordingly to address space. 
--         See hardware.h (software/_core directory)
--         Address space is multiplexed using WORD address.
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity iodatabusmux is
    port(
        daddress                : in  unsigned(31 downto 0); --! Connect to RISC-V data bus address 

        ddata_r_gpio            : in  std_logic_vector(31 downto 0);
        ddata_r_segments        : in  std_logic_vector(31 downto 0);
        ddata_r_uart            : in  std_logic_vector(31 downto 0);
        ddata_r_adc             : in  std_logic_vector(31 downto 0);
        ddata_r_i2c             : in  std_logic_vector(31 downto 0);
        ddata_r_timer           : in  std_logic_vector(31 downto 0);
        ddata_r_dif_fil         : in  std_logic_vector(31 downto 0);
        ddata_r_stepmot         : in  std_logic_vector(31 downto 0);
        ddata_r_lcd             : in  std_logic_vector(31 downto 0);
        ddata_r_nn_accelerator  : in   std_logic_vector(31 downto 0);
        -- Mux 
        ddata_r_periph   : out std_logic_vector(31 downto 0) --! Connect to data bus mux
    );

end entity iodatabusmux;

architecture RTL of iodatabusmux is

begin
    -- Word address, ignoring least significant 4 bytes

    with daddress(19 downto 4) select ddata_r_periph <=
        ddata_r_gpio when x"0000",
        ddata_r_segments when x"0001",
        ddata_r_uart when x"0002",
        ddata_r_adc when x"0003",
        ddata_r_i2c when x"0004",
        ddata_r_timer when x"0005",
        ddata_r_dif_fil when x"0008",
        ddata_r_stepmot when x"0009",
        ddata_r_lcd when x"000A",
        ddata_r_nn_accelerator when x"000B",  
        -- Add new io peripherals here
        (others => '0') when others;

end architecture RTL;
