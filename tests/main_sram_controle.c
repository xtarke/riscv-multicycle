/*
 * sram_controle.c
 *
 *      Author: Bruna e Maria
 *      Instituto Federal de Santa Catarina
 *
 *
 */


#include "utils.h"
#include "hardware.h"


int main(){
	int x = 0;
	int i = 0;
	volatile uint32_t *sdram = &SDRAM;

	while (1){

		for(x=0; x<16; x++){
				 sdram[x] = 1;
		}

		for(x=0; x<16; x++){
			OUTBUS =  sdram[x];
			delay_(5); //ToDo: SDRAM refresh and init are not working.
		}

		/* To test Data Bus
		x = INBUS;
		OUTBUS = x; */
	}

	return 0;
}
