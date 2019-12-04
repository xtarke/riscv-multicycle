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

int main(void){
    while(1){
        static uint32_t events;

        // test mode 0
        TIMER_0->timer_reset = 1;
        TIMER_0->timer_mode = 0;
        TIMER_0->prescaler = 1;
        TIMER_0->top_counter = 10;
        TIMER_0->compare_0A = 2;
        TIMER_0->compare_0B = 3;
        TIMER_0->compare_1A = 4;
        TIMER_0->compare_1B = 5;
        TIMER_0->compare_2A = 6;
        TIMER_0->compare_2B = 7;
        TIMER_0->timer_reset = 0;
        for(events = 4; events;){
            if(TIMER_0->output_2A){
                TIMER_0->timer_reset = 1;
                events--;
                TIMER_0->timer_reset = 0;
            }
        }

        // test mode 1
        TIMER_0->timer_reset = 1;
        TIMER_0->timer_mode = 1;
        TIMER_0->prescaler = 1;
        TIMER_0->top_counter = 10;
        TIMER_0->timer_reset = 0;
        events = 4;
        while(--events) while(!TIMER_0->output_0A);

        // test mode 2
        TIMER_0->timer_reset = 1;
        TIMER_0->timer_mode = 2;
        TIMER_0->prescaler = 2;
        TIMER_0->timer_reset = 0;
        events = 4;
        while(--events) while(!TIMER_0->output_0A);

        // test mode 3
        TIMER_0->timer_reset = 1;
        TIMER_0->timer_mode = 3;
        TIMER_0->prescaler = 2;
        TIMER_0->timer_reset = 0;
        events = 4;
        while(--events) while(!TIMER_0->output_0A);

    }   


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
