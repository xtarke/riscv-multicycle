#include <stdint.h>
#include "rtc/rtc.h"
#include "gpio/gpio.h"

static uint32_t two_digits(uint32_t value)
{
    uint32_t unit = value % 10;
    uint32_t ten  = value / 10;

    return (ten << 4) | unit;
}

int main(void)
{
    rtc_write_hour(0);
    rtc_write_min(0);
    rtc_write_sec(0);
    rtc_enable();

    while (1)
    {
        uint32_t sec  = rtc_read_sec();
        uint32_t min  = rtc_read_min();
        uint32_t hour = rtc_read_hour();

        SEGMENTS =
            (two_digits(hour) << 16) |
            (two_digits(min)  << 8)  |
            (two_digits(sec));

    }

    return 0;
}