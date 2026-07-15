#include "rtc.h"

uint32_t rtc_read_sec(void)
{
    return RTC_SEC;
}

uint32_t rtc_read_min(void)
{
    return RTC_MIN;
}

uint32_t rtc_read_hour(void)
{
    return RTC_HOUR;
}

void rtc_write_sec(uint32_t value)
{
    RTC_SEC = value;
}

void rtc_write_min(uint32_t value)
{
    RTC_MIN = value;
}

void rtc_write_hour(uint32_t value)
{
    RTC_HOUR = value;
}

void rtc_enable(void)
{
    RTC_CTRL = 1;
}

void rtc_disable(void)
{
    RTC_CTRL = 0;
}