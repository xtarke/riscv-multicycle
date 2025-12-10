-------------------------------------------------------------------
-- Name        : rng.vhd
-- Author      : Elisa Anes Romero
-- Version     : 0.2
-- Description : Random number generator - read only version
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rng is
    port(
        clk        : in std_logic;  -- clock do sistema
        rst        : in std_logic;  -- reset síncrono
        chip_select : in std_logic; -- ativa este periférico
        addr        : in std_logic_vector(1 downto 0);  -- seleciona registrador
        read_data   : out std_logic_vector(31 downto 0) -- valor lido pelo CPU
    );
end entity rng;


architecture RTL of rng is

    -- LFSR de 16 bits com seed fixa
    signal lfsr     : std_logic_vector(15 downto 0) := x"ACE1";
    signal feedback : std_logic;

begin

    -------------------------------------------------------------------
    -- Polinômio do LFSR (maximal length)
    -- x^16 + x^13 + x^9 + x^6 + 1
    -------------------------------------------------------------------
    feedback <= lfsr(15) xor lfsr(12) xor lfsr(8) xor lfsr(5);

    -------------------------------------------------------------------
    -- Processo principal: LFSR gera novo número a cada ciclo
    -------------------------------------------------------------------
    process(clk, rst)
    begin
        if rst = '1' then
            -- Seed fixa – não pode ser alterada por software
            lfsr <= x"ACE1";
        elsif rising_edge(clk) then
            -- shift para a esquerda e insere feedback no bit 0
            lfsr <= lfsr(14 downto 0) & feedback;
        end if;
    end process;


    -------------------------------------------------------------------
    -- Leitura: somente leitura, sem registradores de controle
    -------------------------------------------------------------------
    process(chip_select, addr, lfsr)
    begin
        if chip_select = '1' then
            case addr is
                when "00" =>  -- RNG_VALUE
                    read_data <= x"0000" & lfsr;
                when others =>
                    read_data <= (others => '0');
            end case;
        else
            read_data <= (others => '0');
        end if;
    end process;

end architecture RTL;
