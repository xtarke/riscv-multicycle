/*
 * blink.c
 *
 *  Created on: Jan 20, 2019
 *              May 11, 2020
 *      Author: Renan Augusto Starke
 *      Instituto Federal de Santa Catarina
 *
 *
 * Simple LED blink example with GPIO input
 * -----------------------------------------
 */

#include "../_core/utils.h"
#include "../_core/hardware.h"
#include "../gpio/gpio.h"
#include "interrupt.h"
#include "../timer/timer.h"

#define USE_GLOBAL_VAR

volatile uint32_t global_1 = 0x5;
volatile uint32_t global_2 = 0x8;
volatile uint32_t teste[4] = {0x24, 0x35, 0x58, 0x47};

void EXTI0_IRQHandler(void)
{
#ifndef USE_GLOBAL_VAR
	OUTBUS = 0x52;
#else
	OUTBUS = global_1;
#endif

	global_1++;

}

void EXTI1_IRQHandler(void)
{
#ifndef USE_GLOBAL_VAR
	OUTBUS = 0xf4;
#else
	OUTBUS = global_2;
#endif
}

void TIMER0_0A_IRQHandler(void)
{
	static uint32_t i = 0;

	SEGMENTS_BASE_ADDRESS = teste[i];  //SEGMENTS_BASE_ADDRESS + 1;

	i++;
	i &=0x03;
}

/* Check hardware */
void TIMER0_0B_IRQHandler(void)
{
	// SEGMENTS_BASE_ADDRESS = SEGMENTS_BASE_ADDRESS  + 1;
}

void init_timer0(void)
{
    uint32_t events;

    TIMER_0->timer_reset = 1;

    TIMER_0->timer_mode = 1;
    TIMER_0->prescaler = 1000;
    TIMER_0->top_counter = 150;

    TIMER_0->compare_0A = 100;
    TIMER_0->compare_0B = 600;
    TIMER_0->compare_1A = 10;
    TIMER_0->compare_1B = 10;
    TIMER_0->compare_2A = 10;
    TIMER_0->compare_2B = 10;
    TIMER_0->enable_irq = 1;
    TIMER_0->timer_reset = 0;

}

int main(){
	volatile uint32_t data = 0;
	
	input_interrupt_enable(GPIO0,RISING_EDGE);
    	input_interrupt_enable(GPIO1,RISING_EDGE);
	init_timer0();

	extern_interrupt_enable(true);
	timer_interrupt_enable(true);
	global_interrupt_enable(true);

	teste[2] = 3;
	
	while (1){
        	data++;
        }

	return 0;
}

