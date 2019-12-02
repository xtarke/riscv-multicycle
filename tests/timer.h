/*
 * timer.h
 *
 *  Created on: July 1, 2019
 *      Author: Rafael Reis e João Antônio Cardoso
 *      Instituto Federal de Santa Catarina
 *
 */

#ifndef __TIMER_H
#define __TIMER_H

#include <stdint.h>
#include "hardware.h"


typedef struct {
	uint32_t timer_reset : 1; // 0x20, bit 0
	uint32_t timer_mode : 3;  // 0x20, bit 1,2,3
	uint32_t prescaler : 16;  // 0x20, bit 4,5,...,18,19
	uint32_t output_0A : 1;   // 0x20, bit 20
	uint32_t output_1A : 1;   // 0x20, bit 21
	uint32_t output_2A : 1;   // 0x20, bit 22
	uint32_t output_0B : 1;   // 0x20, bit 23
	uint32_t output_1B : 1;   // 0x20, bit 24
	uint32_t output_2B : 1;   // 0x20, bit 25
    uint32_t unused : 6;      // 0x20, bit 26 to 31

	uint32_t compare_0A;      // 0x24
	uint32_t compare_0B;      // 0x28
	uint32_t compare_1A;      // 0x2C
	uint32_t compare_1B;      // 0x30
	uint32_t compare_2A;      // 0x34
	uint32_t compare_2B;      // 0x38
} TIMER_TYPE;

#define TIMER_0 ((TIMER_TYPE *) &TIMER_ADDRESS)

void timerOneShot1(uint8_t prescaler, uint32_t compare, uint8_t output_sel);
void timerClearOnCompare1(uint8_t prescaler, uint32_t compare, uint8_t output_sel);
void timerUpDown1(uint8_t prescaler, uint32_t compare, uint8_t output_sel);
void timerClearOnTop1(uint8_t prescaler, uint32_t compare, uint8_t output_sel);

void timerOneShot6(
        uint8_t prescaler, 
        uint32_t compare_0A, uint32_t compare_0B, 
        uint32_t compare_1A, uint32_t compare_1B,
		uint32_t compare_2A, uint32_t compare_2B
);
void timerClearOnCompare6(
        uint8_t prescaler, 
        uint32_t compare_0A, uint32_t compare_0B, 
        uint32_t compare_1A, uint32_t compare_1B,
		uint32_t compare_2A, uint32_t compare_2B
);
void timerUpDown6(
        uint8_t prescaler, 
        uint32_t compare_0A, uint32_t compare_0B, 
        uint32_t compare_1A, uint32_t compare_1B,
	    uint32_t compare_2A, uint32_t compare_2B
);
void timerClearOnTop6(
        uint8_t prescaler, 
        uint32_t compare_0A, uint32_t compare_0B, 
        uint32_t compare_1A, uint32_t compare_1B,
		uint32_t compare_2A, uint32_t compare_2B
);

#endif // __TIMER_H
