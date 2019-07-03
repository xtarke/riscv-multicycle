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
#include "hardware.h"

#define RAM_BASE		((uint32_t)0x60000)          /*!< SRAM  base address*/
#define RAM				(*(_IO32 *) (RAM_BASE))

#define VGA_RAM_SIZE 8192


int main(){
	int x = 0000;
	
	volatile uint32_t *ram = &RAM;

	for(x=0; x<VGA_RAM_SIZE; x++){
		ram[x]=0x000F; // 0BGR
	}
	while (1){
		delay_(10);
	}

	return 0;
}
