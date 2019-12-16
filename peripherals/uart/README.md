# UART
---

O periférico realiza a comunicação UART com um baudrate variavel (4800 até 38400). Tanto a transmissão quanto a recepção foram implementados e testados no Kit de desenvolvimento DE-10 Lite.

É importante ressaltar a síntese da PLL para gerar os clocks utilizados:

	- Output clocks: 
		- clk c0 em 1 MHz
		- clk c1 em 0.00960000 MHz (9600 Hz)

Pode ser configurado o baud rate e o bit de paridade (se exitira ou não e se par ou impar) atravez dos bits de configuração.

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

Para configurar baudrate e bit de paridade
```//UART_setup(X, Y);
Onde	X = 0 baud rate = 38400
	X = 1 baud rate = 19200
	X = 2 baud rate = 9600
	X = 3 baud rate = 4800
	
Onde	Y = 0 paridade off
	Y = 1 paridade off
	Y = 2 paridade impar
	Y = 3 paridade par
