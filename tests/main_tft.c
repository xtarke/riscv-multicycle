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
	
	while (1){
		
        //tft_clean(0xFFC0);
		//delay_(10000);
		
		tft_clean(0x0000);
		delay_(10000);
	}

	return 0;
}
