// GABRIEL ROMERO E YURI MARQUES
// SIMPLE SERIAL TRANSMITTER

#ifndef __SERIAL_TRANSMITTER_H
#define __SERIAL_TRANSMITTER_H

#include "../_core/hardware.h"


typedef struct {  
    _IO32 addr;       
    _IO32 data;        
    _IO32 start;   

}serial_transmitter_t;


#define SERIAL_TRANSMITTER ((serial_transmitter_t *) &SIMPLE_SERIAL_TRANSMITTER_ADDRESS)

#endif
