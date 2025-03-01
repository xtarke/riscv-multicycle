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

void RS485_write(volatile uint8_t data)
{
	// // Slow assembly
	// while (!RS485_REGISTER->tx_done)
	// 	;
	// RS485_REGISTER->tx_byte = data;
	// RS485_REGISTER->tx_start = 1;

	// while (!RS485_REGISTER->tx_done)
	// 	;
	while (!((RS485_BASE_ADDRESS >> 17) & 1))
	{
	};

	/* Fast assembly: less instructions */
	// RS485_REGISTER->tx_byte = 0;
	// RS485_BASE_ADDRESS = (RS485_BASE_ADDRESS & 0xFFFFFF00);
	// RS485_BASE_ADDRESS |= (1 << 16) | data;

	RS485_BASE_ADDRESS = (RS485_BASE_ADDRESS & 0xFFFFFF00) | (1 << 16) | data;

}

// void RS485_setup()
// {
// 	/* Slow assembly
// 	RS485_SETUP_REG->baud_rate = baud;
// 	RS485_SETUP_REG->parity = parity; */

// 	baud_rate_t baud = _9600;
// 	parity_t parity = NO_PARITY;

// 	/* Fast assembly: less instructions */
// 	*((_IO32 *)RS485_REGISTER) &= (~0x0f) << 19;
// 	*((_IO32 *)RS485_REGISTER) |= ((baud & 0x03) << 19) | ((0x03 & parity) << 21);
// }

inline void RS485_reception_enable(void)
{
	// RS485_REGISTER->rx_enable = 1; //DONT WORK
	RS485_BASE_ADDRESS |= (1 << 23);
}

inline void RS485_reception_disable(void)
{
	// RS485_REGISTER->rx_enable = 0; //DONT WORK
	RS485_BASE_ADDRESS &= ~(1 << 23);
}

uint8_t RS485_read(void)
{
	volatile uint8_t byte;

	/*Wait for a new byte */
	// while (!RS485_REGISTER->rx_done)
	// {
	// };

	while (!(RS485_BASE_ADDRESS >> 18) & 1)
	{
	};

	/* Read byte */
	// byte = RS485_REGISTER->rx_byte;

	// byte = *(volatile uint32_t *)RS485_REGISTER >> 8;

	// byte = RS485_BASE_ADDRESS >> 8 & 0xFF;
	// RS485_BASE_ADDRESS |= (1 << 23) ;

	/* Reenable receiver */
	// RS485_REGISTER->rx_enable = 1;

	// return byte;

	return RS485_BASE_ADDRESS >> 8 & 0xFF;
}

inline uint8_t RS485_unblocked_read(void)
{
	return RS485_REGISTER->rx_byte;
}
