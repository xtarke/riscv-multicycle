/*
 * firmware.c
 *
 *  Created on: Jan 20, 2019
 *      Author: Cleisson Fernandes Da Silva
 *      Instituto Federal de Santa Catarina
 * 
 * 
 * Simple SDRAM example.
 * -----------------------------------------
 */


#include "../_core/utils.h"
#include "../_core/hardware.h"
#include "../gpio/gpio.h"


int test_memory();
void test_memory_2();

int main(){
	int x = 0;

	while (1){
		OUTBUS = test_memory();
		delay_(10000);
		test_memory_2();
		delay_(10000);
	}
	return 0;
}


void test_memory_2(){
	int x = 0;
   volatile uint32_t *sdram = &SDRAM;
	for(x=0; x<64; x++){
		sdram[x] = x; 
	}
	delay_(100000); 

	for(x=0; x<64; x++){
		OUTBUS =  sdram[x];
		delay_(10000); 
	}
	for(x=0; x<64; x++){
		OUTBUS =  sdram[63-x];
		delay_(10000); 
	}
	
}


int test_memory(){
	int x = 0;
   volatile uint32_t *sdram = &SDRAM;
	volatile uint32_t vector[64];
	for(x=0; x<64; x++){
		vector[x] = x; 
	}
	for(x=0; x<64; x++){
		sdram[x] = vector[x]; 
	}
	delay_(10000);
	for(x=0; x<64; x++){
		if(sdram[x]!=vector[x]){
			return 0;
		}
	}
	return 1;
}