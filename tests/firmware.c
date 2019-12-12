/*
 * firmware.c
 *
 *  Created on: Jan 20, 2019
 *      Author: Renan Augusto Starke
 		Modifyed by : Diogo Tavares - Dez 09, 2019
 *      Instituto Federal de Santa Catarina
 * 
 * 
 * Simple LED blink example.
 * -----------------------------------------
 */

#include "utils.h"
#include "spi.h"
#include "hardware.h"
#include <limits.h>

int main(){
	// 
	uint8_t data_out = 0xa2;
	// uint8_t data_in = 0x00;
	
	while (1){
		spi_write(data_out++);
		// spi_write(INBUS); 
		//SEGMENTS = spi_read();
		delay_(10000);
	}
	return 0;
}



