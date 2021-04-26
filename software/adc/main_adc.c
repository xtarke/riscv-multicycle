/*
 * adc_main.c
 *
 *  Created on: Jan 20, 2019
 *      Author: Jeferson Pedroso
 *              Leticia de Oliveira Nunes
 *              Marieli Matos
 *      Modified: Renan Augusto Starke
 * 		Instituto Federal de Santa Catarina
 * 
 * 
 * ADC main example.
 * -----------------------------------------
 */

#include "../_core/utils.h"
#include "../_core/hardware.h"
#include "adc.h"

int main(){	

	uint32_t adc_value;
	uint32_t adc_ch = 1;
	
	//x faz a varredura dos canais para teste!
	while (1){
		//if (adc_ch == 17)
			adc_ch = 1;
		//função para ler o adc do kit DE10_LITE
		adc_value = adc_read(adc_ch);
		delay_(10000);
		adc_ch++;
		OUTBUS = adc_value;
	}
	return 0;
}
