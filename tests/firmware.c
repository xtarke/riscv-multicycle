/*
 * firmware.c
 *
 *  Created on: Jan 20, 2019
 *      Author: Renan Augusto Starke
 *      Instituto Federal de Santa Catarina
 * 
 * 
 * Simple LED blink example.
 * -----------------------------------------
 */


#include "utils.h"
//#include "i2c_master.h"
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


int main(){


//	int ack;
	SEGMENTS = 0xFFFFFFF0;

	uint8_t i = 0;
	
	while (1){
		
		// To blink
		OUTBUS = 0x07;
		//SEGMENTS = 0xFFFFFFC0;
		
		SEGMENTS = SEGMENTS & 0xFFFFFFF0;
		SEGMENTS |= (i & 0x0F);
		
		delay_(10000);

		OUTBUS = 0;
        //SEGMENTS = 0xFFFFFFF0;
		delay_(10000); 


		/* To test Data Bus
		x = INBUS;        
		OUTBUS = x;*/
	}



/*	while(1)
	{
		I2C |= 0x40000000;
		//ack = I2C_write( 0xFF, 0b01101000);
		delay_(100);

	}
*/



	return 0;
}
