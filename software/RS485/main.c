
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
#include "RS485.h"
#include "../_core/utils.h"
#include "../_core/hardware.h"

int main()
{

	uint8_t data = 10;
	volatile uint8_t x = 0;

	RS485_setup(_9600, NO_PARITY);
	// RS485_reception_enable();

	while (1)
	{
		// Testint UART - Reception
		// x = RS485_read();

		// Testing UART - Transmission
		RS485_write('A');
		// RS485_write('L');
		// RS485_write('E');
		// RS485_write('X');

		// delay_(100);

		// Display data in IO bus
		SEGMENTS_BASE_ADDRESS = x;
	}

	return 0;
}
