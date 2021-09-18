/*
 * Simple FLASH example.
 */

#include "../_core/utils.h"
#include "../_core/hardware.h"
#include "../gpio/gpio.h"


void test_write_read();

int main() {

	test_write_read();

	return 0;
}

void test_write_read() {

   	volatile uint32_t *flash = &FLASH;

	// consecutive write operations don't require delay in between.

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