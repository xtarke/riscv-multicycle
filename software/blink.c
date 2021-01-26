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

#include "utils.h"
#include "hardware.h"
#include "gpio.h"
#include "interrupt.h"


void EXTI0_IRQHandler(void)
{
	OUTBUS = 0xAB;
}

void EXTI1_IRQHandler(void)
{
	OUTBUS = 0x53;
}

void TIMER0_TRG_CMT_IRQHandler(void)
{
	int i = 0x53;
	OUTBUS = i;
}
void TIMER0_UP_IRQHandler(void)
{
	int i = 15;
	OUTBUS = i;
}

int main(){
	uint32_t data = 0;
	
	input_interrupt_enable(GPIO0,FALLING_EDGE);
    input_interrupt_enable(GPIO1,RISING_EDGE);

	extern_interrupt_enable(true);
	timer_interrupt_enable(true);
	global_interrupt_enable(true);

	while (1){

		/* Read input bus */
		//if (INBUS_BASE_ADDRESS)
			/* Resets data when any input is high */
			//data = 0;

		/* Counter blink */
		OUTBUS = data;
		delay_(500000);

		data++;
	}


	return 0;
}
