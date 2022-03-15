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
		if (INBUS)
			/* Resets data when any input is high */
			data = 0;

		/* Counter blink */
		OUTBUS = data;
		SEGMENTS_BASE_ADDRESS = data;
		delay_(10000);

		data++;
	}

	return 0;
}
