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
#include "timer.h"

int main(void){
    while(1){
        static uint32_t events;
        uint32_t prescaler = 10;
        uint32_t top_counter = 1000;
        /*
        // test mode 0
        TIMER_0->timer_reset = 1;
        TIMER_0->timer_mode = 0;
        TIMER_0->prescaler = prescaler;
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
        */

        static uint32_t duty_cycle = 0;

        // test mode 1
        TIMER_0->timer_reset = 1;
        TIMER_0->timer_mode = 3;
        TIMER_0->prescaler = prescaler;
        TIMER_0->top_counter = top_counter;
        TIMER_0->timer_reset = 0;
        const uint32_t divider_top = 100;
        uint32_t divider = divider_top;
        int32_t updown = 1;

        while(1){
            if(!--divider){
                divider = divider_top;
                duty_cycle += updown;

                if(duty_cycle == top_counter){
                    updown = -1;
                }else if(duty_cycle == 0){
                    updown = 1;
                }
                
                TIMER_0->compare_0A = duty_cycle;
                TIMER_0->compare_1A = 500;
                TIMER_0->compare_2A = 950;
                TIMER_0->compare_0B = 950;
                TIMER_0->compare_1B = 500;
                TIMER_0->compare_2B = duty_cycle;
            }
            //events = 4;
            //while(--events) while(!TIMER_0->output_0A);
        }
        /*
        // test mode 2
        TIMER_0->timer_reset = 1;
        TIMER_0->timer_mode = 2;
        TIMER_0->prescaler = prescaler;
        TIMER_0->timer_reset = 0;
        events = 4;
        while(--events) while(!TIMER_0->output_0A);

        // test mode 3
        TIMER_0->timer_reset = 1;
        TIMER_0->timer_mode = 3;
        TIMER_0->prescaler = prescaler;
        TIMER_0->timer_reset = 0;
        events = 4;
        while(--events) while(!TIMER_0->output_0A);
        */
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
