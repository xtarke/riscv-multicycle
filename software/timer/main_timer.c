/*
 * firmware.c
 *
 *  Created on: Dez 09, 2019
 *      Author: JoÃ£o AntÃ´nio Cardoso e Rafael Fernando Reis
 *      Instituto Federal de Santa Catarina
 * 
 * Simple Timer tests and examples
 * -----------------------------------------
 */
#include "../_core/utils.h"
#include "../_core/hardware.h"
#include "timer.h"
#include "../gpio/gpio.h"

void test_mode_0(void);
void test_mode_1(void);
void test_mode_2(void);
void test_mode_3(void);
void test_mode_4(void);
void test_mode_5(void);
void test_mode_6(void);
void example_heartbeat(void);

void test_mode_0(void)
{
    uint32_t events;

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
}

void test_mode_1(void)
{
    uint32_t events;

    TIMER_0->timer_reset = 1;

    TIMER_0->timer_mode = 1;
    TIMER_0->prescaler = 1;
    TIMER_0->top_counter = 10;

    TIMER_0->compare_0A = 2;
    TIMER_0->compare_0B = 3;
    TIMER_0->compare_1A = 4;
    TIMER_0->compare_1B = 5;
    TIMER_0->compare_2A = 6;
    TIMER_0->compare_2B = 7;

    TIMER_0->timer_reset = 0;

    events = 4;
    while(--events) while(!TIMER_0->output_0A);
}



void test_mode_2(void)
{
    uint32_t events;

    TIMER_0->timer_reset = 1;

    TIMER_0->timer_mode = 2;
    TIMER_0->prescaler = 2;
    TIMER_0->top_counter = 10;

    TIMER_0->compare_0A = 2;
    TIMER_0->compare_0B = 3;
    TIMER_0->compare_1A = 4;
    TIMER_0->compare_1B = 5;
    TIMER_0->compare_2A = 6;
    TIMER_0->compare_2B = 7;

    TIMER_0->timer_reset = 0;

    events = 4;
    while(--events) while(!TIMER_0->output_0A);
}

void test_mode_3(void)
{
    uint32_t events;

    TIMER_0->timer_reset = 1;

    TIMER_0->timer_mode = 3;
    TIMER_0->prescaler = 2;
    TIMER_0->top_counter = 10;

    TIMER_0->compare_0A = 2;
    TIMER_0->compare_0B = 3;
    TIMER_0->compare_1A = 4;
    TIMER_0->compare_1B = 5;
    TIMER_0->compare_2A = 6;
    TIMER_0->compare_2B = 7;

    TIMER_0->timer_reset = 0;

    events = 4;
    while(--events) while(!TIMER_0->output_0A);
}   

void example_heartbeat(void)
{
	const uint32_t top_counter = 1000;
	const uint32_t divider_top = 100;
	static uint32_t divider = divider_top;
	static int32_t updown = 1; 
    static uint32_t duty_cycle = 0;

	TIMER_0->timer_reset = 1;

	TIMER_0->timer_mode = 3;
	TIMER_0->prescaler = 10;
	TIMER_0->top_counter = top_counter;

	TIMER_0->timer_reset = 0;

	if(!--divider){
		divider = divider_top;
		duty_cycle += updown;

		if((duty_cycle == top_counter) | (!duty_cycle)) updown = -updown;

		TIMER_0->compare_0A = duty_cycle;
		TIMER_0->compare_1A = 500;
		TIMER_0->compare_2A = 950;
		TIMER_0->compare_0B = 950;
		TIMER_0->compare_1B = 500;
		TIMER_0->compare_2B = duty_cycle;
	}
}

void test_mode_4(void)
{
    uint32_t events;

    TIMER_0->timer_reset = 1;

    TIMER_0->timer_mode = 4;
    TIMER_0->prescaler = 1;

    TIMER_0->timer_reset = 0;

    while (TIMER_0->capture_value == 0);
    SEGMENTS_BASE_ADDRESS = TIMER_0->capture_value;
}   


void test_mode_5(void)
{
    uint32_t events;

    TIMER_0->timer_reset = 1; 

    TIMER_0->timer_mode = 5;
    TIMER_0->prescaler = 2;
    TIMER_0->top_counter = 20;
    TIMER_0->dead_time = 2;

    TIMER_0->compare_0A = 5;
    TIMER_0->compare_1A = 10;
    TIMER_0->compare_2A = 14;


    TIMER_0->timer_reset = 0;

}

void test_mode_6(void)
{
    uint32_t events;

    TIMER_0->timer_reset = 1;

    TIMER_0->timer_mode = 6;
    TIMER_0->prescaler = 2;
    TIMER_0->top_counter = 20;
    TIMER_0->dead_time = 2;

    TIMER_0->compare_0A = 5;
    TIMER_0->compare_1A = 10;
    TIMER_0->compare_2A = 14;


    TIMER_0->timer_reset = 0;

}

int main(void)
{

   test_mode_5();
   uint32_t data = 0;
  
    while(1){
        
        //test_mode_0();
        //test_mode_1();
        //test_mode_2();
        //test_mode_4();
	    //example_heartbeat();
	    	/* Read input bus */
		if (INBUS)
			/* Resets data when any input is high */
			data = 0;

		/* Counter blink */
		OUTBUS = data;
		SEGMENTS_BASE_ADDRESS = data;

		data++;

    }
	return 0;
}
