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
<<<<<<< HEAD
#include "i2c_master.h"
#include "utils.h"
=======
#include "i2c_mastert.h"
>>>>>>> cb5b91ddc8a8f1db590880c74afc8d74e09835e9
#include "hardware.h"

int I2C_write(uint8_t data, uint8_t addr){

// verificar se tempos de delay atendem
	int ack;

	// [ 31  	30   30  29 14-8 7-0 ]
	// ack_err	rst  ena rw addr data	--  inplementar no futuro "1 bit busy"

	//pulso no rst
	I2C = 0x40000000;  // limpa o ack_err, rst e os campos addr e data
	delay_(20);
	I2C = 0x00000000;


<<<<<<< HEAD
	I2C =  (addr * 256) + data;// carrega endereï¿½o
=======
	I2C =  (addr * 256) + data;// carrega endereço
>>>>>>> cb5b91ddc8a8f1db590880c74afc8d74e09835e9

	// pulso no enable
	I2C = I2C | 0x20000000;
	delay_(2);
	I2C &= 0xDFFFFFFF;
<<<<<<< HEAD
	delay_(100);	// ##### CONFERIR SE ESSE TEMPO DE DELAY ï¿½ SUFICIENTE ####
=======
	delay_(100);	// ##### CONFERIR SE ESSE TEMPO DE DELAY É SUFICIENTE ####
>>>>>>> cb5b91ddc8a8f1db590880c74afc8d74e09835e9
	//le o ack
	ack = (I2C >> 31);

	return ack;
}
