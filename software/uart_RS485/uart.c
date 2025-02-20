/*
 * uart.h
 *
 *  Created on: July 1, 2019
 *      Author: Marcos Vinícius Leal da Silva e
 *      Modified: Daniel Pereira
*       Modified: Renan Augusto Starke
 *
 *      Instituto Federal de Santa Catarina
 *
 * UART functions
 *  - write
 *  - send
 *	- read
 *	- (...)
 *
 */

#include <stdint.h>
#include "uart.h"
#include "../_core/hardware.h"

void UART_write(uint8_t data){
	/* Slow assembly
	while (!UART_REGISTER->tx_done);
	UART_REGISTER->tx_byte = data;
	UART_REGISTER->tx_start = 1; */

	while (!UART_REGISTER->tx_done);

	/* Fast assembly: less instructions */
	UART_REGISTER->tx_byte = 0;
	*((_IO32 *)UART_REGISTER) |= (1 << 16) | data;
}

void UART_setup(baud_rate_t baud, parity_t parity){
	/* Slow assembly
	UART_SETUP_REG->baud_rate = baud;
	UART_SETUP_REG->parity = parity; */

	/* Fast assembly: less instructions */
	*((_IO32 *)UART_REGISTER) &= (~0x0f) << 19;
	*((_IO32 *)UART_REGISTER) |= ((baud & 0x03) << 19) | ((0x03 & parity) << 21);
}

void Buffer_setup(buffer_t buffer_type, uint8_t config_byte){	
	if(buffer_type == 0){
		if(0 < config_byte < 8){
		UART_REGISTER->num_bytes_irq = config_byte;
		UART_REGISTER->byte_final = 0;
		}else{
		UART_REGISTER->num_bytes_irq = 1;
		UART_REGISTER->byte_final = 0;
		}
	}else{
		UART_REGISTER->byte_final = config_byte;
		UART_REGISTER->num_bytes_irq = 0;
	}
	UART_REGISTER->irq_mode = buffer_type;
}

void UART_buffer_read(uint8_t* vetor, uint8_t size){
	// tamanho maximo do buffer é de 8 bytes 
	size = size & 0x07; 
	for(uint8_t i = 0; i < size; i++){
 			vetor[i] = UART_REGISTER->buffer_rx[i];
	}

}

inline void UART_reception_enable(void){
	UART_REGISTER->rx_enable = 1;
}

inline void UART_interrupt_enable(void){
	UART_REGISTER->rx_irq_enable = 1;
}

inline void UART_reception_disable(void){
	UART_REGISTER->rx_enable = 0;
}

uint8_t UART_read(void){
	uint8_t byte;

	/*Wait for a new byte */
	while (!UART_REGISTER->rx_done);

	/* Read byte */
	byte = UART_REGISTER->rx_byte;

	/* Reenable receiver */
	UART_REGISTER->rx_enable = 1;

	return byte;
}

inline uint8_t UART_unblocked_read(void){
	return UART_REGISTER->rx_byte;
}

