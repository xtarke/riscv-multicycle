/*
 * adc.c
 *
 *  Created on: Jul 1, 2019
 *      Author: Kevin Jahn Ferreira
 				Jeferson Pedroso
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
#include "../irq/interrupt.h"

//Funcao para leitura do ADC. Recebe o canal a ser lido para gravar o canal lido.
uint32_t adc_read (uint32_t channel_sel)
{
	ADC -> sel_channel = channel_sel; //entra no endereço 0x0030 
    return ADC -> indata_adc; //entra no endereço 0x0031
}

// Função para ativar a interrupção do ADC
// Verificar o arquivo ADC_BUS.vhd no processo do output register
inline void ADC_interrupt_enable(void){
	ADC->irq_adc_en = 1; // entra no endereço 0x0032 onde habilita uma flag
}
