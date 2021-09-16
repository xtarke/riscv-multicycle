/* Digital filter peripheral 
*/
#ifndef _DIF_FILT
#define _DIF_FILT

#include "../_core/hardware.h"
#include "../_core/utils.h"

typedef struct {
  _IO8 enable :1 ;           /*!< Bit habilitação filto */
  _IO8 reset  :1 ;           /*!< Bit de filtro Habilitado. */
 
} DIG_FIL_REG_TYPE;

#define DIG_FILT_CTRL ((DIG_FIL_REG_TYPE *) &DIG_FIL_BASE_ADDRESS )
#define DIG_FILT_OUT    *(&DIG_FIL_BASE_ADDRESS + 4)    


void dig_filt_reset(uint8_t);
void dig_filt_enable(uint8_t);
uint32_t dig_filt_get_output();

#endif
