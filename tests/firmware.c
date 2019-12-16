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

	SEGMENTS = 0xFFFFFFF0;

	uint8_t i = 0;
	
	while (1){

		/* To blink */
		OUTBUS = 0x03;
		SEGMENTS = 0xFFFFFFC0;

		
		/* To blink */
		OUTBUS = 0x07;
		//SEGMENTS = 0xFFFFFFC0;
		
		SEGMENTS = SEGMENTS & 0xFFFFFFF0;
		SEGMENTS |= (i & 0x0F);
		
		delay_(10000);


		sdram[0] = 255;
		SEGMENTS =  sdram[0];
		delay_(5);


		//}


		OUTBUS = 0;
        //SEGMENTS = 0xFFFFFFF0;
		delay_(10000); 

		/* To test Data Bus 
		x = INBUS;        
		OUTBUS = x; */
	}

	return 0;
}
