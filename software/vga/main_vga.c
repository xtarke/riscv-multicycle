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


#include "../_core/utils.h"
#include "../_core/hardware.h"

#define VGA_RAM_SIZE 8192


int main(){
	int x = 0000;
	
	volatile uint32_t *ram = &SDRAM;

	for(x=0; x<VGA_RAM_SIZE; x++){
		ram[x]=0x000F; // 0BGR
		delay_(10000);
	}	
	
	

	return 0;
}
