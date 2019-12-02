# SPI básico

Este módulo consiste em uma SPI-master com modo de operação em borda de subida.

Frequência de envio: 500 khz

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
 

