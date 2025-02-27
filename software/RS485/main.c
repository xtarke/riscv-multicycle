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

	RS485_reception_enable();

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
	// RS485_setup();
	// RS485_reception_enable();
	SEGMENTS = 1;

	uint8_t data = 0;

	while (1)
	{
		// Testing RS485 - Transmission
		// RS485_write('A');
		// RS485_write('L');
		// RS485_write('E');
		// RS485_write('X');

		// RS485_read();
		// SEGMENTS = RS485_REGISTER->rx_byte;

		// SEGMENTS_BASE_ADDRESS = data;  // Display data in IO bus

		// power_on(0);
			if (keep_connection(0))
				SEGMENTS = 2;
			else
				SEGMENTS = 0xE;
	}
	return 0;
}
