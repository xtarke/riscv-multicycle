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


/*typedef struct {
    union{
        _IO32 MASK;
        struct{
            _IO32 timer_reset : 1; // 0x20, bit 0
            _IO32 timer_mode : 3;  // 0x20, bit 1,2,3
            _IO32 prescaler : 16;  // 0x20, bit 4,5,...,18,19
        }BIT;
    }config;

	_IO32 output_0A : 1;   // 0x20, bit 20
	_IO32 output_1A : 1;   // 0x20, bit 21
	_IO32 output_2A : 1;   // 0x20, bit 22
	_IO32 output_0B : 1;   // 0x20, bit 23
	_IO32 output_1B : 1;   // 0x20, bit 24
	_IO32 output_2B : 1;   // 0x20, bit 25
    _IO32           : 6;   // 0x20, bit 26 to 31

	_IO32 compare_0A;      // 0x24
	_IO32 compare_0B;      // 0x28
	_IO32 compare_1A;      // 0x2C
	_IO32 compare_1B;      // 0x30
	_IO32 compare_2A;      // 0x34
	_IO32 compare_2B;      // 0x38
} TIMER_TYPE;
*/
typedef struct {
    _IO32 timer_reset;      // 0x20
    _IO32 timer_mode;       // 0x24
    _IO32 prescaler;        // 0x28

    _IO32 top_counter;      // 0x2C
	_IO32 compare_0A;       // 0x30
	_IO32 compare_0B;       // 0x34
	_IO32 compare_1A;       // 0x38
	_IO32 compare_1B;       // 0x3C
	_IO32 compare_2A;       // 0x40
	_IO32 compare_2B;       // 0x44

	_IO32 output_0A : 1;    // 0x48, bit 0
	_IO32 output_1A : 1;    // 0x48, bit 1
	_IO32 output_2A : 1;    // 0x48, bit 2
	_IO32 output_0B : 1;    // 0x48, bit 3
	_IO32 output_1B : 1;    // 0x48, bit 4
	_IO32 output_2B : 1;    // 0x48, bit 5
    _IO32           : 26;
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
