/*
 * tft.c
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

#include "tft.h"
#include "../_core/utils.h"

void tft_write(uint32_t data_a, uint32_t data_b, uint32_t data_c){
	TFT_DATA1 = data_b; // Grava no Offset + 1 (reg_input_b)
    TFT_DATA2 = data_c; // Grava no Offset + 2 (reg_input_c)
    TFT_DATA0 = data_a; // Grava no Offset + 0 (reg_input_a) -> Ativa o start_sig
	
}

void tft_init(){
    
    tft_write(0x00000000, 0x00000000, 0x00000000);
    
    tft_write(0xFFFFFFFF, 0x00000000, 0x00000000);
    delay_(10000);
    //tft_write(0x0001FFFF, 0x00000000, 0x00000000);
    
}

void tft_clean(uint16_t color){
    
	uint32_t data_a = 0x00010000 | (uint32_t)color;
    tft_write(data_a, 0x00000000, 0x00000000);
    
}

void tft_sqrt(uint16_t color, uint16_t x, uint16_t y, uint16_t h){
    
	uint32_t data_a = 0x00020000 | (uint32_t)color;
    uint32_t data_b = ((uint32_t)x << 16) | (uint32_t)y;
    uint32_t data_c = ((uint32_t)h << 16) | (uint32_t)h;
    tft_write(data_a, data_b, data_c);
    
}

void tft_rect(uint16_t color, uint16_t x, uint16_t y, uint16_t h, uint16_t w){
    
	uint32_t data_a = 0x00030000 | (uint32_t)color;
    uint32_t data_b = ((uint32_t)x << 16) | (uint32_t)y;
    uint32_t data_c = ((uint32_t)w << 16) | (uint32_t)h; // w = len_x (15 downto 16), h = len_y (15 downto 0)
    tft_write(data_a, data_b, data_c);
    
}
