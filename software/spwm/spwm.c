#include "spwm.h"

void spwm_set_sine_frequency(uint32_t frequency){
	SPWM_0->sine_freq = frequency;
}
void spwm_set_modulator_frequency(uint32_t frequency){
	SPWM_0->mod_freq = frequency;
}
void spwm_set_amplitude_modulation_ratio(uint32_t amplitude_ratio){
	SPWM_0->amp_mod_ratio = amplitude_ratio;
}

uint32_t spwm_get_sine_frequency(void){
	return SPWM_0->sine_freq;
}
uint32_t spwm_get_modulator_frequency(void){
	return SPWM_0->mod_freq;
}
uint32_t spwm_get_amplitude_ratio(void){
	return SPWM_0->amp_mod_ratio;
}