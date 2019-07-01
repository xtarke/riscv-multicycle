/*
 * firmware.c
 *
 *  Created on: Jan 20, 2019
 *      Author: Renan Augusto Starke
 *      Instituto Federal de Santa Catarina
 * 
 * 
 * Simple LED blink example.
 * -----------------------------------------
 */


#include "utils.h"
#include "hardware.h"
#include "hardware_ADC_7SEG.h"

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
		
		
		/* To blink */
		//OUTBUS = 0x10;
		//SEGMENTS = 0xFFFFFFC0;
		//delay_(10000);
        
		//OUTBUS = 0;
        //SEGMENTS = 0xFFFFFFFF;
		//delay_(10000); 
        
		/* To test Data Bus 
		x = INDATA_ADC;        
		OUTBUS = x; */
	}

	return 0;
}
