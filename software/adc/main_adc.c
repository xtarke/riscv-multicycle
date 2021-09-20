/*
 * adc_main.c
 *
 *  Created on: Jul 1, 2019
 *      Author: Kevin Jahn Ferreira
 				Jeferson Pedroso
 *              Leticia Nunes
 *              Marieli Matos
 *      Modified: Renan Augusto Starke
 *      Instituto Federal de Santa Catarina
 *
 * ADC main example.
 * -----------------------------------------
 */

#include <limits.h>
#include "../_core/utils.h"
#include "../_core/hardware.h"
#include "adc.h"
#include "../irq/interrupt.h" 

// Rotina de tratamento da interrupção
// Repassa a informação lida do ADC ao display e reseta a interrupção
void ADC0_IRQHandler(void){
	SEGMENTS_BASE_ADDRESS = ADC -> indata_adc;
	ADC->irq_adc_di = 1; // vai para o endereço 0x0033
}

int main(){

	uint32_t adc_value;
	uint32_t adc_ch = 1;

	ADC_interrupt_enable();
	extern_interrupt_enable(true);
	global_interrupt_enable(true);

	//x faz a varredura dos canais para teste!
	while (1){
		/* Pino A0 do KIT é canal 1 *
		 * Pino A1 do KIT é canal 2 */
		adc_ch = 9;

		//função para ler o adc do kit DE10_LITE
		adc_value = adc_read(adc_ch);

		/* Remover _delay se estiver no Modelsim */
		//delay_(100000);
		//adc_ch++;
	}
	return 0;
}
