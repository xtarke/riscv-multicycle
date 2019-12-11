/*
 * uart.h
 *
 *  Created on: December 11, 2019
 *      Author: Diesson Stefano Allebrandt e Felipe Rodrigues Broering
 *      Instituto Federal de Santa Catarina
 * 
 * 
 */


#include "utils.h"
#include "tft.h"
#include "hardware.h"
#include <limits.h>


int main(){
	
	tft_init();
	delay_(10000);
    
    while(1){
        tft_clean(0xFC00);
        delay_(100000);
        
        tft_clean(0x00BF);
        delay_(100000);
        
        tft_sqrt(0x07C0, 0x000F, 0x0050, 0x00A0, 0x000F);
        //tft_clean(0x07C0);
        delay_(100000);
    }

	return 0;
}
