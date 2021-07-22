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

#include <limits.h>
#include "uart.h"
#include "../_core/utils.h"
#include "../_core/hardware.h"
#include "../gpio/gpio.h"
#include "../irq/interrupt.h"


void UART_IRQHandler(void){
	uint8_t data;
	data = UART_unblocked_read();

	SEGMENTS_BASE_ADDRESS = data;

	UART_reception_enable();
}


int main(){

	UART_setup(_38400, NO_PARITY);

	UART_reception_enable();
	UART_interrupt_enable();

	extern_interrupt_enable(true);
	global_interrupt_enable(true);

	while (1){

	}

	return 0;
}
