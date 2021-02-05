/*
 * main_spi.c
 *
 *  Created on: Dez, 2019
 *      Author: Diogo Tavares, José Nicolau Varela
 *      Instituto Federal de Santa Catarina
 * 
 * -----------------------------------------
 */

#include "../_core/utils.h"
#include "spi.h"
#include "../_core/hardware.h"
#include <limits.h>

int main(){
	// 
	uint8_t data_out = 0xa2;
	// uint8_t data_in = 0x00;
	
	while (1){
		spi_write(data_out++);
		// spi_write(INBUS_BASE_ADDRESS); 
		//SEGMENTS = spi_read();
		delay_(10000);
	}
	return 0;
}
