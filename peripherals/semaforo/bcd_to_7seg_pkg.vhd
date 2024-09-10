-------------------------------------------------------------------
-- Name        : bcd_to_7seg_pkg.vhd
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

package bcd_to_7seg_pkg is
    -- Tabela de conversão de BCD para display de 7 segmentos
    type seg_array is array (natural range 0 to 15) of std_logic_vector(7 downto 0);

    constant bcd_to_7seg_table : seg_array :=
        (0 => "11000000", -- 0
         1 => "11111001", -- 1
         2 => "10100100", -- 2
         3 => "10110000", -- 3
         4 => "10011001", -- 4
         5 => "10010010", -- 5
         6 => "10000010", -- 6
         7 => "11111000", -- 7
         8 => "10000000", -- 8
         9 => "10010000", -- 9
         10 => "10001000", -- A
         11 => "10000011", -- B
         12 => "11000110", -- C
         13 => "10100001", -- D
         14 => "10000110", -- E
         15 => "10001110");-- F

    -- Função para converter um número BCD de 4 bits para um display de 7 segmentos
    function bcd_to_7seg(bcd_input : std_logic_vector(3 downto 0)) return std_logic_vector;
    
    -- Tamanho dos vetores de entrada e saída
    constant input_width : integer := 8;
    constant output_width : integer := 16;

    -- Tipos para os vetores de entrada e saída
    subtype input_vector is std_logic_vector(input_width - 1 downto 0);
    subtype output_vector is std_logic_vector(output_width - 1 downto 0);

    -- Função para converter um número de 8 bits para dois displays de 7 segmentos
    function convert_8bits_to_dual_7seg(input_value : input_vector) return output_vector;
end bcd_to_7seg_pkg;

package body bcd_to_7seg_pkg is
    -- Implementação da função para converter um número BCD de 4 bits para um display de 7 segmentos
    function bcd_to_7seg(bcd_input : std_logic_vector(3 downto 0)) return std_logic_vector is
    begin
        return bcd_to_7seg_table(to_integer(unsigned(bcd_input)));
    end function;

    -- Implementação da função para converter um número de 8 bits para dois displays de 7 segmentos
    function convert_8bits_to_dual_7seg(input_value : input_vector) return output_vector is
        variable result : output_vector;
    begin
        -- Converte os primeiros 4 bits para o primeiro display de 7 segmentos
        result(15 downto 8) := bcd_to_7seg(input_value(7 downto 4));
        
        -- Converte os últimos 4 bits para o segundo display de 7 segmentos
        result(7 downto 0) := bcd_to_7seg(input_value(3 downto 0));
        
        return result;
    end function;
end bcd_to_7seg_pkg;