#ifndef __LCD_H
#define __LCD_H

#include "../_core/hardware.h"

void lcd_init();
void lcd_clear();
void lcd_print(char *string, _IO32 len, _IO32 x, _IO32 y);

typedef struct{
    _IO32 reg_ctrl; /*!< State machine control register. */
    _IO32 pos;      /*!< Data index. */
    _IO32 data;     /*!< Data to display.*/
    _IO32 we;       /*!< Write enable */
} DISPLAY_NOKIA_5110_REG_TYPE;

#define DISPLAY_NOKIA_5110_REGISTER ((DISPLAY_NOKIA_5110_REG_TYPE *) &DISPLAY_NOKIA_5110_BASE_ADDRESS)
#define DISPLAY_NOKIA_5110_HEIGHT 6
#define DISPLAY_NOKIA_5110_WIDTH 84
#define DISPLAY_NOKIA_5110_LETTER_SPACING 6

#endif 