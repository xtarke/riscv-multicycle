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

//void tft_write(uint32_t data1, uint32_t data2, uint32_t data3);
//void tft_set(uint32_t data1, uint32_t data2, uint32_t data3);
void tft_init();
void tft_clean(uint16_t color);

#endif // __UART_H
