/*
 * main_spwm.c
 *
 *  Created on: Jun 23, 2023
 *      Author: Gabriel Ayres Rodrigues
 *      Instituto Federal de Santa Catarina
 * 
 * -----------------------------------------
 */

#include "../_core/utils.h"
#include "../_core/hardware.h"
#include "../gpio/gpio.h"
#include "spwm.h"

void example_spwm(void){

    spwm_set_sine_frequency(50);
    spwm_set_amplitude_modulation_ratio(100);
    spwm_set_modulator_frequency(1000);
}

int main(void){
  // SPWM Variables
  uint32_t sine_frequency = 50;
  uint32_t modulator_frequency = 1000;
  uint32_t amplitude_ratio = 100;    // %

    example_spwm();

    while(1){
        
        modulator_frequency = 1000;
        if(INBUS)
            modulator_frequency = 2*1000;
        
        spwm_set_modulator_frequency(modulator_frequency);

        SEGMENTS_BASE_ADDRESS = modulator_frequency;

        /* Comment delay for testbench and uncomment for synthesis. */
        // delay_(10000);
    }
    return 0;
}
