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

	while (!UART_TX_REG->tx_done);

	/* Fast assembly: one instruction */
	*((_IO32 *)UART_TX_REG) = (1 << 8) | data;

}

void UART_setup(baud_rate_t baud, parity_t parity){
	/* Slow assembly
	UART_SETUP_REG->baud_rate = baud;
	UART_SETUP_REG->parity = parity; */

	/* Fast assembly: one instruction */
	*((_IO32 *)UART_SETUP_REG) = (baud & 0x03) | ((0x03 & parity) << 2);
}

void UART_reception_enable(void){
	UART_SETUP_REG->rx_enable = 1;
}

void UART_interrupt_enable(void){
	UART_SETUP_REG->rx_irq_enable = 1;
}

uint8_t UART_read(void){
	/* To do:
		- Change variable "byte" to uint8_t
	*/
	uint8_t byte;

	byte = UART_RX;

	return byte;
}
