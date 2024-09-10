-------------------------------------------------------------------
-- Name        : BCD_to_7seg_display_tb.vhd
-- Author      : Elvis Fernandes
-- Version     : 0.1
-- Copyright   : Departamento de Eletrônica, Florianópolis, IFSC
-- Description : Tarefa 11: subprogramas
-- Date        : 11/07/2024
-------------------------------------------------------------------
--Implemente um pacote que contenha a função especificada abaixo.
--Desenvolva usando a simulação.
--Sintetize e teste no kit DE10-Lite.
--Analise a quantidade de hardware utilizado no resultado da síntese.
--Escreva uma função que faz a conversão de 4-bits BCD para display de 7-segmentos (0 a 0xF).
--Use um vetor (array) constante para definir a tabela.
--Escreve outra função que recebe um número de 8-bits e converte para dois diplays de 7 segmentos. Use a função acima.
--Teste utilizando 2 displays de 7 segmentos e um contador síncrono.
-------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.bcd_to_7seg_pkg.all;


entity BCD_to_7seg_display_tb is
end BCD_to_7seg_display_tb;

architecture Behavioral of BCD_to_7seg_display_tb is
    -- Declaração dos sinais para o teste
    signal bcd_input : std_logic_vector(7 downto 0) := "00000000";
    --signal seven_seg_output : std_logic_vector(15 downto 0);
	signal seven_seg_output_1 : std_logic_vector(7 downto 0); -- Alterado para acomodar um display
    signal seven_seg_output_2 : std_logic_vector(7 downto 0); -- Alterado para acomodar um display

begin

    -- Instanciação do componente a ser testado
    UUT : entity work.BCD_to_7seg_display
    port map (
        bcd_input => bcd_input,
        --seven_seg_output => seven_seg_output
		seven_seg_output_1 => seven_seg_output_1,
		seven_seg_output_2 => seven_seg_output_2
    );

    -- Processo de simulação
    process
    begin
        -- Teste de cada número BCD de 0 a F
        for i in 0 to 15 loop
            bcd_input <= std_logic_vector(to_unsigned(i, bcd_input'length));
            wait for 10 ns; -- Atraso para observar o resultado
        end loop;

        -- Finalização da simulação
        wait;
    end process;

end Behavioral;