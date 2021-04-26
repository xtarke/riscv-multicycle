/*
 * adc.c
 *
 *  Created on: Jul 1, 2019
 *      Author: Jeferson Pedroso
 *              Leticia Nunes
 *              Marieli Matos
 *      Modified: Renan Augusto Starke
 *      Instituto Federal de Santa Catarina
 * 
 * 
 * ADC functions example.
 * -----------------------------------------
 */

#include "adc.h"

//Função para leitura do ADC. Recebe o canal a ser lido para gravar o canal lido.

uint32_t adc_read (uint32_t channel_sel)
{
	ADC -> sel_channel = channel_sel;
	
    return ADC -> indata_adc;
}