# SPI básico

Este módulo consiste em uma SPI com modo de operação em borda de subida para o envio (MOSI).

Frequência de envio: 500 khz

Foi implementado o MISO, porém este necessita de uma defasagem ou operar em borda de descida.
Ele recebe, porém ocorre um deslocamento, pois pega o valor anterior no primeiro bit (zero).

 A seguir, um resultado do testbench do módulo:
 
 ![](https://github.com/diogo0001/riscv-multicycle/blob/master/peripherals/spi/testbench.PNG)
