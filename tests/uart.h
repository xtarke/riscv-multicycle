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


#ifndef __UART_H
#define __UART_H

#include <stdint.h>

void UART_write(int character);
int UART_read(void);

#endif // __UART_H
