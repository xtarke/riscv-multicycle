/*
 * spwm.h
 *
 *  Created on: June 20, 2023
 *      Author: Gabriel Ayres Rodrigues
 *      Instituto Federal de Santa Catarina
 *
 */

#ifndef __SPWM_H
#define __SPWM_H

#include <stdint.h>
#include "../_core/hardware.h"

typedef struct {
  // Inputs
  _IO32 sine_freq;
  _IO32 mod_freq;
  _IO32 amp_mod_ratio;

} SPWM_TYPE;


#define SPWM_0 ((SPWM_TYPE *) &SPWM_BASE_ADDRESS)

// suggestions
void spwm_set_sine_frequency(uint32_t frequency);
void spwm_set_modulator_frequency(uint32_t frequency);
void spwm_set_amplitude_modulation_ratio(uint32_t amplitude_ratio);

uint32_t spwm_get_sine_frequency(void);
uint32_t spwm_get_modulator_frequency(void);
uint32_t spwm_get_amplitude_ratio(void);

#endif // __SPWM_H
