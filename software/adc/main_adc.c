/*
 * adc_main.c
 *
 *  Created on: Jan 20, 2019
 *      Author: Jeferson Pedroso
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
	struct adc_read adc_r;
	int buffer, dig[4];
	int x = 1, i;
	
	//x faz a varredura dos canais para teste!
	while (1){
		/* To ADC read and 7seg write */

		//função para ler o adc do kit DE10_LITE
		ADC_READ (x, &adc_r.channel, &adc_r.value);
		
		
		//Convertendo valor do ADC em mV e ºC no canal 17.
		if (adc_r.channel == 17)
		{
			buffer = (-2*adc_r.value)+3720;
		}
		else
		{
			buffer = 5000*adc_r.value/4095;
		}
		
		// digitos em decimal
		for (i=0; i<=3; i++)
		{
			dig[i] = buffer % 10;
			buffer = buffer/10;
		}
		
		//função para escrever digitos no display 7 segs do kit DE10_LITE
		SEGS7_WRITE (adc_r.channel, 0xC, dig[3], dig[2], dig[1], dig[0]);
		
		
		//delay e incremento para testar os diversos canais do kit.
		delay_(100000);
		x++;
	}

	return 0;
}
