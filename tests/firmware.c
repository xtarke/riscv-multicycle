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


		//for(x=0; x<16; x++){

		sdram[0] = 255;
		SEGMENTS =  sdram[0];

		//}


//		for(x=0; x<16; x++){
//			if(sdram[16 + x] != 0){
//				SEGMENTS =  sdram[x];
//			}
//
//				INBUS = sdram[x];
//
//				//delay_(10); //ToDo: SDRAM refresh and init are not working.
//		}

		/* To test Data Bus
		x = INBUS;
		OUTBUS = x; */
	}

	return 0;
}
