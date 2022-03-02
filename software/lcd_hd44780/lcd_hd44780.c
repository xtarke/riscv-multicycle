
#include <limits.h>
 
#include "../_core/utils.h"
#include "../_core/hardware.h"

#include "lcd_hd44780.h"

int main(){
  unsigned int i;

  while(1) {    
    HD44780_REGISTER -> start = 1;
    //HD44780_REGISTER -> wr_en = 0;
    //HD44780_REGISTER -> character = '01000001'; //'B'; //0b01000001;
    //HD44780_REGISTER -> wr_en = 1;

  }
  return 0;
}


