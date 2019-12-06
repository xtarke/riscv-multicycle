/*
 * spi.h
 *
 *  Created on: July 1, 2019
 *      Author: 
 *      Instituto Federal de Santa Catarina
 */

#include <stdint.h>
#include "spi.h"
#include "hardware.h"

void spi_write(uint8_t data){
	SPI_OUT = (0x01 << 8) | data;
	return;
}

uint8_t spi_read(void){
	uint8_t byte;	
	byte = SPI_IN;
	return byte;
}

