# Filtro digital de média móvel

Este projeto implementa um filtro digital de média móvel como um dos periférico do núcleo riscv. O periférico implementa n registradores de 32 bits.

A entrada de dados é feita pela entrada do periférico, sincronizados com o pulso de clock do sistema.
 
O periférico implementa três funções, reset, habilita e recebe resultado. 

O funcionamento deste periférico é receber dados de forma contínua e retornar a média movél desses dados a partir dos ultimos n dados.

## Funcionamento do periférico

A constante de entrada "G_AVG_LEN_LOG : integer := 2" definirá quantos registrados será ultilizado para média móvel.

- Exemplo 1) Média móvel de 4 valores: "G_AVG_LEN_LOG : integer := 2", ou seja 2^2 = 4.

- Exemplo 2) Média móvel de 32 valores "G_AVG_LEN_LOG : integer := 5", ou seja 2^5 = 32.
		  
Quando o hardware estiver em reset, ou reset via software pela função, a saída e os registradores serão zerados.

A entrada de dados é cascateada conforme abaixo:

```vhdl
registers   <= signed(data_in) & registers(0 to registers'length-2);  
```

O acumulador = acumulador - último registrador, conforme abaixo.

```vhdl
r_acc       <= r_acc + signed(data_in) - signed(registers(registers'length-1));
```

A saída será a média dos registradores.
data_out  <= std_logic_vector(r_acc(G_NBIT+G_AVG_LEN_LOG-1 downto G_AVG_LEN_LOG)); 

### Código em C

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
/* Digital filter peripheral 
*/
#ifndef _DIF_FILT
#define _DIF_FILT

#include "../_core/hardware.h"
#include "../_core/utils.h"

typedef struct {
  _IO8 enable :1 ;           /*!< Bit habilitação filto */
  _IO8 reset  :1 ;           /*!< Bit de filtro Habilitado. */
 
} DIG_FIL_REG_TYPE;

#define DIG_FILT_CTRL ((DIG_FIL_REG_TYPE *) &DIG_FIL_BASE_ADDRESS )
#define DIG_FILT_OUT    *(&DIG_FIL_BASE_ADDRESS + 4)    


void dig_filt_reset(uint8_t);
void dig_filt_enable(uint8_t);
uint32_t dig_filt_get_output();

#endif
```


Implementação das funções:

```c
/* Digital filter peripheral
*/

#include "dig_filt.h"

void dig_filt_reset(uint8_t data){
  DIG_FILT_CTRL-> reset = data;
}

void dig_filt_enable(uint8_t data){
  DIG_FILT_CTRL-> enable = data;
}

uint32_t dig_filt_get_output(){
  return (DIG_FILT_OUT);
}
```

O código a seguir é um exemplo para observar-se o funcionamento do periférico:

```c
/* 
	digital filter peripheral
*/

#include "dig_filt.h"
#include "../gpio/gpio.h"

int main(){
	uint32_t data = 0;

	dig_filt_enable(1);						// habilitada filtro

	while (1){

        	SEGMENTS_BASE_ADDRESS = dig_filt_get_output();  // get output function
		      
		delay_(100000);						// for human interaction	
	}

	return 0;
}
```
