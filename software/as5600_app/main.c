/*
 * main.c - Reading AS5600 sensor and displaying the angle on 7-segment display.
 */

#include <stdint.h>
#include "../_core/hardware.h"
#include "../gpio/gpio.h"

// peripheral address AS5600 (Slot 22)
#define AS5600_T_HIGH (*(_IO32 *)(PERIPH_BASE + 22 * 16 * 4))
#define AS5600_T_PERIOD (*(_IO32 *)(PERIPH_BASE + 22 * 16 * 4 + 4))

int main()
{
    uint32_t t_high;
    uint32_t t_period;
    uint32_t angle;
    uint32_t bcd_val;

    while (1)
    {
        // get sensor output
        t_high = AS5600_T_HIGH;
        t_period = AS5600_T_PERIOD;

        // angle 
        angle = 0;
        if (t_period > 0)
        {
            // pwm to t_high
            uint32_t internal_high = (t_high * 4351) / t_period;

            // offset t_high
            if (internal_high > 128)
            {
                uint32_t data_val = internal_high - 128;

                if (data_val > 4095)
                    data_val = 4095;

                // data to angle
                angle = (data_val * 360) / 4095;
            }
        }

        // 000°
        uint32_t u = angle % 10;
        uint32_t d = (angle / 10) % 10;
        uint32_t c = (angle / 100) % 10;

        bcd_val = 0xA; // °
        bcd_val |= (u << 4);

        if (angle >= 10)
        {
            bcd_val |= (d << 8);
        }
        else
        {
            bcd_val |= (0xF << 8);
        }

        if (angle >= 100)
        {
            bcd_val |= (c << 12);
        }
        else
        {
            bcd_val |= (0xF << 12);
        }

        bcd_val |= 0xFF0000; // unused

        SEGMENTS_BASE_ADDRESS = bcd_val;

        // Delay
        for (volatile uint32_t d = 0; d < 25000; d++)
            ;
    }

    return 0;
}
