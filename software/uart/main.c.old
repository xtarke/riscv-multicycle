/*
 * main.c
 *
 *  Created on: Jan 20, 2019
 *      Author: Marcos Vinicius Leal Da Silva e Daniel Pereira
 *      Instituto Federal de Santa Catarina
 *
 *   Modified: Renan Augusto Starke
 *
 * Simple pooling UART TX example.
 * -----------------------------------------
 */


 #include <limits.h>
 #include "uart.h"
 #include "../_core/utils.h"
 #include "../_core/hardware.h"


int main(){

	uint8_t data = 10;
  volatile uint8_t x = 0;

	UART_setup(_9600, NO_PARITY);
  UART_reception_enable();

	while (1){

    // Testint UART - Reception
    	x = UART_read();

		// Testing UART - Transmission
		UART_write(x);

    // Display data in IO bus
    SEGMENTS_BASE_ADDRESS = x;


	}

	return 0;
}
