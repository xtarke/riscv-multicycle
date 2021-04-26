/*
 * Instituto Federal de Santa Catarina - Câmpus Florianópolis
 * Departamento Acadêmico de Eletrônica
 * Curso de Engenharia Eletrônica
 * Unidade Curricular: Dispositivos Lógico-Programáveis (PLD)
 * Professor:
 * -	Renan Augusto Starke	- renan.starke@ifsc.edu.br
 * Estudantes:
 * -	Heloiza Schaberle 		- heloizaschaberle@gmail.com
 * -	Vítor Faccio 			- vitorfaccio.ifsc@gmail.com
 *
 * watchdog.c
 *
 */

#include "watchdog.h"

void wtd_config(uint32_t wtd_mode, uint32_t prescaler, uint32_t top_counter) {
	WTD->wtd_reset = 1;
	WTD->wtd_mode = wtd_mode;
	WTD->prescaler = prescaler;
	WTD->top_counter = top_counter;
}

void wtd_enable(void) {
	WTD->wtd_reset = 0;
}

void wtd_disable(void) {
	WTD->wtd_reset = 1;
}

void wtd_hold(uint32_t hold){
	WTD->wtd_hold = hold;
}

uint32_t wtd_interrupt_read(void){
	return  WTD->wtd_interrupt;
}

void wtd_clearoutputs(void){
	WTD->wtd_interrupt_clr = 1;
	WTD->wtd_interrupt_clr = 0;
}









