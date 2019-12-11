/*
 * uart.h
 *
 *  Created on: December 11, 2019
 *      Author: Diesson Stefano Allebrandt e Felipe Rodrigues Broering
 *      Instituto Federal de Santa Catarina
 * 
 * TFT functions
 *  - reset
 *	- clean
 *  - write_sqrt
 *  - write_rect
 *  - write
 *	- (...)
 * 
 */


#ifndef __UART_H
#define __UART_H

#include <stdint.h>

void UART_write(int character);
int UART_read(void);

#endif // __UART_H
