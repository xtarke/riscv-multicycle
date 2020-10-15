# FIltro digital de média

Este projeto implementa um filtro digital de média como um dos periférico do núcleo riscv. O periférico implementa 32 registradores de 32 bits dispostos em um array, onde a escrita do array é feita de forma circular. Há 3 formas de acessar o periférico, pelos registradores de controle, entrada ou saída. O periférico implementa duas funções, reset e adicionar novo dado onde reset reseta todos os registradores e novo dado adiciona o valor do registrador de entrada no array de registradores. É possível a leitura da média do array de registradores através da leitura do registrador de saída.

A ideia principal desse periférico é receber dados de forma contínua e retornar a média movél desses dados a partir dos ultimos 32 dados.

## Funcionamento do periférico

O periférico é conectado ao barramento de dados e funciona baseado em 2 maquinas de estado, uma de controle geral e uma de controle de entrada de novos dados.

![](https://i.imgur.com/MdRtKwi.png)

Na maquina de controle geral há 4 estados, sendo RESET e NEW_DATA comandos para o periférico. WAIT_DATA é o estado em que fica o periférico enquanto o mesmo faz os procedimentos necessários antes de poder voltar para IDLE.

Para o procedimento de reset (RESET) não foi necessária a implementação em uma outra máquina de estados, pois nesse procedimento é ligado o clear do banco de registradores, limpando a informação por eles armazenada. A entrada nesse procedimento se da pela escrita do valor alto no bit 0 do registrador de control (DIG_FILT_CTRL).

![](https://i.imgur.com/4rN0ffA.png)

No procedimento de novo dado (NEW_DATA) há a aquisição do conteúdo escrito no registrador de entrada (DIG_FILT_IN), dps o cálculo da saída que é armazenada no registrador de saída (DIG_FILT_OUT) e a atualização do index do banco de registradores. Esse processo é controlado por uma maquina de estados exclusiva desse procedimento.

![](https://i.imgur.com/W2UFhaA.png)

Há também um bit que sinaliza se o periférico está livre ou não (data_is_ready), sendo ele o bit 31 do registrador de controle, esse bit fica em estado alto durante o estado IDLE de controle, caso esse estado mude, o bit é colocado em estado lógico baixo, sinalizando que o periférico está ocupado. Assim que o periférico deixa de estar ocupado o bit volta ao estado alto.

A seguir os sinais de debug do registrador, sendo esses dispensáveis para o funcionamento do periférico.
![](https://i.imgur.com/eU2JKEm.png) ![](https://i.imgur.com/SRRYexH.png)

Na implementação realizada, o sexto display está conectado a um registrador externo (OUTBUS), utilizado para verificar o procedimento de leitura do registrador de saida (DIG_FILT_OUT).

### Processos de entrada e saída

O processo a seguir é responsável por detectar uma requisição de leitura do periférico e de acordo com os filtros retorna para barramento de dados a informação requisitada.
![](https://i.imgur.com/19b1icZ.png)

O processo a seguir é responsável pelo tratamento da requisição de escrita no periférico, ainda nesse mesmo processo há o tratamento das maquinas de estado descritas anteriormente.
![](https://i.imgur.com/6C2DeAf.png)

## Código em C

Em hardware.h as definição dos endereços utilizados:
```c 
#define PERIPH_BASE		((uint32_t)0x4000000) 

#define DIG_FILT_CTRL   (*(_IO32 *) (PERIPH_BASE + 80))
#define DIG_FILT_IN     (*(_IO32 *) (PERIPH_BASE + 84))
#define DIG_FILT_OUT    (*(_IO32 *) (PERIPH_BASE + 88))	
```
NOTA: os endereços supracitados são referentes as words x"14", x"15" e x"16" utilizados para leitura e escrita no .vhd

O protótipo das funções e definições: 
```c 
#define RESET_REGS 	0x00000001
#define NEW_DATA 	0x00000002

void dig_filt_reset();
void dig_filt_add_data(uint32_t data_in);

uint32_t dig_filt_get_output();
uint32_t dig_filt_data_is_ready();
```

Implementação das funções:
```c 
/* Retorna o bit 31 do registrador de controle */
uint32_t dig_filt_data_is_ready(){
	return (DIG_FILT_CTRL >> 31)&(1);
}

/* Escreve o comando de reset do registradores 
   no registrador de controle em seguida 
   espera a liberação do periférico */
void dig_filt_reset(){
	DIG_FILT_CTRL = RESET_REGS;
	while(!dig_filt_data_is_ready());
}

/* Escreve data_in no registrador de entrada, 
   envia o comando de adicionar novo dado
   e aguarda liberação do periférico */
void dig_filt_add_data(uint32_t data_in){
	DIG_FILT_IN = data_in;
	DIG_FILT_CTRL = NEW_DATA;
	while(!dig_filt_data_is_ready());
}

/* Retorna o valor do registrador de saída */
uint32_t dig_filt_get_output(){
	return DIG_FILT_OUT;	
}
```

O código a seguir é um exemplo para observar-se o funcionamento do periférico:

```c
#include "dig_filt.h"

int main(){
	uint8_t i = 0;

	dig_filt_reset();						// reset function

	while (1){

		dig_filt_add_data(0xA);				// add new data function
		OUTBUS = dig_filt_get_output();		// get output function
		delay_(10000);

		i++;
		if (i == 40)
		{
			i = 0;
			dig_filt_reset();				// reset function
		}
	}

	return 0;
}

```

