#include <stdint.h>
#include "_core/utils.h"
#include "_core/hardware.h"
#include "lcd/lcd.h"

int main(){
    char phrase[] = "Hello World!";
    char every_character[] = " !\"#$%&'()*+-,-./0123456789:;<=>?@"
                             "ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`ab"
                             "cdefghijklmnopqrstuvwxyz{|}~";
    _IO32 len = sizeof(phrase)-1;
    _IO32 len_all = sizeof(every_character)-1;
    _IO32 we = 1;
    _IO32 i = 0;

    while(1){
        for(i = 0; i < len; i++){
            DISPLAY_NOKIA_5110_REGISTER->reg_ctrl = 1;
            DISPLAY_NOKIA_5110_REGISTER->pos = i*LETTER_SPACING;
            DISPLAY_NOKIA_5110_REGISTER->data = phrase[i];
            DISPLAY_NOKIA_5110_REGISTER->we = we;
            //we = ~we;
            delay_(1000);
        }
        
        DISPLAY_NOKIA_5110_REGISTER->we = 0;
        delay_(10000);
        DISPLAY_NOKIA_5110_REGISTER->reg_ctrl = 0;
        DISPLAY_NOKIA_5110_REGISTER->we = 1;
        delay_(100);        
        
        for(i = 0; i < len_all-12; i++){
            DISPLAY_NOKIA_5110_REGISTER->reg_ctrl = 1;
            DISPLAY_NOKIA_5110_REGISTER->pos = i*LETTER_SPACING;
            DISPLAY_NOKIA_5110_REGISTER->data = every_character[i];
            DISPLAY_NOKIA_5110_REGISTER->we = we;
            //we = ~we;
            delay_(1000);
        }
        
        DISPLAY_NOKIA_5110_REGISTER->we = 0;
        delay_(10000);
        DISPLAY_NOKIA_5110_REGISTER->reg_ctrl = 0;
        DISPLAY_NOKIA_5110_REGISTER->we = 1;
        delay_(100);
        
        for(i = 0; i < 12; i++){
            DISPLAY_NOKIA_5110_REGISTER->reg_ctrl = 1;
            DISPLAY_NOKIA_5110_REGISTER->pos = i*LETTER_SPACING;
            DISPLAY_NOKIA_5110_REGISTER->data = every_character[i+len_all-12];
            DISPLAY_NOKIA_5110_REGISTER->we = we;
            //we = ~we;
            delay_(1000);
        }
        
        DISPLAY_NOKIA_5110_REGISTER->we = 0;
        delay_(10000);
        DISPLAY_NOKIA_5110_REGISTER->reg_ctrl = 0;
        DISPLAY_NOKIA_5110_REGISTER->we = 1;
        delay_(10000);
    }

    return 0;
}
