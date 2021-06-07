/*
 * uart.h
 *
 *  Created on: July 1, 2019
 *      Author: Marcos Vinícius Leal da Silva e
 *      Modified: Daniel Pereira
 *
 *      Instituto Federal de Santa Catarina
 *
 * UART functions
 *  - write
 *  - send
 *	- read
 *	- (...)
 *
 */

#include <stdint.h>
#include "uart.h"
#include "../_core/hardware.h"

void UART_write(uint8_t data){

	/* Slow assembly */
	/* UART_TX_REG->byte = data;
	UART_TX_REG->tx_start = 1; */

	/* Fast assembly: one instruction */
	*((_IO32 *)UART_TX_REG) = (1 << 8) | data;


}

void UART_setup(int baud, int parity){
	/* To do:
		baud = 0 => baud_rate = 38400
		baud = 1 => baud_rate = 19200
		baud = 2 => baud_rate = 09600
		baud = 3 => baud_rate = 04800

		parity = 0 => parity_off
		parity = 1 => parity_off
		parity = 2 => parity_on odd
		parity = 3 => parity_on even
	*/


	UART_SETUP = (baud & 0x03) | ((0x3 & parity) << 2);
	return;
}

void UART_interrupt_enable(void){
	UART_SETUP = UART_SETUP | (0x01 << 4);
}

uint8_t UART_read(void){
	/* To do:
		- Change variable "byte" to uint8_t
	*/
	uint8_t byte;

	byte = UART_RX;

	return byte;
}
