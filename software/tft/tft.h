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
void tft_sqrt(uint16_t color, uint16_t x, uint16_t y, uint16_t h);
void tft_rect(uint16_t color, uint16_t x, uint16_t y, uint16_t h, uint16_t w);


#define TFT_DATA0	  *(&TFT_BASE_ADDRESS)
#define TFT_DATA1	  *(&TFT_BASE_ADDRESS + 1)
#define TFT_DATA2	  *(&TFT_BASE_ADDRESS + 2)
#define TFT_RETURN    *(&TFT_BASE_ADDRESS + 3)

#endif // __UART_H
