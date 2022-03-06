
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
  delay_(500);
  HD44780_REGISTER -> start = 1;
  delay_(500);
  HD44780_REGISTER -> start = 0;
  delay_(500);
  HD44780_REGISTER -> clear = 1;
  delay_(500);
  HD44780_REGISTER -> clear = 0;
  while(1) {
    HD44780_REGISTER -> wr_en = 1;
    HD44780_REGISTER -> character = (int) 'C';
    delay_(500);
  }
  return 0;
}

