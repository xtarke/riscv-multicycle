#include "cordic.h"

void cordic_angle_in(uint32_t angle_in)
{
    ///CORDIC->angle_in = angle_in & 0xFFFF;
    //CORDIC->angle_in |= (1 << 16);


    *(&CORDIC_BASE_ADDRESS + 1) = angle_in;
}


uint16_t get_cordic_sin(void)
{
    volatile uint32_t *cordic = (volatile uint32_t *) CORDIC_BASE_ADDRESS;
    uint32_t sin_val = cordic[0];  // Lê do endereço 0x540
    cordic[1] &= ~(1 << 16);
    // CORDIC->angle_in &= ~(1 << 16);
    // return CORDIC->sin;
    // *(&CORDIC_BASE_ADDRESS + 1) &= ~(1 << 16);
    return sin_val;
}

uint16_t get_cordic_cos(void)
{
    CORDIC->angle_in &= ~(1 << 16);
    return CORDIC->cos;
}

uint32_t get_cordic_full(void)
{
    return CORDIC_BASE_ADDRESS;
}