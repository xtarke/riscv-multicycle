#ifndef RTC_H
#define RTC_H

#include <stdint.h>
#include "../_core/hardware.h"

//Registradores do RTC
//registrador de 32bits, +1 equivale a 4bytes, +2 equivale a 8bytes
#define RTC_SEC     *(&RTC_BASE_ADDRESS + 0)
#define RTC_MIN     *(&RTC_BASE_ADDRESS + 1)
#define RTC_HOUR    *(&RTC_BASE_ADDRESS + 2)
#define RTC_DAY     *(&RTC_BASE_ADDRESS + 3)
#define RTC_MONTH   *(&RTC_BASE_ADDRESS + 4)
#define RTC_YEAR    *(&RTC_BASE_ADDRESS + 5)
#define RTC_CTRL    *(&RTC_BASE_ADDRESS + 6)

uint32_t rtc_read_sec(void);
uint32_t rtc_read_min(void);
uint32_t rtc_read_hour(void);

void rtc_write_sec(uint32_t value);
void rtc_write_min(uint32_t value);
void rtc_write_hour(uint32_t value);

void rtc_enable(void);
void rtc_disable(void);

#endif

