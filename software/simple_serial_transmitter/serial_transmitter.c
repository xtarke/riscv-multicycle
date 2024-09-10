// GABRIEL ROMERO E YURI MARQUES
// SIMPLE SERIAL TRANSMITTER

// Online C compiler to run C program online
#include "../_core/utils.h"
#include "../_core/hardware.h"
#include "../gpio/gpio.h"

#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>

#include "serial_transmitter.h"

void main(){
 
   uint32_t data = 0;
    
   while(1){

      SERIAL_TRANSMITTER->addr = 0xff;
      SERIAL_TRANSMITTER->data = data;
      SERIAL_TRANSMITTER->start = 1;
      HEX0 = 1;
      OUTBUS = data;

      delay_(100000);

      SERIAL_TRANSMITTER->start = 0;
      HEX0 = 0;
      data++;

   };
}
