/*
 * firmware.c
 *
 *  Created on: Jan 20, 2019
 *      Author: Renan Augusto Starke
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
		
		// To test LEDR and Display 7 Seg
		// OUTBUS = 0x10;
		// SEGMENTS = 0xFFFFFFC0;
		// delay_(10000);
		
		// OUTBUS = 0;
		// SEGMENTS = 0xFFFFFFFF;
		// delay_(10000);
		
		// To test Data Bus
		//x = INBUS;        
		//OUTBUS = x;
		//delay_(10000); 
		
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
