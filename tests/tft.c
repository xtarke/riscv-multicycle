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
#include "hardware.h"
#include "utils.h"

void tft_write(uint32_t data1, uint32_t data2, uint32_t data3){

    TFT_DATA0 = data1 & (0x7FFFFFFF);
    TFT_DATA1 = data2 & (0x7FFFFFFF);
    TFT_DATA2 = data3 & (0x7FFFFFFF);
    delay_(10);
    
    TFT_DATA0 = data1;
    TFT_DATA1 = data2;
    TFT_DATA2 = data3;
    delay_(10);
    //while(TFT_RETURN != 0x00000001);
    
    TFT_DATA0 = data1 & (0x7FFFFFFF);
    TFT_DATA1 = data2 & (0x7FFFFFFF);
    TFT_DATA2 = data3 & (0x7FFFFFFF);
    
	return;
    
}

void tft_set(uint32_t data1, uint32_t data2, uint32_t data3){
    
    TFT_DATA0 = data1;
    TFT_DATA1 = data2;
    TFT_DATA2 = data3;
    
	return;
    
}

void tft_init(){
    
    tft_set(0x00000000, 0x00000000, 0x00000000);
    
    tft_write(0xFFFF0000, 0x00000000, 0x00000000);
    delay_(1000);
    
    tft_write(0x8001FFFF, 0x00000000, 0x00000000);
    delay_(1000);
    
	return;
    
}

void tft_clean(uint16_t color){
    
    uint32_t color_ = color;
    
    tft_write(0x80010000 | color, 0x00000000, 0x00000000);
    //delay_(1000);
	//tft_write(0x00010000 | color, 0x00000000, 0x00000000);
    
	return;
    
}
