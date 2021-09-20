/*
 * Simple FLASH example.
 */

#define SUCCESS 1
#define ERROR 0

#include "../_core/utils.h"
#include "../_core/hardware.h"
#include "../gpio/gpio.h"


void test_modelsim_simulation();
int test_quartus();

int main() {

	// test_modelsim_simulation();
	// return 0;

	while (1) {
		int retval = test_quartus();

		if (retval == ERROR)
			while (1){};
	}


	return 0;
}

void test_modelsim_simulation() {

   	volatile uint32_t *flash = &FLASH;

	// consecutive write/read operations don't require delay in between.

	// flash[0] = 0xAABBCCDD;
	flash[0] = 0xAA000000;
	flash[1] = 0xAABB0000;
	flash[2] = 0xAABBCC00;
	flash[3] = 0xAABBCCDD;

	uint32_t x,y,z,w;
	x = flash[0];
	y = flash[1];
	z = flash[2];
	w = flash[3];
}

int test_quartus() {

	volatile uint32_t *flash = &FLASH;
	
	for (uint32_t i = 0; i < 64; i++) {
		flash[i] = i;
	}

	for (uint32_t i = 0; i < 64; i++) {
		if (flash[i] == i) {
			OUTBUS = i;
			delay_(10000);
		} else {
			OUTBUS = 0xFF;
			return ERROR;
		}
	}

	return SUCCESS;
}