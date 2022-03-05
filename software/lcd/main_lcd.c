/** @file main_lcd.h
 *  @brief Nokia 5110 LCD display example file.
 * 
 *  Provides an example for its usage.
*/

#include <stdint.h>
#include "lcd.h"
#include "../_core/utils.h"
#include "../_core/hardware.h"

int main(){
    char phrase[] = "Hello World!";
    char every_character[] = " !\"#$%&'()*+-,-./0123456789:;<=>?@"
                             "ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`ab"
                             "cdefghijklmnopqrstuvwxyz{|}~";
    _IO32 len = sizeof(phrase)-1;
    _IO32 len_all = sizeof(every_character)-1;
    lcd_init();

    while(1){
        lcd_print(phrase, len, 0, 0);
        
        /* Comment delay for testbench and uncomment for synthesis. */
        //delay_(10000);
        
        lcd_clear();
        lcd_print(every_character, len_all-12, 0, 0);

        /* Comment delay for testbench and uncomment for synthesis. */
        //delay_(10000);
        
        lcd_clear();
        lcd_print(&every_character[len_all-12], 12, 0, 0);
        
        /* Comment delay for testbench and uncomment for synthesis. */
        //delay_(10000);
        
        lcd_clear();
    }

    return 0;
}