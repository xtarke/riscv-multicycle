#include <stdint.h>
#include "../_core/utils.h"
#include "../_core/hardware.h"
#include "lcd.h"

inline _IO32 lcd_pos(_IO32 x, _IO32 y){
    while(x >= DISPLAY_NOKIA_5110_WIDTH){
        x -= DISPLAY_NOKIA_5110_WIDTH;
        y += 1;
    }
    
    while(y >= DISPLAY_NOKIA_5110_HEIGHT)
        y -= DISPLAY_NOKIA_5110_HEIGHT;
        
    return x + y * DISPLAY_NOKIA_5110_WIDTH;
}

void lcd_init(){
    DISPLAY_NOKIA_5110_REGISTER->reg_ctrl = 1;
    DISPLAY_NOKIA_5110_REGISTER->we = 0;
    delay_(700);
}

void lcd_clear(){
    DISPLAY_NOKIA_5110_REGISTER->reg_ctrl = 0;
    DISPLAY_NOKIA_5110_REGISTER->we = 1;
    delay_(100);
    DISPLAY_NOKIA_5110_REGISTER->we = 0;
    delay_(600);
}
void lcd_print(char *string, _IO32 len, _IO32 x, _IO32 y){
    for(int i = 0; i < len; i++){
        DISPLAY_NOKIA_5110_REGISTER->reg_ctrl = 1;
        DISPLAY_NOKIA_5110_REGISTER->pos = lcd_pos(x, y) + (i*DISPLAY_NOKIA_5110_LETTER_SPACING);
        DISPLAY_NOKIA_5110_REGISTER->data = string[i];
        DISPLAY_NOKIA_5110_REGISTER->we = 1;
        delay_(10);
    }
    
    DISPLAY_NOKIA_5110_REGISTER->we = 0;
    delay_(100);
}