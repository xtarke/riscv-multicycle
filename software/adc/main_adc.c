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
	uint32_t x=1;
	
	//x faz a varredura dos canais para teste!
	while (1){
		
		//função para ler o adc do kit DE10_LITE
		adc_value = adc_read(x);
		
		
		//Convertendo valor do ADC em mV e tempºC no canal 17.
		//if (adc_r.channel == 17)
		//{
		//	buffer = (-2*adc_r.value)+3720;
		//}
		//else
		//{
		//	buffer = 5000*adc_r.value/4095;
		//}		
		// digitos em decimal
		//for (i=0; i<=3; i++)
		//{
		//  dig[i] = buffer % 10;
		//	buffer = buffer/10;
		//}
		
		// Testint ADC
        //adc_value = adc_read(1);
        //OUTBUS = adc_value;
        //delay_(10000);
        x++;
        x = x & 0xf;
	}
	return 0;
}
