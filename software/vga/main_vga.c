/*
 * main_vga.c
 *
 *  Created on: Jan 20, 2019
 *      Author: Renan Augusto Starke
 *      Instituto Federal de Santa Catarina
 *
 * VGA test: draws a small colored square using the 8K word VGA RAM.
 * The VGA controller wraps addresses with 13 bits, so only addresses
 * 0..8191 are visible. At 640 pixels per row, 8192 words cover ~12
 * rows. We draw colored stripes in the top-left area.
 * -----------------------------------------
 */

#include "../_core/utils.h"
#include "../_core/hardware.h"

/* VGA RAM is mapped at SDRAM address space (dcsel = "11") */
/* 8192 words of 16-bit color, format: 0x0BGR (4 bits each) */
#define VGA_RAM_SIZE 4096
#define SCREEN_WIDTH 640

/* Colors in 0BGR format */
#define RED   0x000F
#define GREEN 0x00F0
#define BLUE  0x0F00
#define WHITE 0x0FFF
#define BLACK 0x0000

int main(){
	volatile uint32_t *vga = &SDRAM;
	int x, y;

	/* Clear VGA RAM to black */
	for (x = 0; x < VGA_RAM_SIZE; x++) {
		vga[x] = BLACK;
	}

	/* Draw a 64x6 red rectangle starting at pixel (0,0).
	 * With 640px width, row y starts at address y*640.
	 * We can only address up to 4095 (daddress limit),
	 * so rows 0..5 are fully addressable (6 * 640 = 3840). */
	for (y = 0; y < 6; y++) {
		for (x = 0; x < 64; x++) {
			int addr = y * SCREEN_WIDTH + x;
			if (addr < VGA_RAM_SIZE) {
				vga[addr] = RED;
			}
		}
	}

	/* Draw a green stripe next to it */
	for (y = 0; y < 6; y++) {
		for (x = 64; x < 128; x++) {
			int addr = y * SCREEN_WIDTH + x;
			if (addr < VGA_RAM_SIZE) {
				vga[addr] = GREEN;
			}
		}
	}

	/* Draw a blue stripe next to that */
	for (y = 0; y < 6; y++) {
		for (x = 128; x < 192; x++) {
			int addr = y * SCREEN_WIDTH + x;
			if (addr < VGA_RAM_SIZE) {
				vga[addr] = BLUE;
			}
		}
	}

	/* Infinite loop */
	while(1);

	return 0;
}
