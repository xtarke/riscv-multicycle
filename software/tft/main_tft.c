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
	
    uint16_t color = 0x0001;
    uint16_t position = 0;
	tft_init();
	delay_(10000);
    
	tft_clean(color);
	delay_(11000);
		
    while(1){
        
        tft_rect(~color, position, position, 0x0050, 0x00A0);
        delay_(10000);
        
        tft_sqrt(~color, position, position, 0x000A);
        //tft_clean(0x07C0);
        delay_(90000);
        color = color << 1;
        position = position + 4;
        
        if(color == 0x0000)
            color = 0x0001;
        if(position > 200)
            position = 0;
    }

	return 0;
}
