/*
 * firmware.c
 *
 *  Created on: Jan 20, 2019
 *      Author: Marcos Vinicius Leal Da Silva e Daniel Pereira
 *      Instituto Federal de Santa Catarina
 *
 *
 * Simple UART TX example.
 * -----------------------------------------
 */


 #include <limits.h>
 #include "uart.h"
 #include "../_core/utils.h"
 #include "../_core/hardware.h"


int main(){

	uint8_t data = 0;

	UART_setup(_9600, NO_PARITY);
  //UART_reception_enable();

	//UART_write('j');

	while (1){
		// Testing UART - Adjusts
		//delay_(10000);

		// Testing UART - Transmission
		UART_write(data);
		//delay_(10);

		// Testint UART - Reception
		//x = UART_read();
		//OUTBUS = x;
		delay_(100);
    data++;
	}

	return 0;
}
