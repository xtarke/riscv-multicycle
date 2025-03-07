#include "accelerometer.h"

uint32_t read_axe_x(void)
{
	return ACCEL -> axe_x;
}

uint32_t read_axe_y(void)
{
	return ACCEL -> axe_y;
}

uint32_t read_axe_z(void)
{
	return ACCEL -> axe_z;
}

uint32_t read_axe_x_max(void)
{
	return ACCEL -> axe_x_max;
}

uint32_t read_axe_y_max(void)
{
	return ACCEL -> axe_y_max;
}

uint32_t read_axe_z_max(void)
{
	return ACCEL -> axe_z_max;
}