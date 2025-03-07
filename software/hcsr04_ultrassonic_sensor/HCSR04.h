#ifndef __HCSR04_H
#define __HCSR04_H
// Adicione esta linha ao HCSR04.h
#define HCSR04_BASE_ADDRESS 0x40000190 // 0x40000000 (periféricos) + 0x0190 (offset do dispositivo)

#include <stdint.h>
#include "../_core/hardware.h"


uint32_t HCSR04_read(void);

typedef struct 
{
  _IO32 measure; 
} HCSR04_REG_TYPE;

#define HCSR04_REGISTER ((HCSR04_REG_TYPE *) &HCSR04_BASE_ADDRESS)

#endif // __HCSR04_H
