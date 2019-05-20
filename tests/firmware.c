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


int main(){

	int i;
    int loop = 1;      
   
	while (loop){
        OUTBUS = 3;
        delay_(10000);
        OUTBUS = 0;
        delay_(10000);
    }

	return 0;
}
