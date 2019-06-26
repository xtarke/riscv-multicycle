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
	volatile uint32_t *sdram = &SDRAM;
   
	 
		

	while (1){

		for(x=0; x<16; x++){
				 sdram[x] = 3; 
		}

		for(x=0; x<16; x++){
			OUTBUS =  sdram[x];
			delay_(5); 
		}


		// sdram[0] = 0x0;
	//	 sdram[1] = 0x1;
		// sdram[2] = 0x2;
		// sdram[3] = 0x3;
		// sdram[4] = 0x4;
		// sdram[5] = 0x5;
		// sdram[6] = 0x6;
		// sdram[7] = 0x7;
		// sdram[8] = 0x8;
		// sdram[9] = 0x9;
		// sdram[10] = 0xA;
		//delay_(10000); 
		// sdram[5] = sdram[1] + sdram[2];
		 //delay_(10000); 
		 //OUTBUS = sdram[5];
		 //delay_(100000); 
		
		// for(x=0; x<10000; x++){
		// 	sdram[x] = 0xFFF;
		// 	//  if (x%800 == 0){
		// 	//  	i++;
		// 	//  }
		// }
		// OUTBUS = 0x0F;
		
		
		//while(1){
			// OUTBUS = sdram[3];
			// OUTBUS = sdram[4];
			/* To blink */
		// OUTBUS = 0x10;
		// SEGMENTS = 0xFFFFFFC0;
		// delay_(10000);
        
		// OUTBUS = 0;
    // SEGMENTS = 0xFFFFFFFF;
		// delay_(10000); 
		//}
        
		/* To test Data Bus 
		x = INBUS;        
		OUTBUS = x; */
	}

	return 0;
}
