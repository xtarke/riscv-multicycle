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
	SPI_TX = (0x01 << 8) | data;   // coloca o dado na memória e a flag para o tx_start
	return;
}

uint8_t spi_read(void){  
	return SPI_RX;               // retorna o que está na memória
}

