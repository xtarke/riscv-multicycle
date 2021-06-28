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

typedef struct {
  _IO8 tx_byte;           /*!< Data to transfer. */
  _IO8 rx_byte;           /*!< Data received. */
  _IO32 tx_start : 1;     /*!< Start Transmission. Bit 16. */
  _IO32 tx_done  : 1;     /*!< Transmission done flag. Bit 17. */
  _IO32 rx_done  : 1;     /*!< Reception done flag. Bit 18 */
  _IO32 baud_rate  : 2;   /*!< Baud rate config. Bits 19 e 20. */
  _IO32 parity     : 2;   /*!< Parity config. Bit 21 and 22. */
  _IO32 rx_enable  : 1;     /*!< Reception transceiver enable. Bit 23. */
  _IO32 rx_irq_enable : 1;  /*!< Reception interrupt enable. Bit 24. */
  _IO32 tx_irq_enable : 1;  /*!< Transmission done interrupt enable. Bit 25 */
} UART_REG_TYPE;

#define UART_REGISTER ((UART_REG_TYPE *) &UART_BASE_ADDRESS)

#endif // __UART_H
