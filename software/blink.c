/*
 * blink.c
 *
 *  Created on: Jan 20, 2019
 *              May 11, 2020
 *      Author: Renan Augusto Starke
 *      Instituto Federal de Santa Catarina
 *
 *
 * Simple LED blink example with GPIO input
 * -----------------------------------------
 */

#include "_core/utils.h"
#include "_core/hardware.h"
#include "gpio/gpio.h"

int main(){
	uint32_t data = 0;

	while (1){
		/* Read input bus */
		if (INBUS & 0x0F)
			/* Resets data when any input is high */
			data = 0;

		/* Counter blink */
		OUTBUS = data;
		SEGMENTS_BASE_ADDRESS = data;
		
		/* Volatile delay to prevent optimization and increased count for visibility */
		for (volatile uint32_t i = 0; i < 2000000; i++);

		data++;
	}

	return 0;
}
