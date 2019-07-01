/*
 * firmware.c
 *
 *  Created on: Jan 20, 2019
 *      Author: Jeferson Pedroso
 *      Instituto Federal de Santa Catarina
 * 
 * 
 * Simple LED blink example.
 * -----------------------------------------
 */


#include "utils.h"
#include "uart.h"
#include "hardware.h"

int main(){
	int x = 0;
   
	while (1){
		
		
		// Testing UART - Transmission
		UART_write('a');
		delay_(10000);
		
		// Testint UART - Reception
		x = UART_read();
		OUTBUS = x;
		delay_(10000);
		
	}

	return 0;
}
