/*
 * utils.h
 *
 *  Created on: Dez 9, 2019
 *      Author: Jhonatan; Alexsandro
 *      Instituto Federal de Santa Catarina
 *
 * I2c functions
 *  - send data
 *  - (...)
 *
 */

#include <stdint.h>
#include "i2c_mastert.h"
#include "hardware.h"

int I2C_write(uint8_t data, uint8_t addr){

// verificar se tempos de delay atendem
	int ack;

	// [ 32  31  30 29   	17	16	15 	14-8 7-0 ]
	// ack_err				rst ena rw  addr data			--futuro "1 bit busy"   --sda e scl?

	//pulso no rst
	I2C |= 0x40000000;
	delay_(20);
	I2C &= 0xBFFF8000;  // limpa o rst e os campos addr e data

	I2C |=  data;		// carrega dado
	I2C |=  (addr << 8);// carrega endereço

	// pulso no enable
	I2C |= 0x00008000;
	delay_(20);
	I2C &= 0xFFFF7FFF;

	delay_(300);
	//le o ack
	ack = (I2C >> 31);

}


