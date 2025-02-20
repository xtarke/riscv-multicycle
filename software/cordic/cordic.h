#ifndef __CORDIC_H
#define __CORDIC_H

 #include <stdint.h>
#include "../_core/hardware.h"
 
typedef struct {
   _IO16 sin;
   _IO16 cos;
   _IO32 angle_in;

} CORDIC_TYPE;
 
#define CORDIC ((CORDIC_TYPE *) &CORDIC_BASE_ADDRESS)

void cordic_reset(void);
void cordic_angle_in(uint32_t angle_in);

uint32_t get_cordic_sin(void);
uint32_t get_cordic_cos(void);

#endif // __CORDIC_H
 