# UART
---

O periférico realiza a comunicação UART com um baudrate variável (4800 até 38400). Tanto a transmissão quanto a recepção foram implementados e testados no Kit de desenvolvimento DE-10 Lite.

Descrição de entradas e saídas do componentes:
* clk_in_1M	: Clock de entrada que será utilizado para os processos das máquinas de estado Moore e para sinalização de interrupção;
* clk_baud	: Clock relacionado à transmissão e recepção de dados;
* csel		: Habilita que o dado seja enviado no tx da UART;
* data_in		: Dado de 8 bits que será transmitido na UART;
* tx 			: Transmissor de dados;
* tx_cmp		: Sinalizador que o pino tx está sendo utilizado;
* data_out	: Dado recebido através do rx da UART;
* rx			: Receptor de dados;
* rx_cmp		: Sinalizador que o pino rx está recebendo algum dado;
* interrupt : Flag utilizada para sinalizar uma interrupção quando a interrupção para o periférico está habilitada;
* config_all  : Vetor de 32 bits utilizados para configuração do periférico

É importante ressaltar a síntese da PLL para gerar os clocks utilizados:

- Output clocks:
	- clk c0 em 1 MHz
	- clk c1 em 0.00960000 MHz (9600 Hz)

Pode ser configurado o baudrate e o bit de paridade par ou ímpar através dos bits de configuração.

O periférico feito possui ainda dois pinos que não foram conectados: tx_cmp e rx_cmp. O primeiro indica o término do envio ("tx complete") e o segundo o término da leitura de um byte ("rx complete"). Eles podem ser utilizados no futuro para sincronizar o envio e recepção por pooling.

## Getting Started (software):

Para transmissão de um carácter basta utilizar a função UART_write(carácter).

```C
// Testing UART - Transmission
UART_write('a');
delay_(1000); // Necessário para não perder sincronia.
```

Para recepçao de um carácter utilize a função UART_read().
```C
// Testint UART - Reception
int x;
x = UART_read();
OUTBUS = x;
delay_(1000); // Necessário para não perder sincronia.
```

O controle do baudrate é feito através de múltiplas divisões do maior baudrate.

O bit de paridade é criado, quando requisitado, na maquina de estados através da adição de um bit extra a palavra enviada. O numero de 1's é contado através de uma função separada e de acordo com as configurações se define paridade par ou impar.

Para configurar baudrate e bit de paridade
```C
UART_setup(X, Y);
/*  Onde	X = 0 baud rate = 38400
	X = 1 baud rate = 19200
	X = 2 baud rate = 9600
	X = 3 baud rate = 4800

Onde	Y = 0 paridade off
	Y = 1 paridade off
	Y = 2 paridade impar
	Y = 3 paridade par */
```

### Utilizando a interrupção

Para utilizar interrupções externas e ler um novo dado quando este é recebido, deve-se, primeiramente, habilitar a interrupção da UART implementando trecho de código na aplicação

```C
UART_interrupt_enable();

extern_interrupt_enable(true);
global_interrupt_enable(true);
```

Segundo, a função de callback deverá ser implementada e a função ``UART_read()`` deverá ser utilizada para ler os dados recebidos quando ocorrer a interrupção, conforme o bloco de código exemplo abaixo:

```C
void UART_IRQHandler(void){
	uint8_t data;

	data = UART_read();

	OUTBUS = data;
	HEX0 = data;
	HEX1 = data >> 4;
}
```
Com isso, quando um novo dado é recebido na UART, imprime-se nos display de 7 segmentos e nos LEDs o byte recebido na UART.
