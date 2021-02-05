/*
 * firmware.c
 *
 *  Created on: December 6, 2019
 *      Author: Alexsandro Gehlen; Jhonatan Lang
 *      Instituto Federal de Santa Catarina
 *
 *
 * Simple LED blink example.
 * -----------------------------------------
 */


#include "../_core/utils.h"
#include "i2c_master.h"
#include "../_core/hardware.h"


int main(){

	int ack;

	while(1)
	{
	//	Exemplo "pisca LED" com back ligth do display I2C
		ack = I2C_write( 0x01, 0b00100111);//0b00100111);
		delay_(10000);
		ack = I2C_write( 0xFF, 0b00100111);//0b00100111);
		delay_(10000);
	}

	return 0;
}
