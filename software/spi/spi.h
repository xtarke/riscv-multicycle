#ifndef __UART_H
#define __UART_H

#include <stdint.h>
#include "../_core/hardware.h"

void spi_write(uint8_t data);
uint8_t spi_read(void);

#define SPI_TX    *(&SPI_BASE_ADDRESS)
#define SPI_RX    *(&SPI_BASE_ADDRESS + 1)


#endif // __UART_H
