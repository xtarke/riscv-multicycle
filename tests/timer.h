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

void timer_config(uint32_t mode, uint32_t prescaler, uint32_t top_counter);
void timer_reset(void);

void timer_set_compare0A(uint32_t comp_value);
void timer_set_compare0B(uint32_t comp_value);
void timer_set_compare1A(uint32_t comp_value);
void timer_set_compare1B(uint32_t comp_value);
void timer_set_compare2A(uint32_t comp_value);
void timer_set_compare2B(uint32_t comp_value);

uint32_t timer_get_output0A(void);
uint32_t timer_get_output0B(void);
uint32_t timer_get_output1A(void);
uint32_t timer_get_output1B(void);
uint32_t timer_get_output2A(void);
uint32_t timer_get_output2B(void);

#endif // __TIMER_H
