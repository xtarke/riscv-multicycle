
#ifndef __ACCELEROMETER_H
#define __ACCELEROMETER_H

#include <stdint.h>
#include "../_core/utils.h"
#include "../_core/hardware.h"

typedef struct
{
	_IO32 axe_x; //	0x0000, 128, x80
	_IO32 axe_y; //	0x0001, 129, x81
	_IO32 axe_z; //	0x0002, 130, x82
} ACCEL_TYPE;

#define ACCEL ((ACCEL_TYPE *) &ACCELEROMETER_BASE_ADDRESS)

uint32_t read_axe_x(void);
uint32_t read_axe_y(void);
uint32_t read_axe_z(void);

#endif //ACCELEROMETER_H