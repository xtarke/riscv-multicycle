#include <limits.h>
#include "crc.h"
#include "../_core/utils.h"
#include "../_core/hardware.h"
#include "../gpio/gpio.h"

int main() {
	uint8_t data[] = {0xA1, 0x02, 0xF3, 0x34, 0x65, 0x06, 0xB7, 0xC8};
	
	CRC_REGISTER->initial = 0xFF;

	for (int i = 0 ; i < 8; i++) 
		CRC_REGISTER->crc_value = data[i];

	SEGMENTS_BASE_ADDRESS = CRC_REGISTER->crc_value; 
	
	while(1);

	return 0; 
}

