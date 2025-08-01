datasheet: https://www.analog.com/media/en/technical-documentation/data-sheets/max7219-max7221.pdf

**	Tópicos Principais:	**

--
Módulo MAX7219CN
--

--
** Possui um display de leds 8x8: **

1088AS Catodo-Comum
--

Precisa-se configurar uma PLL para gerar frequências menores que 10 MHz

período mínimo: 100 ns
Duty = 0.5
CS (queda) mínimo = 25 ns 

--

** Endereçamento: **

D15 - D12 /   D11 - D8  /    D7 - D0
 XXXXXX       Endereço     MSB Dado LSB
 
D0 - D7 -> do  endereço 0001 a 1000 o dado enviado corresponde ao valor da linha

--

Informações do datasheet

- CS must be low to clock data in or out.
	The data is latched into either the digit or control registers
	on the rising edge of LOAD/CS at the 16th rising edge

- LOAD/CS must go high
	concurrently with or after the 16th rising clock edge, but
	before the next rising clock edge or data will be lost.

input de clock (shift de bits) é ativo somente em CS low

-- ** Resultado: não funciona **


-----------------------------------------------------------------------------------

** 	Desenvolvimento:  **


Funcionamento do CI:
	
	- Como descrito pelo datasheet, o Circuito integrado funciona através da escrita síncrona do pino 'din' quando CS (chip select) está em nível lógico baixo
	- Modos de funcionamento: NOP (sem operação), digitos, modo decodificador, intensidade, scan de limite, shutdown, teste de dsplay
	- Como utilizar os modos: através da escrita síncorna de 'din', escreve-se no registrador interno de 16 bits, eles são escritos do MSB para o LSB sendo os 4 primeiros de don't care.
	  Esse registrador possui duas partes, uma é a de endereço e a outra de dado. Do endereço D11 a D8 está localizado a região de endereço e do D7 ao D0 a região de dados
	- O endereço seleciona a funcionalidade e o dado escreve um dado no registrador interno dessa funcionalidade - os dados são escritos após o 16° ciclo de clock e o pino CS em nível lógico alto - 
	- O nível lógico de CS precisa ser alto durante ou após o 16° subida de clock, mas antes da próxima subida. O dado escrito em desconformidade com essa regra é perdido 
	- O modo usado no shield é o de Dígitos, nele cada endereço corresponde a uma linha do display 8x8 de leds e cada bit de dado é correspondente a um led nele

Observações sobre o CI:

	- Ao utilizá-lo é necessário configurar uma PLL, pois o período mínimo de clock do circuito é de 100 ns (10 MHz).
	- Use uma fonte externa de alimentação.
	- Não foi encontrado quais eram os valores de corrente máximas que são drenadas pelos pinos do shield, então por precausão usou-se 3 mosfets bf245 e uma protoboard para ligá-los à placa MAX-DE10  
	

Como foi estruturado o código:

	- O Código foi feito pensando em uma máquina de estados separada nas funcionalidades do shield

	Entradas:

    clk: Clock Principal - frequência deve ser menor que 10 MHz.

    rst: Reset - Sinal de reset que, quando ativado ('1'), reinicia a maquina de estados para o estado inicial No_op.

    data: Dados (8 bits) - Barramento de 8 bits que contem o dado a ser enviado para o MAX7219. 

    modo: Modo de Operação (8 bits) - Barramento de 8 bits que funciona como o endereço. Ele determina qual registrador será escrito (ex: qual digito, o registrador de intensidade, modo de decodificação, etc.).

    program: Gatilho de Programação - Um pulso neste sinal deveria indicar que novos valores de modo e data estÃ£o prontos para serem enviados ao MAX7219, iniciando o ciclo de escrita. 


	Saídas:

    din: Data In (Serial) - A saída de dados seriais que se conecta ao pino DIN do MAX7219. Os dados são enviados bit a bit por esta linha.

    clk_out: Clock de Saída - O clock enviado para o pino CLK do MAX7219 para sincronizar a transferência de dados seriais.

    cs: Chip Select / Load - Esta saÃ­da se conecta ao pino CS (ou LOAD) do MAX7219. Quando em nível baixo ('0'), o MAX7219 aceita os dados seriais. Um pulso de baixo para alto trava (latches) os dados recebidos nos registradores internos.


Atualmente, o código implementa parcialmente a funcionalidade do controlador.

Máquina de Estados: O controle central é feito por uma máquina de estados (process estados) com um estado inicial No_op (Nenhuma Operação).

Modo de Escrita de Dígitos: A principal funcionalidade implementada é a escrita de dados nos registradores de dígitos (endereços de 0x01 a 0x08).

    Quando a máquina de estados está em No_op e a entrada modo indica um endereço de dígito (o código verifica especificamente modo = x"01", mas a intenção parece ser para todos os dígitos), o estado muda para Digitos.

    No estado Digitos, o processo saidas assume o controle:

        Ele concatena os 8 bits de modo e os 8 bits de data para formar um pacote de 16 bits (reg_din).

        Ativa o chip select (cs <= '0') para habilitar a recepção de dados pelo MAX7219.

        Gera um clock de saída (clk_out) e, a cada ciclo, envia um bit do pacote de 16 bits pela saída din, do mais significativo (MSB) para o menos significativo (LSB). Isso é controlado por um contador de 8 bits (counter_8bits) que conta de 0 a 15.

        Após enviar os 16 bits, ele desativa o chip select (cs <= '1') e gera um sinal de termino.

    O sinal de termino faz com que a máquina de estados retorne ao estado No_op, aguardando a próxima instrução.




Simulação:

	- Simulando o circuito pode-se ver: os sinais de entrada e saída do módulo e sinais internos (clk, rst,data,modo,clk_out cs,din, program, estado e termino)
	- Analisando as formas de onda o modulo parece funcional, exibindo o comportamento parecido com o desejado, porém posteriormente foi visto que parece que o dado está atrasado meio ciclo de clock e quando chega-se ao 'termino'
	o periodo de permanencia do sinal de CS é muito curto, o que pode inviabilizar a leitura desse dado, fazendo com que toda a escrita seja perdida.

Síntese:

	- Para fazer a síntese foram usadas probes (18 bits de source e 3 de probe) para analisar sinais externos e de controle.



Frustações: 
	- Como não foi feita a análise dos sinais utilizando o osciloscópio, não foi possível analisar a conformidade das restrições temporais do ciruito, inviabilizando uma análise mais a fundo dos problemas enfrentados.

