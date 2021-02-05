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

#include <stdint.h>
#include "tft.h"
#include "../_core/hardware.h"
#include "../_core/utils.h"

void tft_write(uint32_t data1, uint32_t data2, uint32_t data3){

    TFT_DATA1 = data2;
    TFT_DATA2 = data3;
    TFT_DATA0 = data1;
    //while(TFT_RETURN != 0x00000001);

	return;
    
}

void tft_init(){
    
    tft_write(0x00000000, 0x00000000, 0x00000000);
    
    tft_write(0xFFFFFFFF, 0x00000000, 0x00000000);
    delay_(10000);
    //tft_write(0x0001FFFF, 0x00000000, 0x00000000);
    
	return;
    
}

void tft_clean(uint16_t color){
    
    uint32_t color_ = color;
    
    tft_write(0x00010000 | color, 0x00000000, 0x00000000);
    
	return;
    
}

void tft_sqrt(uint16_t color, uint16_t x, uint16_t y, uint16_t h){
    
    uint32_t color_ = color;
    uint32_t pos_ = (x << 16) | y;
    uint32_t size_ = (h << 16) | h;
    
    tft_write(0x00020000 | color, pos_, size_);
    
	return;
    
}

void tft_rect(uint16_t color, uint16_t x, uint16_t y, uint16_t h, uint16_t w){
    
    uint32_t color_ = color;
    uint32_t pos_ = (x << 16) | y;
    uint32_t size_ = (h << 16) | w;
    
    tft_write(0x00030000 | color, pos_, size_);
    
	return;
    
}
