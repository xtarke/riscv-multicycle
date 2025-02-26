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
#include "RS485.h"
#include "../_core/utils.h"
#include "../_core/hardware.h"

void RS485_write(uint8_t data){
	/* Slow assembly
	while (!RS485_REGISTER->tx_done);
	RS485_REGISTER->tx_byte = data;
	RS485_REGISTER->tx_start = 1; */

	while (!RS485_REGISTER->tx_done);

	/* Fast assembly: less instructions */
	RS485_REGISTER->tx_byte = 0;
	*((_IO32 *)RS485_REGISTER) |= (1 << 16) | data;
	// delay_(10);
	// while (RS485_REGISTER->tx_done);
}

void RS485_setup(baud_rate_t baud, parity_t parity){
	/* Slow assembly
	RS485_SETUP_REG->baud_rate = baud;
	RS485_SETUP_REG->parity = parity; */

	/* Fast assembly: less instructions */
	*((_IO32 *)RS485_REGISTER) &= (~0x0f) << 19;
	*((_IO32 *)RS485_REGISTER) |= ((baud & 0x03) << 19) | ((0x03 & parity) << 21);
}

void Buffer_setup(buffer_t buffer_type, uint8_t config_byte){	
	if(buffer_type == 0){
		if(0 < config_byte < 8){
		RS485_REGISTER->num_bytes_irq = config_byte;
		RS485_REGISTER->byte_final = 0;
		}else{
		RS485_REGISTER->num_bytes_irq = 1;
		RS485_REGISTER->byte_final = 0;
		}
	}else{
		RS485_REGISTER->byte_final = config_byte;
		RS485_REGISTER->num_bytes_irq = 0;
	}
	RS485_REGISTER->irq_mode = buffer_type;
}

void RS485_buffer_read(uint8_t* vetor, uint8_t size){
	// tamanho maximo do buffer é de 8 bytes 
	size = size & 0x07; 
	for(uint8_t i = 0; i < size; i++){
 			vetor[i] = RS485_REGISTER->buffer_rx[i];
	}

}

inline void RS485_reception_enable(void){
	RS485_REGISTER->rx_enable = 1;
}

inline void RS485_interrupt_enable(void){
	RS485_REGISTER->rx_irq_enable = 1;
}

inline void RS485_reception_disable(void){
	RS485_REGISTER->rx_enable = 0;
}

uint8_t RS485_read(void){
	uint8_t byte;

	/*Wait for a new byte */
	while (!RS485_REGISTER->rx_done);

	/* Read byte */
	byte = RS485_REGISTER->rx_byte;

	/* Reenable receiver */
	RS485_REGISTER->rx_enable = 1;

	return byte;
}

inline uint8_t RS485_unblocked_read(void){
	return RS485_REGISTER->rx_byte;
}

