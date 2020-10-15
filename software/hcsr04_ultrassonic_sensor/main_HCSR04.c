/*
 * main_HCSR04.c
 *
 *  Created on: out 12, 2020
 *
 *      Author: Suzi Yousif
 *      Instituto Federal de Santa Catarina
 *
 *
 * HCSR04 Ultrassonic Sensor
 * -----------------------------------------
 */

#include "utils.h"
#include "hardware.h"


int Read_HCSR04(){
	return INBUS;
}

int main(){
	int buffer = 0;

	while (1){

		SEGMENTS = Read_HCSR04();
		delay_(5000);

	}

	return 0;
}
