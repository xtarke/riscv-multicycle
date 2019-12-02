# SPI básico

Este módulo consiste em uma SPI-master com modo de operação em borda de subida para o envio (MOSI).

Frequência de envio: 500 khz

### A seguir, a máquina de estados do sistema:

![](https://github.com/diogo0001/riscv-multicycle/blob/master/peripherals/spi/FSM.jpeg)

Foi implementado o MISO, porém este necessita de uma defasagem ou operar em borda de descida.
Ele recebe, porém ocorre um deslocamento, pois pega o valor anterior no primeiro bit (zero).

No testbench pode-se ver o valor enviado (xA9) e o valor recebido (x54, 1 bit deslocado pra direita),
as ondas aparecem iguais pois é o mesmo sinal que realimenta MOSI->MISO, mas o registro é deslocado.

 ### A seguir, um resultado do testbench do módulo:
 
 ![](https://github.com/diogo0001/riscv-multicycle/blob/master/peripherals/spi/testbench.PNG)
 
 
 ### A seguir, imagens dos testes com osciloscópio
 
 Foram feitos testes com osciloscópio para verificar os sinais nos pinos
 
 Clock:
 
 ![](https://github.com/diogo0001/riscv-multicycle/blob/master/peripherals/spi/spi_clock_osciloscope.PNG)
 
 Dados no MOSI:
 
 ![](https://github.com/diogo0001/riscv-multicycle/blob/master/peripherals/spi/spi_mosi_osciloscope.PNG)
 
 Realimentando o MISO com MOSI. MOSI -> chaves, MISO -> leds
 
 ![](https://github.com/diogo0001/riscv-multicycle/blob/master/peripherals/spi/spi_miso_leds.PNG)
 
 Pode-se observar o mesmo deslocamento ocorrido no testbench, os leds acesos estão deslocados em 1 bit para a direita.
