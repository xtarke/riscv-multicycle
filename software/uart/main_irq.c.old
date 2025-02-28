#include <limits.h>
#include "uart.h"
#include "../_core/utils.h"
#include "../_core/hardware.h"
#include "../gpio/gpio.h"
#include "../irq/interrupt.h"
#include <stdlib.h>

volatile uint8_t leitura;
volatile uint8_t addr = 4;
uint8_t data[8];

void UART_IRQHandler(void){
	
	UART_buffer_read(data, 8);

	leitura = 1;
	UART_reception_enable();
	
}


int main(){

	int i = 0;
	leitura = 0;
	for(i = 0; i <8 ; i++){
		data[i] = 0;
	}
	// Para simulação manter 9600 para manter ou alterar baudrate do testbench geração dos sinais 
	UART_setup(_9600, NO_PARITY);
	//Configuração do Buffer em relação ao modo de recebimento
    Buffer_setup(IRQ_BYTE_FINAL, 'a');
	//Habilitando as interrupções da UART
	UART_reception_enable();
	UART_interrupt_enable();
	//Habilitando as interrupções globais
	extern_interrupt_enable(true);
	global_interrupt_enable(true);

	while (1){
		//Tratameno da flag que é ativada na função UART IRQ HANDLER
		if(leitura == 1){
			for(i = 0; i <8 ; i++){
				UART_write(data[i]);
			}
			leitura = 0;
		}
	}

	return 0;
}