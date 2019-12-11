/*
 * uart.h
 *
 *  Created on: July 1, 2019
 *      Author: Marcos Vinícius Leal da Silva
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
#include "hardware.h"

void UART_write(int character){
	/* To do:
		- Change variable "character" to uint8_t
	*/
	UART_TX = (0x01 << 8) | character;
	return;
}

int UART_read(void){
	/* To do:
		- Change variable "byte" to uint8_t
	*/
	int byte;
	
	byte = UART_RX;
	return byte;
}

