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
		delay_(100000);
	}
	return 0;
}



// #include "utils.h"
// #include "uart.h"
// #include "hardware.h"



// int main(){

// 	int count = 0x0f;
// 	int input = 0x00;

// 	while (1){
// 		/* To blink */
// 		// count = count +1;
// 		// if(count==0xff){
// 		// 	count = 0x00;
// 		// }

// 		// OUTBUS = count;
// 		// SEGMENTS = 0xFFFFFFC0;
// 		// delay_(10000);

// 		// OUTBUS = 0;
//   //       SEGMENTS = 0xFFFFFFFF;
// 		// delay_(10000); 

// 		/* To test Data Bus 
// 		x = INBUS;        
// 		OUTBUS = x; */	

// 		input = INBUS;


// 		switch(input){
// 			case 0x00 : SEGMENTS = 0xFFFFFFEF; break; // 01111111
// 			case 0x01 : SEGMENTS = 0xFFFFFFCF; break; // 11110011
// 			case 0x02 : SEGMENTS = 0xFFFFFFEA; break; // 11101010
// 			case 0x03 : SEGMENTS = 0xFFFFFF9E; break; //  10011110
// 			case 0x04 : SEGMENTS = 0xFFFFFF04; break; // 
// 			case 0x05 : SEGMENTS = 0xFFFFFF05; break; // 
// 			case 0x06 : SEGMENTS = 0xFFFFFF06; break;
// 			case 0x07 : SEGMENTS = 0xFFFFFF07; break;
// 			case 0x08 : SEGMENTS = 0xFFFFFF08; break;
// 			case 0x09 : SEGMENTS = 0xFFFFFF09; break;
// 			case 0x0a : SEGMENTS = 0xFFFFFF0a; break;
// 			case 0x0b : SEGMENTS = 0xFFFFFF0b; break;
// 			case 0x0c : SEGMENTS = 0xFFFFFF0c; break;
// 			case 0x0d : SEGMENTS = 0xFFFFFF0d; break;
// 			case 0x0e : SEGMENTS = 0xFFFFFF0e; break;
// 			default : break;
// 		}

// 	}

// 	return 0;
// }
