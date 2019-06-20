/*
 * firmware.c
 *
 *  Created on: Jan 20, 2019
 *      Author: Renan Augusto Starke
 *      Instituto Federal de Santa Catarina
 * 
 * 
 * Simple LED blink example.
 * -----------------------------------------
 */


#include "utils.h"
#include "hardware.h"


int main(){
	int x = 0;
	uint32_t *sdram = &SDRAM;
   
	while (1){
		
		sdram[0] = 0x0;
		sdram[1] = 0x1;
		sdram[2] = 0x2;
		sdram[3] = 0x3;
		sdram[4] = 0x4;
		sdram[5] = sdram[1] + sdram[4];
		OUTBUS = sdram[5];
		
		/* To blink */
		//OUTBUS = 0x10;
		//SEGMENTS = 0xFFFFFFC0;
		//delay_(10000);
        
		//OUTBUS = 0;
    //SEGMENTS = 0xFFFFFFFF;
		//delay_(10000); 
        
		/* To test Data Bus 
		x = INBUS;        
		OUTBUS = x; */
	}

	return 0;
}
