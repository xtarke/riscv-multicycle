  /* FIR filter peripheral
*/

#include "fir_filt.h"

void fir_filter_coefficient0(uint32_t coefficient){

    FIR_FILT_CTRL-> coef0 = coefficient;
  
}

void fir_filter_coefficient1(uint32_t coefficient){

    FIR_FILT_CTRL-> coef1 = coefficient;
  
}

void fir_filter_coefficient2(uint32_t coefficient){

    FIR_FILT_CTRL-> coef2 = coefficient;
  
}

void fir_filter_coefficient3(uint32_t coefficient){

    FIR_FILT_CTRL-> coef3 = coefficient;
  
}

uint32_t fir_filt_get_output_msb_data(){
  return (FIR_FILT_CTRL -> dadomsb);
}

uint32_t fir_filt_get_output_lsb_data(){
  return (FIR_FILT_CTRL -> dadolsb);
}