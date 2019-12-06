/*
 * firmware.c
 *
 *  Created on: Dez, 2019
 *      Author: 
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
	
	uint8_t data_out = 0x01;
	uint8_t data_in = 0x00;
	
	while (1){
		spi_write(data_out++);
		data_in = spi_read();
		SPI_IN = data_in;
		delay_(2000);
	}
	return 0;
}
