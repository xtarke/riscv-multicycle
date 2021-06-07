/*
 * uart.h
 *
 *  Created on: July 1, 2019
 *      Author: Marcos Vinícius Leal da Silva e Daniel Pereira
 *      Modified: Renan Augusto Starke
 *
 *      Instituto Federal de Santa Catarina
 *
 * UART functions
 *  - write
 *  - setup
 *	- read
 *	- (...)
 *
 */

#ifndef __UART_H
#define __UART_H

#include <stdint.h>
#include "../_core/hardware.h"

void UART_write(uint8_t data);
void UART_setup(int baud, int parity);
void UART_interrupt_enable(void);
uint8_t UART_read(void);

#define UART_TX              *(&UART_BASE_ADDRESS)
#define UART_RX              *(&UART_BASE_ADDRESS + 1)
#define UART_SETUP           *(&UART_BASE_ADDRESS + 2)

typedef struct {
    _IO8 byte;          /*!< Data to transfer. */
    _IO32 tx_start : 1;  /*!< Start Transmission */
    _IO32 tx_done  : 1;  /*!< Transmission done flag. */
    _IO32 __unused : 22;
} UART_TX_TYPE;


#define UART_TX_REG ((UART_TX_TYPE *) &UART_TX)

#endif // __UART_H
