#ifndef __UART_H
#define __UART_H

#include <stdint.h>

void spi_write(uint8_t data);
uint8_t spi_read(void);

#endif // __UART_H
