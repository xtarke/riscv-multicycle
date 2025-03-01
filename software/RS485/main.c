/* 		Created on: Jan 20, 2019
 *      Author: Alexsander e Jonas
 *      Instituto Federal de Santa Catarina
 *
 *   Modified: Renan Augusto Starke
 *
 * Simple pooling RS485 keep connection example.  */

#include <limits.h>
#include "RS485.h"
#include "../_core/utils.h"
#include "../_core/hardware.h"
#include "../gpio/gpio.h"

uint8_t power_on(uint8_t address)
{
	RS485_write(0x81);
	RS485_write(address); // 0 to 3
	RS485_write(0xFA);
	RS485_write(0);
	RS485_write(0);
	RS485_write(0);
	RS485_write(0);
}

uint8_t keep_connection(uint8_t address)
{
	RS485_write(0x81);
	RS485_write(address); // 0 to 3
	RS485_write(0xFD);
	RS485_write(0);
	RS485_write(0);
	RS485_write(0);
	RS485_write(0);

	// RS485_reception_enable();

	uint8_t data = 0;
	for (int i = 0; i < 8; i++)
		data = RS485_read();

	// RS485_reception_disable();

	if (data > 0x0)
		return 1;
	return 0;
}

uint8_t register_information(uint8_t address)
{
	RS485_write(0x81);
	RS485_write(address); // 0 to 3
	RS485_write(0xFE);
	RS485_write(0);
	RS485_write(0);
	RS485_write(0);
	RS485_write(0);

	RS485_reception_enable();

	uint8_t data = 0;
	for (int i = 0; i < 8; i++)
		data = RS485_read();

	RS485_reception_disable();

	if (data == 0x80)
		return 1;
	return 0;
}

uint8_t check_alarm_input(uint8_t address)
{
	RS485_write(0x81);
	RS485_write(address); // 0 to 3
	RS485_write(0xC8);
	RS485_write(0);
	RS485_write(0);
	RS485_write(0);
	RS485_write(0);

	RS485_reception_enable();

	uint8_t data[8] = {0};
	for (int i = 0; i < 8; i++)
		data[i] = RS485_read();

	RS485_reception_disable();

	if (data[3] != 0xFF)
		return 1;
	if (data[4] != 0xFF)
		return 1;
	if (data[5] != 0xFF)
		return 1;
	if (data[6] != 0xFF)
		return 1;
	return 0;
}

int main()
{
	RS485_reception_enable();
	// RS485_BASE_ADDRESS |= (1 << 23);
	// SEGMENTS = 0xFF765432;
	// volatile uint32_t test = 0;
	uint8_t data = 0;
	// delay_(50);

	RS485_write(0x81);
	RS485_write(0); // 0 to 3
	RS485_write(0xFD);
	RS485_write(0);
	RS485_write(0);
	RS485_write(0);
	RS485_write(0);

	// for (int i = 0; i < 8; i++)
	// 	SEGMENTS = RS485_read();

	while (1)
	{
		SEGMENTS = RS485_read();
		// Testing RS485 - Transmission
		// RS485_write('A');
		// RS485_write('L');
		// RS485_write('E');
		// RS485_write('X');

		// SEGMENTS = RS485_read();

		// test = (volatile uint32_t);

		// volatile uint32_t *ptr = &RS485_BASE_ADDRESS;
		// uint32_t word = *ptr;  // Read the word from memory
		// SEGMENTS = ((volatile uint32_t *)&RS485_BASE_ADDRESS);

		// while (((RS485_BASE_ADDRESS >> 18) & 1) == 0)
		// {
		// };

		// SEGMENTS = RS485_BASE_ADDRESS >> 8 & 0xFF;
		// SEGMENTS = 0xFFFFFFFF;

		// // // RS485_BASE_ADDRESS = 0x12344321;
		// if(data != (RS485_BASE_ADDRESS >> 8 & 0xFF))
		// {
		// 	data = RS485_BASE_ADDRESS >> 8 & 0xFF;
		// 	SEGMENTS = data;
		// }

		// delay_(100);

		// while ((RS485_BASE_ADDRESS >> 18) & 1)
		// {
		// };

		// delay_(100);

		// *(volatile uint32_t*)RS485_REGISTER = 0xFFFFFFFF;

		// SEGMENTS_BASE_ADDRESS = data;  // Display data in IO bus

		// power_on(0);
		// if (keep_connection(0))
		// 	SEGMENTS = 0x01;
		// else
		// 	SEGMENTS = 0xE;

		// keep_connection(0);
	}
	return 0;
}
