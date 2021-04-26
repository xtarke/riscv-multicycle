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

/*
 * Instituto Federal de Santa Catarina - Câmpus FLorianópolis
 * Departamento Acadêmico de Eletrônica
 * Curso de Engenharia Eletrônica
 * Unidade Curricular: Dispositivos Lógico-Programáveis (PLD)
 * Professor:
 * -	Renan Augusto Starke	- renan.starke@ifsc.edu.br
 * Estudantes:
 * -	Heloiza Schaberle 		- heloizaschaberle@gmail.com
 * -	Vítor Faccio 			- vitorfaccio.ifsc@gmail.com
 *
 * Arquivo .C de teste dos periféricos GPIO e Timer
 * blink simples com uso de timer ao invés de delay_()
 */

#include "../_core/utils.h"
#include "../_core/hardware.h"
#include "../gpio/gpio.h"
#include "../irq/interrupt.h"
#include "../timer/timer.h"
#include "watchdog.h"

void EXTI0_IRQHandler(void);
void EXTI1_IRQHandler(void);
void TIMER0_0A_IRQHandler(void);
void TIMER0_0B_IRQHandler(void);
void init_timer0(void);
void shoot_timer0(void);

uint32_t data;


int main(){

	data = 1;
	OUTBUS = data;

	input_interrupt_enable(GPIO0,RISING_EDGE);
	input_interrupt_enable(GPIO1,RISING_EDGE);
	//init_timer0();
	extern_interrupt_enable(true);
	timer_interrupt_enable(true);
	global_interrupt_enable(true);

	wtd_config(1, 2, 65535);

	while (1){

		wtd_enable();
		while(!wtd_interrupt_read());
		wtd_disable();
		data++;
		OUTBUS = data;

	}

	return 0;
}


void EXTI0_IRQHandler(void)
{
	//Shoot Timer, IRQ do timer vai acender o LED
	shoot_timer0();
}
void EXTI1_IRQHandler(void)
{
	data = 0;
}

void TIMER0_0A_IRQHandler(void)
{
    TIMER_0->timer_reset = 1;
	if (INBUS > 1)
		/* Resets data when any input is high */
		data = 5;
	else
		data++;
	OUTBUS = data;
}
void TIMER0_0B_IRQHandler(void)
{

}

void init_timer0(void)
{
    uint32_t events;

    TIMER_0->timer_reset = 1;

    TIMER_0->timer_mode = 1;
    TIMER_0->prescaler = 500;
    TIMER_0->top_counter = 1000;

    TIMER_0->compare_0A = 500;
    TIMER_0->compare_0B = 999;
    TIMER_0->compare_1A = 10;
    TIMER_0->compare_1B = 10;
    TIMER_0->compare_2A = 10;
    TIMER_0->compare_2B = 10;
    TIMER_0->enable_irq = 3;
    TIMER_0->timer_reset = 0;

}

void shoot_timer0(void)
{
	uint32_t events;

	TIMER_0->timer_reset = 1;

	TIMER_0->timer_mode = 0;
	TIMER_0->prescaler = 1000;
	TIMER_0->top_counter = 2000;

	TIMER_0->compare_0A = 500;
	TIMER_0->compare_0B = 999;
	TIMER_0->compare_1A = 4;
	TIMER_0->compare_1B = 5;
	TIMER_0->compare_2A = 6;
	TIMER_0->compare_2B = 7;
    TIMER_0->enable_irq = 3;

	TIMER_0->timer_reset = 0;

}



