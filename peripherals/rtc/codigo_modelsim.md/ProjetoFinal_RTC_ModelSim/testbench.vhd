-------------------------------------------------------------------
-- Name        : testbench.vhd
-- Author      : Thais Silva Lisatchok
-- Created     : 08/07/2025
-- Description : Este é um testbench para verificar o funcionamento 
--               do rtl em VHDL.
-------------------------------------------------------------------

-- bibliotecas e cláusulas
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-------------------------------------
entity testbench is
end entity testbench;
------------------------------
architecture behavior of testbench is

    -- sinais de clock e reset
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';

    -- sinais de saída do rtc
    signal sec   : std_logic_vector(7 downto 0);
    signal min   : std_logic_vector(7 downto 0);
    signal hour  : std_logic_vector(7 downto 0);
    signal day   : std_logic_vector(7 downto 0);
    signal month : std_logic_vector(7 downto 0);
    signal year  : std_logic_vector(15 downto 0);

    -- período de clock
    constant clk_period : time := 10 ns;

begin

    -- instância do rtc (uut - unidade sob teste)
    uut: entity work.rtc
        port map (
            clk   => clk,
            rst   => rst,
            sec   => sec,
            min   => min,
            hour  => hour,
            day   => day,
            month => month,
            year  => year
        );

    -- processo de clock (oscilação contínua)
    clk_process: process
    begin
        while now < 10 ms loop  -- simula até 10ms (equivalente a 10 "segundos lógicos")
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
        wait;  -- finaliza simulação automaticamente
    end process;

    -- processo de reset e monitoramento
    stim_proc: process
    begin
        -- gera reset
        rst <= '1';
        wait for 20 ns;
        rst <= '0';

        -- aguarda o rtc começar a contar
        wait for 50 ns;

        -- monitoramento da contagem por tempo definido
        for i in 0 to 100 loop  -- exibe 100 ciclos
            wait for clk_period;
            report "time = " & time'image(now) &
                   " | " &
                   "hora: " & integer'image(to_integer(unsigned(hour))) & ":" &
                   integer'image(to_integer(unsigned(min))) & ":" &
                   integer'image(to_integer(unsigned(sec))) &
                   "  data: " & integer'image(to_integer(unsigned(day))) & "/" &
                   integer'image(to_integer(unsigned(month))) & "/" &
                   integer'image(to_integer(unsigned(year(15 downto 8)))) & 
                   integer'image(to_integer(unsigned(year(7 downto 0))));
        end loop;

        wait;
    end process;

end behavior;