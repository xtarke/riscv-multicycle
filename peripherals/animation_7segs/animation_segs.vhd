-------------------------------------------------------------------
-- Name        : animation_segs.vhd
-- Author      : Joana Wasserberg
-- Version     : 0.1
-- Copyright   : Joana, Departamento de Eletrônica, Florianópolis, IFSC
-- Description : Módulo top-level responsável por animar um display
--               de 7 segmentos com base em uma máquina de estados.
--               A direção da animação, velocidade e reset são
--               controlados por sinais de entrada.
--               A arquitetura conecta três componentes:
--               - divisor de clock (clock com velocidade ajustável),
--               - máquina de estados (controle da animação),
--               - codificador para display de 7 segmentos.
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity animation_segs is
    port(
        clk        : in std_logic;                         -- Clock principal do sistema
        direction  : in std_logic;                         -- Direção da animação ('0' para esquerda, '1' para direita)
        rst        : in std_logic;                         -- Sinal de reset síncrono para reiniciar a animação
        speed      : in std_logic_vector(1 downto 0);      -- Seleção da velocidade (2 bits = 4 velocidades possíveis)
        segs       : out std_logic_vector(7 downto 0)      -- Saída para os segmentos do display (ativo baixo ou alto, depende do hardware)
    );
end entity animation_segs;

architecture RTL of animation_segs is
	
    -- Sinais internos
    signal output_sig : std_logic_vector(3 downto 0);  -- Saída da FSM: valor binário da posição a ser exibida
    signal clk_output : std_logic;                     -- Clock dividido, com velocidade ajustável     
    
begin

    fsm_inst : entity work.fsm_animation_segs
    port map(
        direction => direction,
        rst       => rst,
        clk       => clk_output,	-- Clock ajustado pelo divisor
        output    => output_sig
    );

    seven_segs_inst : entity work.seven_segs
    port map(
        input => output_sig,
        segs => segs
    );

    clk_div_inst: entity work.divisor_clock
    port map(
        clk => clk,
        ena => '1',
		  rst => rst,
        speed => speed,
        clk_output => clk_output
    ); 

end architecture RTL;
