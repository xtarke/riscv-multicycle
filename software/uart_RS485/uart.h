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

typedef enum irq_buffer_config {
  IRQ_LENGTH,
  IRQ_BYTE_FINAL
} buffer_t;

void UART_write(uint8_t data);
void UART_setup(baud_rate_t baud, parity_t parity);
void Buffer_setup(buffer_t buffer_type, uint8_t config_byte);
void UART_interrupt_enable(void);
void UART_reception_enable(void);
void UART_reception_disable(void);
uint8_t UART_read(void);
uint8_t UART_unblocked_read(void);
void UART_buffer_read(uint8_t* vetor, uint8_t size);

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
  _IO32 _padding : 5;       /*Ajuste de variavel para alinhar a memoria  Bit 26 ao 30*/
  _IO32 irq_mode : 1;       /*Configuração para o modo de recepção Bit 31*/
  _IO8 buffer_rx[8];       /*Definição do Buffer para recepção. Duas words 1 e 2*/
  _IO8 num_bytes_irq;      /*Numero de bytes para gerar uma interrupção. Bit 0 a 7 word 3*/
  _IO8 byte_final;         /*É o byte que determina o final do pacote serial. Bit 8 a 15 word 3*/
} UART_REG_TYPE;

#define UART_REGISTER ((UART_REG_TYPE *) &UART_BASE_ADDRESS)

#endif // __UART_H
