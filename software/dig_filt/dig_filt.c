/* Digital filter peripheral HAL
   Tarcis Aurélio Becher  14/10/2020
*/

#include "dig_filt.h"

uint32_t dig_filt_data_is_ready(){
	return (DIG_FILT_CTRL >> 31)&(1);
}

void dig_filt_reset(){
	DIG_FILT_CTRL = RESET_REGS;
	while(!dig_filt_data_is_ready());
}

void dig_filt_add_data(uint32_t data_in){
	DIG_FILT_IN = data_in;
	DIG_FILT_CTRL = NEW_DATA;
	while(!dig_filt_data_is_ready());
}

uint32_t dig_filt_get_output(){
	return DIG_FILT_OUT;	
}