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
#include "uart.h"
#include "hardware.h"



int main(){

	uint8_t i = 0;
	
	
	SEGMENTS = 0xFFFFFFF0;
	
	while (1){
		/* To blink */
		OUTBUS = 0x07;
		//SEGMENTS = 0xFFFFFFC0;
		
		SEGMENTS = SEGMENTS & 0xFFFFFFF0;
		SEGMENTS |= (i & 0x0F);
		
		delay_(10000);

		OUTBUS = 0;
        //SEGMENTS = 0xFFFFFFF0;
		delay_(10000); 

		/* To test Data Bus 
		x = INBUS;        
		OUTBUS = x; */		

		
		i++;
	}

	return 0;
}
