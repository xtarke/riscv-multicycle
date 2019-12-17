# SPI

Este módulo consiste em uma SPI-master com modo de operação em borda de subida e frequência de 500 khz.

O envio acontece na borda de subida e a recepção do dado acontece também em borda de subida,
porém, com defasagem de 1 ciclo de clock. Diferentemente do SPI tradicional, que opera em modos,
que são configurados para realizar o envio e o recebimento por alternância das bordas.

![](https://github.com/diogo0001/riscv-multicycle/blob/master/peripherals/spi/images/spi_blocks.PNG)

![](https://github.com/diogo0001/riscv-multicycle/blob/master/peripherals/spi/images/spi_edges.PNG)

(Fonte: https://www.analog.com/en/analog-dialogue/articles/introduction-to-spi-interface.html)


### A seguir, a máquina de estados do sistema:

![](https://github.com/diogo0001/riscv-multicycle/blob/master/peripherals/spi/images/FSM.jpeg)

## Biblioteca e uso

A bibioteca escrita em C oferece 2 funções:

 - void spi_write(uint8_t data)
 - uint8_t spi_read(void);
 
 Para compilar é necessário editar o Makefile para adicionar o arquivo spi.o e configurar para o main_spi.c (Para testar pode-se escrever no arquivo firmware.c que já está configurado)

## Resultados

 ### A seguir, resultados do testbench do módulo:
 
 Para 8 bits :
 
 ![](https://github.com/diogo0001/riscv-multicycle/blob/master/peripherals/spi/images/testbench_8bits.PNG)
 
 Para 16 bits:
 
 ![](https://github.com/diogo0001/riscv-multicycle/blob/master/peripherals/spi/images/testbench_16bits.PNG)
 
 
 ### A seguir, imagens dos testes com osciloscópio
 
 Foram feitos testes com osciloscópio para verificar os sinais nos pinos
 
 Clock:
 
 ![](https://github.com/diogo0001/riscv-multicycle/blob/master/peripherals/spi/images/spi_clock_osciloscope.PNG)
 
 Dados no MOSI:
 
 ![](https://github.com/diogo0001/riscv-multicycle/blob/master/peripherals/spi/images/spi_mosi_osciloscope.PNG)
 
 Realimentando o MISO com MOSI. MOSI -> chaves, MISO -> leds.
 
 ![](https://github.com/diogo0001/riscv-multicycle/blob/master/peripherals/spi/images/spi_miso_leds.PNG)
 
 Pode-s observar que os leds são respectivos aos botões ativados.
 
 ### Testbench de integração 
 
 Foi feito um contador como dado de envio e um jumper entre MISO e MOSI
 
 ![](https://github.com/diogo0001/riscv-multicycle/blob/master/peripherals/spi/images/core_tb_sim.PNG)
 
 ![](https://github.com/diogo0001/riscv-multicycle/blob/master/peripherals/spi/images/core_tb_sim_expand.PNG)
 
 ### Resultados da síntese
 
 Foi implementado o mesmo contador e jumper entre MISO e MOSI
 
 ![](https://github.com/diogo0001/riscv-multicycle/blob/master/peripherals/spi/images/osc_spi_gifs.gif)
 

