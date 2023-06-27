# UART
---

O periférico realiza a comunicação UART com um baudrate variável (4800 até 38400). Tanto a transmissão quanto a recepção foram implementados e testados no Kit de desenvolvimento DE-10 Lite.

Descrição de entradas e saídas do componentes:
* clk	: Clock de entrada que será utilizado para os processos das máquinas de estado Moore e para sinalização de interrupção;
* rst   : Reset o funcionamento da UART;
* clk_baud	: Clock relacionado à transmissão e recepção de dados;
* daddress   : Endereço dos dados a serem lidos ou escritos; 
* ddata_w    : Dado de 32 bits para a escrita na memória do periférico;
* ddata_r    : Dado de 32 bits para a leitura na memória do periférico;
* d_we       : Sinal para habilitar a escrita na memória;
* d_rd       : Sinal para habilitar a leitura na memória;
* dcsel      : Dado para a seleção do chip;
* dmask      : Seleção da máscara para leitura e escrita entre Word,half word e byte;
* tx_out     : Saída de transmissão de dados;
* rx_out     : Entrada de recepção de dados;
* interrupts : Flag utilizada para sinalizar uma interrupção quando a interrupção para o periférico está habilitada;

É importante ressaltar a síntese da PLL para gerar os clocks utilizados:

- Output clocks:
	- clk c0 em 1 MHz
	- clk c1 em 50 MHz
	- clk c2 em 0.03840000 MHz (38400 Hz)

## Processos referentes a recepção da UART

Primeiros processos e funções são os de configuração do funcionamento da UART, para essa configuração se tem dois vetores de registradores que tem as informações de controle e configuração desta que são o ``uart_register`` e o ``buffer_register`` onde cada um tem um tamanho de 32 bits ou uma word e traz as informações necessárias para configurar o periférico UART e o seu buffer de recebimento. Assim  o primeiro parâmetro que pode ser configurado é a paridade.

```VHDL
    ----------- Function Parity Value ----------
    function parity_val(s : integer; setup : std_logic) return std_logic is
        variable temp : std_logic := '0';
    begin
        if ((s mod 2) = 0) and (setup = '0') then --Paridade ativada impar
            temp := '0';
        elsif ((s mod 2) = 0) and (setup = '1') then --Paridade ativada par
            temp := '1';
        elsif ((s mod 2) = 1) and (setup = '0') then --Paridade ativada impar
            temp := '1';
        elsif ((s mod 2) = 1) and (setup = '1') then --Paridade ativada par
            temp := '0';
        end if;
        return temp;
    end function parity_val;
```

O próximo passo é selecionar o baud rate, o processo que seleciona esse baud rate é demonstrado abaixo. A partir do baud rate selecionado ele pega a frequência de 38400 Hz que é o maior baud rate possível e faz uma divisão caso o baud rate selecionado seja menor que 38400 Hz.

```VHDL
    -------------- Baud Rate Select -------------
    baudselect : process(uart_register(BAUD_RATE_BIT+1 downto BAUD_RATE_BIT), baud_04800, baud_09600, baud_19200, clk_baud) is
    begin
        case uart_register(BAUD_RATE_BIT + 1 downto BAUD_RATE_BIT) is
            when "00" =>
                baud_ready <= clk_baud;
            when "01" =>
                baud_ready <= baud_19200;
            when "10" =>
                baud_ready <= baud_09600;
            when "11" =>
                baud_ready <= baud_04800;
            when others =>
                baud_ready <= baud_09600;
        end case;
    end process;
```

Com esses dois parâmetros da comunicação serial definidos podemos agora partir para a configuração do buffer que é feita através de somente um processo nesse ele verifica o modo de configuração selecionado e o byte de configuração.

```VHDL
rx_buffer_config : process(rst, clk)
    begin
        if rst = '1' then
            buffer_mode <= '0';
            buffer_byte <= (others => '0');
        elsif rising_edge(clk) then
            case uart_register(IRQ_MODE_BIT) is
                when '0' =>
                    buffer_mode <= '0';
                    buffer_byte <= buffer_register(NUM_BYTES_IRQ downto NUM_BYTES_IRQ - 7);
                when '1' =>
                    buffer_mode <= '1';
                    buffer_byte <= buffer_register(BYTE_FINAL downto BYTE_FINAL - 7);
                when others =>

            end case;
        end if;
    end process;
```

Agora um processo muito importante é o processo de recebimento de um byte e assim poder armazenar o byte completo no buffer. Basicamente o processo verifica se um bit foi recebido e armazena esse bit no from_rx que recebe do start bit e stop bit da informação e incrementa o sinal cnt_rx que representa a posição a ser armazenada. Ao receber um byte completo ele armazena o somente o valor recebido no sinal rx_register que posteriormente irá para o buffer. 

