#ifndef __HD44780_H
#define __HD44780_H

  #include <stdint.h>
  #include "../_core/hardware.h"

  typedef struct {
    _IO32 character; // 0 a 7
    _IO32 wr_en; // 8
    _IO32 start; // 9

  } HD44780_REG_TYPE;

  #define HD44780_REGISTER ((HD44780_REG_TYPE *) &HD44780_BASE_ADDRESS)

#endif // __HD44780_H