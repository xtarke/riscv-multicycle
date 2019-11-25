/*
 * uart.h
 *
 *  Created on: July 1, 2019
 *      Author: Rafael Reis e João Antônio
 *      Instituto Federal de Santa Catarina
 *
 * UART functions
 *  - write
 *  - send
 *	- read
 *	- (...)
 *
 */

#ifndef __TIMER_H
#define __TIMER_H

#include <stdint.h>
#include "hardware.h"

typedef struct {
	uint32_t timer_reset : 1;
	uint32_t timer_mode : 3;
	uint32_t prescaler : 16;
	uint32_t output_A : 3;
	uint32_t output_B : 3;


	uint32_t compare_0A;
	uint32_t compare_0B;
	uint32_t compare_1A;
	uint32_t compare_1B;
	uint32_t compare_2A;
	uint32_t compare_2B;

} TIMER_TYPE;

#define TIMER_0 ((TIMER_TYPE *) &TIMER_ADDRESS)

void timerOneShot1(uint8_t prescaler, uint32_t compare, uint8_t output_sel);
void timerClearOnCompare1(uint8_t prescaler, uint32_t compare, uint8_t output_sel);
void timerUpDown1(uint8_t prescaler, uint32_t compare, uint8_t output_sel);
void timerClearOnTop1(uint8_t prescaler, uint32_t compare, uint8_t output_sel);

void timerOneShot6(uint8_t prescaler, uint32_t compare_0A, uint32_t compare_0B, uint32_t compare_1A, uint32_t compare_1B,
		uint32_t compare_2A, uint32_t compare_2B);
void timerClearOnCompare6(uint8_t prescaler, uint32_t compare_0A, uint32_t compare_0B, uint32_t compare_1A, uint32_t compare_1B,
		uint32_t compare_2A, uint32_t compare_2B);
void timerUpDown6(uint8_t prescaler, uint32_t compare_0A, uint32_t compare_0B, uint32_t compare_1A, uint32_t compare_1B,
	uint32_t compare_2A, uint32_t compare_2B);
void timerClearOnTop6(uint8_t prescaler, uint32_t compare_0A, uint32_t compare_0B, uint32_t compare_1A, uint32_t compare_1B,
		uint32_t compare_2A, uint32_t compare_2B);

#endif // __TIMER_H
