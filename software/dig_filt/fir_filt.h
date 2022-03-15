/* Digital filter peripheral 
*/
#ifndef _FIR_FILT
#define _FIR_FILT

#include "../_core/hardware.h"
#include "../_core/utils.h"

typedef struct {
  _IO32 coef0;
  _IO32 coef1;
  _IO32 coef2;
  _IO32 coef3; 
  _IO32 dadomsb;
  _IO32 dadolsb;
} DIG_FIL_REG_TYPE;

#define FIR_FILT_CTRL ((DIG_FIL_REG_TYPE *) &FIR_FILT_BASE_ADDRESS )
  
  
void fir_filter_coefficient0(uint32_t coefficient);
void fir_filter_coefficient1(uint32_t coefficient);
void fir_filter_coefficient2(uint32_t coefficient);
void fir_filter_coefficient3(uint32_t coefficient);
uint32_t fir_filt_get_output_msb_data();
uint32_t fir_filt_get_output_lsb_data();

#endif
