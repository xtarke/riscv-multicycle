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

#ifndef __ADC_H
#define __ADC_H

#include <stdint.h>
#include "../_core/hardware.h"

//estrutura de dados para armazenar o valor e canal lidos, e interrupções.
typedef struct 
{
	uint32_t sel_channel; 		// 0x0030       
	uint32_t indata_adc;        // 0x0031	
	uint32_t irq_adc_en; 			// 0x0032 irq enable
	uint32_t irq_adc_di; 			// 0x0033 irq disable
}ADC_TYPE;

//ADC_BASE_ADDRESS esta definido no arquivo hardware.h na pasta software\_core
#define OUTBUS  *(&IONBUS_BASE_ADDRESS + 1)
#define ADC ((ADC_TYPE *) &ADC_BASE_ADDRESS)

uint32_t adc_read (uint32_t channel_sel);
void ADC_interrupt_enable(void);

#endif //__ADC_H