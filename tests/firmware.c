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

	while (1){
		/* To blink */
		OUTBUS = 0x07;
		SEGMENTS = 0xFFFFFFC5;
		delay_(10000);

		OUTBUS = 0;
        SEGMENTS = 0xFFFFFFFF;
		delay_(10000); 

		/* To test Data Bus 
		x = INBUS;        
		OUTBUS = x; */		

	}

	return 0;
}
