/* Digital filter peripheral HAL
   Tarcis Aurélio Becher  14/10/2020
*/
#ifndef _XABLAU_
#define _XABLAU_

#include "hardware.h"
#include "utils.h"

#define RESET_REGS 	0x00000001
#define NEW_DATA 	0x00000002

uint32_t dig_filt_data_is_ready();

void dig_filt_reset();
void dig_filt_add_data(uint32_t data_in);
uint32_t dig_filt_get_output();

#endif