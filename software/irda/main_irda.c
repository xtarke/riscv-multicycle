/*
 * main_irda.c
 *
 *  Created on: Fev 27, 2025
 *      Author: Guido Locks Momm
 *      Instituto Federal de Santa Catarina
 * 
 * Simple IRDA sensor implementation
 * -----------------------------------------
 */
#include "../_core/hardware.h"
#include "../gpio/gpio.h"
#include "../_core/utils.h"

int main(void){
    while(1){
        SEGMENTS_BASE_ADDRESS = IRDA_BASE_ADDRESS;
        delay_(1000);
    }
	return 0;
}