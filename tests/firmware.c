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
	int i = 0;
	uint32_t *sdram = &SDRAM;
   
	while (1){
		
		for(x=0; x<64000; x++){
			sdram[x] = 0x7;
			// if (x%800 == 0){
			// 	i++;
			// }
		}
		
		
		while(1){
			/* To blink */
		OUTBUS = 0x10;
		SEGMENTS = 0xFFFFFFC0;
		delay_(10000);
        
		OUTBUS = 0;
    SEGMENTS = 0xFFFFFFFF;
		delay_(10000); 
		}
        
		/* To test Data Bus 
		x = INBUS;        
		OUTBUS = x; */
	}

	return 0;
}
