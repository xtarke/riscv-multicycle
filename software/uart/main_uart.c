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

int main(){
	
	int x;
	
	UART_setup(3, 1);
	
	while (1){
		// Testing UART - Adjusts
		//delay_(10000);
	
		// Testing UART - Transmission
		UART_write('c');
		delay_(10000);
		
		// Testint UART - Reception
		x = UART_read();
		OUTBUS = x;
		delay_(10000);
	}

	return 0;
}
