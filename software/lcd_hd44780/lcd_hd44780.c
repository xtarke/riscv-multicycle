
#include <limits.h>
#include "../_core/utils.h"
#include "../_core/hardware.h"

#include "lcd_hd44780.h"

int main(){
  unsigned int i;
  HD44780_REGISTER -> start = 0;
  HD44780_REGISTER -> wr_en = 0;
  HD44780_REGISTER -> clear = 0;
  HD44780_REGISTER -> goL1 = 0;
  HD44780_REGISTER -> goL2 = 0;
  HD44780_REGISTER -> wait_next = 0;
  
  delay_(5000);
  HD44780_REGISTER -> start = 1;
  delay_(5000);
  HD44780_REGISTER -> start = 0;
  delay_(5000);
  HD44780_REGISTER -> clear = 1;
  delay_(5000);
  HD44780_REGISTER -> clear = 0;

  char string_lcd[] = "Hello World ";

  while(1) {
    for(i=0; i<12; i++){      
      HD44780_REGISTER -> character = (int) string_lcd[i];  
      HD44780_REGISTER -> wait_next = 0;   
      HD44780_REGISTER -> wr_en = 1;
      delay_(50);
      HD44780_REGISTER -> wait_next = 1;
      delay_(150);
    }
    HD44780_REGISTER -> wr_en = 0;
    while(1){}
  }
  return 0;
}


