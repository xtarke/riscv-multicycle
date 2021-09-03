/* Digital filter peripheral
*/

#include "dig_filt.h"

void dig_filt_reset(uint8_t data){
  DIG_FILT_CTRL-> reset = data;
}

void dig_filt_enable(uint8_t data){
  DIG_FILT_CTRL-> enable = data;
}

uint32_t dig_filt_get_output(){
  return (DIG_FILT_OUT);
}