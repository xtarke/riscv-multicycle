
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
	_IO32 axe_x_max; //	0x0000, 131, x83
	_IO32 axe_y_max; //	0x0001, 132, x84
	_IO32 axe_z_max; //	0x0002, 133, x85
} ACCEL_TYPE;

#define ACCEL ((ACCEL_TYPE *) &ACCELEROMETER_BASE_ADDRESS)

uint32_t read_axe_x(void);
uint32_t read_axe_y(void);
uint32_t read_axe_z(void);
uint32_t read_axe_x_max(void);
uint32_t read_axe_y_max(void);
uint32_t read_axe_z_max(void);

#endif //ACCELEROMETER_H