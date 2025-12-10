# Síntese e Integração do Periférico RNG com o Softcore

## Introdução

Este projeto implementa e sintetiza um **periférico de geração de números pseudoaleatórios (RNG)** em **VHDL**, integrado ao **processador softcore** desenvolvido no projeto do IFSC.

O objetivo é testar a comunicação entre o **hardware sintetizado na FPGA** e o **software em linguagem C** executado no softcore, que realiza a leitura contínua dos valores gerados pelo RNG.

<img src="../imagens/rng_bus_softcore.png" title="" alt="Bloco do periférico integrado com softcore." data-align="center">

O código em C lê o pseudo-rng a cada determinado tempo e mostra o numero gerado no display.

<img src="../imagens/softcore.mp4" title="" alt="Periférico rodando com código em C." data-align="center">


## Sugestões de melhorias

Uma possível melhoria seria utilizar ruído do ADC como entrada do polinômio, assim teríamos um verdadeiro gerador de números aleatórios.



