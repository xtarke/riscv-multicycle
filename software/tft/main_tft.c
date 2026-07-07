/*
 * uart.h
 *
 *  Created on: December 11, 2019
 *      Author: Diesson Stefano Allebrandt e Felipe Rodrigues Broering
 *      Instituto Federal de Santa Catarina
 * 
 * 
 */


#include "../_core/utils.h"
#include "tft.h"
#include "../_core/hardware.h"
#include <limits.h>


int main(){
	
	uint16_t color = 0x001F;
    uint16_t position = 0;
	
	tft_init();
	delay_(10000);
    
	tft_clean(0x0000);
	delay_(11000);
		
    while(1){
        
		tft_sqrt(~color, position + 10, position + 10, 0x0014);
        delay_(90000);
        
		tft_sqrt(~color, position + 10, position + 10, 0x0014);
        delay_(90000);
		
		color = (color << 1) | 0x0001; 
        position = position + 8;
        
		if(color == 0xFFFF || color == 0x0000){
            color = 0x001F;
        }
        if(position > 120){
            position = 0;
            tft_clean(0x0000);
            delay_(11000);
        }
    }

	return 0;
}
