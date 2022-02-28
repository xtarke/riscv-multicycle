
#include <limits.h>
 
#include "../_core/utils.h"
#include "../_core/hardware.h"

#include "hd44780.h"

int main(){
  HD44780_REGISTER -> start = 1;
  while(1) {    
    HD44780_REGISTER -> character = 'A'; //0b01000001;
    HD44780_REGISTER -> wr_en = 1;
  }
  return 0;
}

