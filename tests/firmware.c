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
#include "uart.h"
#include "hardware.h"
#include "timer.h"



int main(){

    //*(uint32_t *)TIMER_0 = 3;

	/*                 
	TIMER_0->config.BIT.timer_reset = 1;
	TIMER_0->config.BIT.timer_mode = 3;
	TIMER_0->config.BIT.prescaler = 1;
    */

    TIMER_0->timer_reset = 1;

    TIMER_0->timer_mode = 1;
    TIMER_0->prescaler = 1;

    TIMER_0->compare_0A = 2;
    TIMER_0->compare_0B = 3;
    TIMER_0->compare_1A = 4;
    TIMER_0->compare_1B = 5;
    TIMER_0->compare_2A = 6;
    TIMER_0->compare_2B = 7;

    TIMER_0->timer_reset = 0;

    for(;;);

//	uint8_t i = 0;
//
//
//	SEGMENTS = 0xFFFFFFF0;
//
//	while (1){
//		/* To blink */
//		OUTBUS = 0x07;
//		//SEGMENTS = 0xFFFFFFC0;
//
//		SEGMENTS = SEGMENTS & 0xFFFFFFF0;
//		SEGMENTS |= (i & 0x0F);
//
//		delay_(10000);
//
//		OUTBUS = 0;
//        //SEGMENTS = 0xFFFFFFF0;
//		delay_(10000);
//
//		/* To test Data Bus
//		x = INBUS;
//		OUTBUS = x; */
//
//
//		i++;
//	}

	return 0;
}
