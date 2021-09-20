/*
 * Simple FLASH example.
 */

#define SUCCESS 1
#define ERROR 0

// set a low number (e.g. 8, 16, 32) for simulation
// in quartus, don't set it above 128.
#define COUNT_UNTIL 8

// ADD_DELAY is useful only in quartus in order to visualize output in LEDs
#define ADD_DELAY

#include "../_core/utils.h"
#include "../_core/hardware.h"
#include "../gpio/gpio.h"

int test();

int main() {

	// test_modelsim_simulation();
	// return 0;

	while (1) {
		int retval = test();

		if (retval == ERROR)
			while (1){};
	}


	return 0;
}

int test() {

	volatile uint32_t *flash = &FLASH;
	
	for (uint32_t i = 0; i < COUNT_UNTIL; i++) {
		flash[i] = i;
	}

	for (uint32_t i = 0; i < COUNT_UNTIL; i++) {
		if (flash[i] == i) {
			OUTBUS = i;
			#ifdef ADD_DELAY
			delay_(10000);
			#endif
		} else {
			OUTBUS = 0xFF;
			return ERROR;
		}
	}

	return SUCCESS;
}