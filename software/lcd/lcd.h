#ifndef __LCD_H
#define __LCD_H

#include "../_core/hardware.h"

typedef struct{
    _IO32 reg_ctrl; /*!< State machine control register. */
    _IO32 pos;         /*!< Data index. */
    _IO32 data;         /*!< Data to display.*/
    _IO32 we;         /*!< Write enable */
} DISPLAY_NOKIA_5110_REG_TYPE;

#define DISPLAY_NOKIA_5110_REGISTER ((DISPLAY_NOKIA_5110_REG_TYPE *) &DISPLAY_NOKIA_5110_BASE_ADDRESS)

#endif 