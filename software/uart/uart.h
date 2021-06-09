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

typedef enum baud_rates_config {
  _38400,
  _19200,
  _9600,
  _4800
} baud_rate_t;

typedef enum parity_config {
  NO_PARITY,
  ODD_PARITY,
  EVEN_PARITY
} parity_t;

void UART_write(uint8_t data);
void UART_setup(baud_rate_t baud, parity_t parity);

void UART_interrupt_enable(void);
void UART_reception_enable(void);

uint8_t UART_read(void);

#define UART_TX              *(&UART_BASE_ADDRESS)
#define UART_RX              *(&UART_BASE_ADDRESS + 1)
#define UART_SETUP           *(&UART_BASE_ADDRESS + 2)

typedef struct {
    _IO8 byte;          /*!< Data to transfer. */
    _IO32 tx_start : 1;  /*!< Start Transmission */
    _IO32 tx_done  : 1;  /*!< Transmission done flag. */
} UART_TX_TYPE;

typedef struct {
    _IO8 byte;          /*!< Data to transfer. */
    _IO32 rx_done  : 1;  /*!< Reception done flag. */
} UART_RX_TYPE;

typedef struct {
    _IO32 baud_rate  : 2;      /*!< Baud rate config. */
    _IO32 parity     : 2;      /*!< Parity config. */
    _IO32 rx_enable  : 1;      /*!< Reception transceiver enable. */
    _IO32 rx_irq_enable : 1;  /*!< Reception interrupt enable */
} UART_SETUP_TYPE;

#define UART_TX_REG ((UART_TX_TYPE *) &UART_TX)
#define UART_RX_REG ((UART_RX_TYPE *) &UART_RX)
#define UART_SETUP_REG ((UART_SETUP_TYPE *) &UART_SETUP)

#endif // __UART_H
