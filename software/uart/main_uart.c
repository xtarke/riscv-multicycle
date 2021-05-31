/*
 * firmware.c
 *
 *  Created on: Jan 20, 2019
 *      Author: Marcos Vinicius Leal Da Silva e Daniel Pereira
 *      Instituto Federal de Santa Catarina
 *
 *
 * Simple LED blink example.
 * -----------------------------------------
 */


#include "../_core/utils.h"
#include "uart.h"
#include "../_core/hardware.h"
#include <limits.h>
#include "../gpio/gpio.h"
#include "../irq/interrupt.h"


void UART_IRQHandler(void){
	uint8_t data;
	data = UART_read();
	OUTBUS = data;
	HEX0 = data;
	HEX1 = data >> 4;
}


int main(){

	uint8_t data = 0x0F;
	UART_setup(0, 0);
	UART_interrupt_enable();

	extern_interrupt_enable(true);
	global_interrupt_enable(true);

	while (1){

		delay_(100);
	}

	return 0;
}
