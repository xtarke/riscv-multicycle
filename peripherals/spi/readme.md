# SPI básico

Este módulo consiste em uma SPI-master com modo de operação em borda de subida e frequência de 500 khz.

O envio acontece na borda de subida e a recepção do dado acontece também em borda de subida,
porém, com defasagem de 1 ciclo de clock. Diferentemente do SPI tradicional, que opera em modos,
que são configurados para realizar o envio e o recebimento por alternância das bordas.

![](https://github.com/diogo0001/riscv-multicycle/blob/master/peripherals/spi/spi_blocks.PNG)

![](https://github.com/diogo0001/riscv-multicycle/blob/master/peripherals/spi/spi_edges.PNG)


### A seguir, a máquina de estados do sistema:

![](https://github.com/diogo0001/riscv-multicycle/blob/master/peripherals/spi/FSM.jpeg)


 ### A seguir, resultados do testbench do módulo:
 
 Para 8 bits :
 
 ![](https://github.com/diogo0001/riscv-multicycle/blob/master/peripherals/spi/testbench_8bits.PNG)
 
 Para 16 bits:
 
 ![](https://github.com/diogo0001/riscv-multicycle/blob/master/peripherals/spi/testbench_16bits.PNG)
 
 
 ### A seguir, imagens dos testes com osciloscópio
 
 Foram feitos testes com osciloscópio para verificar os sinais nos pinos
 
 Clock:
 
 ![](https://github.com/diogo0001/riscv-multicycle/blob/master/peripherals/spi/spi_clock_osciloscope.PNG)
 
 Dados no MOSI:
 
 ![](https://github.com/diogo0001/riscv-multicycle/blob/master/peripherals/spi/spi_mosi_osciloscope.PNG)
 
 Realimentando o MISO com MOSI. MOSI -> chaves, MISO -> leds.
 
 ![](https://github.com/diogo0001/riscv-multicycle/blob/master/peripherals/spi/spi_miso_leds.PNG)
 
 Pode-s observar que os leds são respectivos aos botões ativados.
 

