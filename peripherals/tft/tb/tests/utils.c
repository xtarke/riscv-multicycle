/*
 * utils.c
 *
 *  Created on: May 20, 2019
 *      Author: Renan Augusto Starke
 *      Instituto Federal de Santa Catarina
 * 
 * Utility functions
 *  - delays
 *  - (...)
 * 
 */

#include <stdint.h>
#include "hardware.h"

void delay_(uint32_t loop_count){    
    while(loop_count--);    
}
