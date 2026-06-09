-------------------------------------------------------
--! @file   can.vhd
--! @author Christopher Costa & Rafael Suzin
--! @date   09/06/2026
--! @brief  VHDL implementation of a CAN controller.
--! @version 0.0.1
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity can is
    port(
        -- Transceiver side ports
        TXCAN : out std_logic;
        RXCAN : in std_logic;

        -- @TODO
        -- comunicação com o restante do processado e memória

        -- Clock and reset inputs
        clk :   in std_logic;
        rst :   in std_logic
    );
end entity can;

architecture RTL of can is

    -- Registers



begin

    -- CAN protocol engine


    -- SOF process


    -- CRC process


    -- ACK process


    -- Bit stuffing 


    -- Config process

    
end architecture RTL;

