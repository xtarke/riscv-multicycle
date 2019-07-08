# UART
---

O periférico realiza a comunicação UART com um baudrate fixo de 9600. Tanto a transmissão quanto a recepção foram implementados e testados no Kit de desenvolvimento DE-10 Lite.

É importante ressaltar a síntese da PLL para gerar os clocks utilizados:

	- Output clocks: 
		- clk c0 em 1 MHz
		- clk c1 em 0.00960000 MHz (9600 Hz)

O periférico feito possui ainda dois pinos que não foram conectados: tx_cmp e rx_cmp. O primeiro indica o término do envio ("tx complete") e o segundo o término da leitura de um byte ("rx complete"). Eles podem ser utilizados no futuro para sincronizar o envio e recepção por pooling.
		
## Getting Started (software):

Para transmissão de um carácter basta utilizar a função UART_write(carácter).

```// Testing UART - Transmission```
```UART_write('a');```
```delay_(1000); // Necessário para não perder sincronia.```

Para recepçao de um carácter utilize a função UART_read().
```// Testint UART - Reception```
```int x;```
```x = UART_read();```
```OUTBUS = x;```
```delay_(1000); // Necessário para não perder sincronia.```
