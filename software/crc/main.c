#include <limits.h>
#include "crc.h"
#include "../_core/utils.h"
#include "../_core/hardware.h"

uint16_t CRC16_2(uint8_t *buf, int len)
{
	uint16_t crc = 0xFFFF;
	int i;

	for (i = 0; i < len; i++)
	{
		crc ^= (uint16_t)buf[i];          // XOR byte into least sig. byte of crc


		for (int i = 8; i != 0; i--) {    // Loop over each bit
			if ((crc & 0x0001) != 0) {      // If the LSB is set
				crc >>= 1;                    // Shift right and XOR 0xA001
				crc ^= 0xA001;
			}
			else                            // Else LSB is not set
				crc >>= 1;                    // Just shift right
		}
	}

	// Note, this number has low and high bytes swapped, so use it accordingly (or swap bytes)
	return crc;
}


int main() {
	
	uint8_t data[] = {0xA1, 0x02, 0xF3, 0x34, 0x65, 0x06, 0xB7, 0xC8};

	//uint16_t crc_esperado = CRC16_2(data, 8);

	CRC_REGISTER->initial = 0xFFFF;
	for (int i = 0 ; i < 8; i++) 
		CRC_REGISTER->crc_value = data[i];
	uint16_t crc_obtido = CRC_REGISTER->crc_value;

	return 0; 
}

