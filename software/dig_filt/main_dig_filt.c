/* 
	Example code for digital filter peripheral
   	Tarcis Aurélio Becher  14/10/2020
*/

#include "dig_filt.h"

int main(){

	uint32_t data_in[32] = {0x00, 0x01, 0x02, 0x03, 
							0x04, 0x05, 0x06, 0x07, 
							0x08, 0x09,	0x0A, 0x0B, 
							0x0C, 0x0D, 0x0E, 0x0F,
							0x10, 0x11, 0x12, 0x13, 
							0x14, 0x15, 0x16, 0x17, 
							0x18, 0x19,	0x1A, 0x1B, 
							0x1C, 0x1D, 0x1E, 0x1F};
	uint8_t i = 0;

	dig_filt_reset();						// reset function

	while (1){

		dig_filt_add_data(0xA);				// add new data function
		OUTBUS = dig_filt_get_output();		// get output function
		delay_(10000);						// for human interaction

		i++;
		if (i == 40)
		{
			i = 0;
			dig_filt_reset();				// reset function
		}
	}

	return 0;
}
