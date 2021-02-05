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

#ifndef __HARDWARE_ADC_7SEG_H
#define __HARDWARE_ADC_7SEG_H

#include <stdint.h>
#include "../_core/hardware.h"

#define INDATA_ADC	*(&I2C_BASE_ADDRESS)
#define CH_ADC_FEED *(&I2C_BASE_ADDRESS + 1)
#define SEL_CH_ADC  *(&I2C_BASE_ADDRESS + 2)
//estrutura de dados para armazenar o valor e canal lidos.
struct adc_read
{
	int channel;
	int value;
};

void ADC_READ (int channel_sel, int *channel_read, int *value_read);

void SEGS7_WRITE (int disp5, int disp4, int disp3, int disp2, int disp1, int disp0);

#endif //HARDWARE_ADC_7SEG_H