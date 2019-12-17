/*
 * uart.h
 *
 *  Created on: July 1, 2019
 *      Author: Marcos VinÃ­cius Leal da Silva e Daniel Pereira
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
void UART_setup(int baud, int parity);
int UART_read(void);

#endif // __UART_H
