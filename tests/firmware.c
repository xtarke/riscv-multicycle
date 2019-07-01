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
	int x = 3;
	
	uint32_t data = 0xFFFFFFC0;
	
	while (1){
		/* To blink */
		OUTBUS = 0x10;
		SEGMENTS = data;
		delay_(10000);
        	
	
		OUTBUS = 0;
		SEGMENTS = 0xFFFFFFFF;
		delay_(10000); 
        
		data = data << 8;
		x--;

		if (!x){
			data = 0xFFFFFFC0;
			x = 3;
		}


		/* To test Data Bus 
		x = INBUS;        
		OUTBUS = x; */
	}

	return 0;
}
