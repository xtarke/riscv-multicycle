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

#include "../_core/hardware.h"
#include "adc.h"
#include "../gpio/gpio.h"

//Função para leitura do ADC. Recebe o canal a ser lido, bem como os ponteiros para gravar o valor e canal lidos.

uint32_t adc_read (uint32_t channel_sel)
{
	ADC -> sel_ch_adc = channel_sel;
    
    return ADC -> indata_adc;
}
