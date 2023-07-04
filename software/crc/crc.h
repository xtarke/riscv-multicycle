#ifndef __GPIO_H
#define __GPIO_H

#include "../_core/hardware.h"

typedef struct 
{
	_IO32 crc_value;
	_IO32 initial;
} CRC_REG_Type;


#define CRC_REGISTER ((CRC_REG_Type *) &CRC_BASE_ADDRESS)

#endif
