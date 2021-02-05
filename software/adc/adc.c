/*
 * adc.c
 *
 *  Created on: Jul 1, 2019
 *      Author: Jeferson Pedroso
 *      Modified: Renan Augusto Starke
 *      Instituto Federal de Santa Catarina
 * 
 * 
 * ADC functions example.
 * -----------------------------------------
 */

#include "../_core/hardware.h"
#include "adc.h"
#include "../gpio/gpio.h"

//Função para leitura do ADC. Recebe o canal a ser lido, bem como os ponteiros para gravar o valor e canal lidos.
void ADC_READ (int channel_sel, int *channel_read, int *value_read)
{
	int buffer;
	
	SEL_CH_ADC = channel_sel;
	buffer = INDATA_ADC;
	
	*value_read = buffer & 4095;
	*channel_read = (buffer >> 12) & 0b1111;;
}


//Função para escrita nos displays de 7 segmentos. Recebe os valores (hexa ou decimal) a ser enviado a cada display separadamente.
void SEGS7_WRITE (int disp5, int disp4, int disp3, int disp2, int disp1, int disp0)
{
	int buffer = 0;
	
	buffer = disp0;
	buffer |= (disp1<<4);
	buffer |= (disp2<<8);
	buffer |= (disp3<<12);
	buffer |= (disp4<<16);
	buffer |= (disp5<<20);
	
	SEGMENTS = buffer;
}
