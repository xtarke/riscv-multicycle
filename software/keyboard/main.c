/*
 * main_HCSR04.c
 *
 *  Created on: out 12, 2020
 *
 *      Author: 
 *      Instituto Federal de Santa Catarina
 *
 *
 * 
 * -----------------------------------------
 */

#include "../_core/utils.h"
#include "../_core/hardware.h"

int read_keyboard(){
	return KEYBOARD_BASE_ADDRESS;
}

int main(){
	int buffer = 0;

	while (1){

		SEGMENTS_BASE_ADDRESS   = read_keyboard();
		delay_(5000);

	}

	return 0;
}
