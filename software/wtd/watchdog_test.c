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
 * watchdog_test.c
 *
 */

#include "../_core/utils.h"
#include "../_core/hardware.h"
#include "../gpio/gpio.h"
#include "watchdog.h"


int main(){

	uint32_t wtd_mode = 1;
	uint32_t prescaler = 1;
	uint32_t top_counter = 250; // pra dar +- em 1/8 da simulação

	wtd_config(wtd_mode, prescaler, top_counter);

	wtd_enable();
	delay_(10);
	wtd_disable();
	delay_(10);


	wtd_enable();
	delay_(3);
	wtd_hold(1);
	delay_(3);
	wtd_hold(0);

	delay_(40);
	wtd_disable();

	delay_(10);
	wtd_enable();
	while(!wtd_interrupt_read());
	OUTBUS = 1;

	while (1){

		delay_(10000);

	}

	return 0;
}
