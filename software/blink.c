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

#include "_core/utils.h"
#include "_core/hardware.h"
#include "gpio/gpio.h"


void EXTI0_IRQHandler(void)
{
	OUTBUS = 0x52;
}

void EXTI1_IRQHandler(void)
{
	OUTBUS = 0xf4;
}

void TIMER0_0A_IRQHandler(void)
{
	OUTBUS = OUTBUS  + 1;
}
void TIMER0_0B_IRQHandler(void)
{
	OUTBUS = OUTBUS + 1;
}

void init_timer0(void)
{
    uint32_t events;

    TIMER_0->timer_reset = 1;
    TIMER_0->timer_mode = 1;
    TIMER_0->prescaler = 100;
    TIMER_0->top_counter = 999;
    TIMER_0->compare_0A = 100;
    TIMER_0->compare_0B = 600;
    TIMER_0->compare_1A = 10;
    TIMER_0->compare_1B = 10;
    TIMER_0->compare_2A = 10;
    TIMER_0->compare_2B = 10;
    TIMER_0->enable_irq = 3;
    TIMER_0->timer_reset = 0;
}

int main(){
	uint32_t data = 0;
	
	input_interrupt_enable(GPIO0,FALLING_EDGE);
   input_interrupt_enable(GPIO1,RISING_EDGE);
	init_timer0();

	while (1){
      HEX0 = ~timer_get_output0A();
		  HEX1 = ~timer_get_output0B();
	}

	return 0;
}