```VHDL
 rx_receive : process(rst, baud_ready, byte_received)
        variable from_rx : std_logic_vector(9 downto 0);
    begin
        if rst = '1' then
            rx_register <= (others => '0');
            cnt_rx      <= 0;
            from_rx     := (others => '0');
        else
            if byte_received = '1' then
                if rising_edge(baud_ready) then
                    from_rx(cnt_rx) := rx_out;
                    cnt_rx          <= cnt_rx + 1;
                    if cnt_rx = 8 then
                        rx_register <= from_rx(8 downto 1);
                    end if;
                end if;
            else
                cnt_rx <= 0;
            end if;
        end if;
    end process;
```

Agora temos o processo de armazenamento do buffer e geração da interrupção se esse for o caso.Esse processo a cada ciclo de clock verifica se um byte inteiro foi lido pelo processo anterior se isso for verdadeiro o valor do rx_register é salvo no buffer na posição adequada e de acordo com o modo de funcionamento configurado ele faz a verificação se uma interrupção deve ser gerada ou não pelo hardware.

```VHDL
 rx_buffer_receive : process(rst, clk)
        variable cnt_rx_irq : unsigned(2 downto 0);
    begin
        if rst = '1' then
            cnt_rx_buffer <= (others => '0');
            rx_cmp_irq    <= '0';
            cnt_rx_irq    := (others => '0');
            for i in 0 to 7 loop
                buffer_rx(i) <= (others => '0');
            end loop;
        elsif rising_edge(clk) then
            rx_cmp_irq <= '0';
            if byte_read = '1' then
                buffer_rx(to_integer(cnt_rx_buffer)) <= rx_register;
                case buffer_mode is
                    when '0' => if cnt_rx_irq = unsigned(buffer_byte(2 downto 0)) - 1 then
                            --proc irq handler
                            cnt_rx_irq := "111";
                            rx_cmp_irq <= '1';
                        end if;
                    when '1' =>
                        if rx_register = buffer_byte then
                            --proc irq handler
                            rx_cmp_irq <= '1';
                        end if;
                    when others =>
                end case;
                cnt_rx_irq    := cnt_rx_irq + 1;
                cnt_rx_buffer <= cnt_rx_buffer + 1;
            end if;
        end if;
    end process;
```
O último processo verifica se uma interrupção foi gerada ou não e caso tenha sido gerada verifica se a recepção de dados esta habilita se a mesma for verdadeira gera a flag de interrupção para o software dar o tratamento devido a informação recebida.

```VHDL
  interrupt_proc : process(clk, rst)
    begin
        if rst = '1' then
            interrupts <= (others => '0');
        elsif rising_edge(clk) then
            interrupts(1) <= '0';

            if input_data = '0' and rx_cmp_irq = '1' and uart_register(IRQ_RX_ENABLE_BIT) = '1' then 
                interrupts(0) <= '1';
            else
                interrupts(0) <= '0';
            end if;
            input_data <= rx_cmp_irq;
        end if;
    end process;
```

## Getting Started (software):

Dando início agora para a parte de software começamos com a transmissão de um carácter para isso basta utilizar a função UART_write(carácter).

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

O bit de paridade é criado, quando requisitado, na máquina de estados através da adição de um bit extra a palavra enviada. O número de 1's é contado através de uma função separada e de acordo com as configurações se define paridade par ou ímpar.

Para configurar baudrate e bit de paridade e usado uma enumeração para facilitar
```C
UART_setup(baud_rate_t baud, parity_t parity);

UART_setup(_38400, NO_PARITY);
/*  
Para o baud_rate 

typedef enum baud_rates_config {
  _38400,
  _19200,
  _9600,
  _4800
} baud_rate_t;

Para o paridade

typedef enum parity_config {
  NO_PARITY,
  ODD_PARITY,
  EVEN_PARITY
} parity_t;
```
O recebimento das informações são armazenadas em um buffer circular de 8 bytes, o recebimento de dados no buffer é gerado a cada byte recebido então ele é armazenado no buffer e o recebimento dessa informação pode gerar uma interrupção de acordo com o setup feito para o buffer. Foram implementados dois modos de funcionamento o primeiro modo de setup e gerar uma interrupção por número de bytes recebidos e o segundo modo e se um byte Y for recebido pelo buffer ele gera uma interrupção um exemplo para cada modo é demonstrado abaixo

```C
Buffer_setup(buffer_t buffer_type, uint8_t config_byte);
Buffer_setup(IRQ_LENGTH, '2');
/* 
Para o modo do buffer 

typedef enum irq_buffer_config {
  IRQ_LENGTH,
  IRQ_BYTE_FINAL
} buffer_t;
*/
```
Nesse exemplo é feita a implementação de um buffer que gera uma interrupção a cada 2 bytes recebidos. O outro modo basta trocar o tipo do buffer e colocar um caractere desejado para gerar uma interrupção ao ser recebido.

