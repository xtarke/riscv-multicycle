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


		// sdram[512] = 0x1;
		// sdram[513] = 0x2;
		// sdram[514] = 0x3;
		// sdram[515] = 0x4;
		// sdram[516] = 0x8;
		// sdram[517] = 0x2;
		// sdram[518] = 0x3;
		// sdram[519] = 0x4;
		// sdram[520] = 0x8;
		// sdram[5] = sdram[514] + sdram[513];
		// OUTBUS = sdram[5];
		
		for(x=0; x<128000; x++){
			sdram[x] = 0x00F;
			// if (x%800 == 0){
			// 	i++;
			// }
		}
		
		
		while(1){
			/* To blink */
		// OUTBUS = 0x10;
		// SEGMENTS = 0xFFFFFFC0;
		// delay_(10000);
        
		// OUTBUS = 0;
    // SEGMENTS = 0xFFFFFFFF;
		// delay_(10000); 
		}
        
		/* To test Data Bus 
		x = INBUS;        
		OUTBUS = x; */
	}

	return 0;
}
