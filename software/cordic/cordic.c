#include "cordic.h"

void cordic_angle_in(uint32_t angle_in)
{
    CORDIC->angle_in = angle_in;
}

uint32_t get_cordic_sin(void)
{
    return CORDIC->sin;
}

uint32_t get_cordic_cos(void)
{
    return CORDIC->cos;
}