### Utilizando a interrupção

Para utilizar interrupções externas e ler um certa quantidade de dados quando este é recebido, deve-se, primeiramente, habilitar a interrupção da UART implementando trecho de código na aplicação

```C
UART_reception_enable();
UART_interrupt_enable();

extern_interrupt_enable(true);
global_interrupt_enable(true);
```

Segundo, a função de callback deverá ser implementada,  e a função ``UART_buffer_read()`` deverá ser utilizada para ler a quantidade de bytes desejada do buffer quando um certo número de bytes forem recebidos ou um determinado byte que irão gerar a interrupção, a implementação do buffer foi implementado e testado somente com o baud rate de 38400 os outros não foram testados com êxito. A seguir tem o código exemplo:

```C
volatile uint8_t leitura;
volatile uint8_t addr = 0;
uint8_t data[8];

void UART_IRQHandler(void){

	UART_buffer_read(data, 8);
	leitura = 1;
	UART_reception_enable();
}

int main(){

	//Valores inicializados com zero
	int i = 0;
	leitura = 0;
	for(i = 0; i <8 ; i++){
		data[i] = 0;
	}
	// para simulação manter baudrate com 9600 ou alterar testbench
	//Recebimento com Buffer testado somente com baudrate de 38400 na placa de desenvolvimento
	UART_setup(_9600, NO_PARITY);
    Buffer_setup(IRQ_LENGTH, '2');
	UART_reception_enable();
	UART_interrupt_enable();

	extern_interrupt_enable(true);
	global_interrupt_enable(true);

	//Envia os valores lidos do buffer pela variavel data a cada interrupção gerada
	while (1){
		if(leitura == 1){
			for(i = 0; i <8 ; i++){
				UART_write(data[i]);
			}
			leitura = 0;
		}
	}

	return 0;
}
```

Com isso, a cada 2 bytes recebidos a interrupção é gerada, ele envia pela transmissão serial os valores da variável data. Com essa configuração feita podemos agora visualizar a simulação feita para a recepção de dados pela serial e envio pela transmissão quando a interrupção for gerada.


Alguns sinais podem ser observados para facilitar a entender o funcionamento da recepção. O primeiro sinal que devemos observar é o ``transmite_byte`` que é a informação transmitida pelo testbench. Outro sinal importante é ``rx_register`` que é o sinal que representa o valor do byte recebido na recepção da UART já o sinal ``RX`` é o recebimento bit a bit da recepção da UART. No modo de recepção acima na simulação é esperado que a cada dois bytes recebidos uma interrupção é gerada, o sinal que gera a interrupção é ``rx_cmp_irq`` quando é gerada uma interrupçãp esse sinal vai para nível lógico alto durante um ciclo de clock e depois vai para nível lógico baixo e quando esse sinal é acionado e se tem a recepção habilitada a flag de ``interrups`` vai para o valor de 01 que gera uma interrupção no hardware. Para acompanhar o funcionamento do buffer é possível observar o sinal ``buffer_mode`` que vai dizer qual o tipo de funcionamento o buffer terá outro sinal importante é o ``buffer_rx`` que mostra os valores recebidos e armazenados pelo buffer, o sinal ``cnt_rx_buffer`` que é a posição que o buffer irá armazenar o byte recebido. O de acordo com o modo definido de funcionamento o sinal ``buffer_byte`` representa o byte configurado para dizer qual o número de bytes a serem recebidos para gerar uma interrupção e assim um tratamento da informação recebida ou o byte a ser recebido para gerar a mesma. Assim na simulação acima é possível ver a variavel ``cnt_rx_irq`` que conta o numero de bytes recebidos e a cada vez que é recebido dois bytes ele gera uma interrupção mudando o valor da flag interrupts que sinaliza para o software realizar o tratamento da informação recebida até então.

![simulacao_por_tamanho](./imgs/simulacao_buffer_tam_2.jpg)

 Alterando somente a função ``Buffer_setup()`` como a seguir irá gerar uma interrupção a sempre que receber o caracter 'a'

```C
 Buffer_setup(IRQ_BYTE_FINAL, 'a');
```

 No modo que gera uma interrupção pelo byte recebido a diferença é que ele para de observar a contagem de bytes e verifica o byte recebido tem o mesmo valor do byte configurado para gerar a interrupção ele gera a mesma, a simulação desse modo de funcionamento é demonstrado abaixo. 

 ![simulacao_por_caractere](./imgs/simulacao_buffer_byte_receive_a.jpg)
