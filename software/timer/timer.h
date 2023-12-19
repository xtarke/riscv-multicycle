/*
 * timer.h
 *
 *  Created on: July 1, 2019
 *      Author: Rafael Reis e Joï¿½o Antï¿½nio Cardoso
 *      Instituto Federal de Santa Catarina
 *
 */

#ifndef __TIMER_H
#define __TIMER_H

#include <stdint.h>
#include "../_core/hardware.h"

typedef struct {
  _IO32 timer_reset;      // 0x00 + TIMER_BASE_ADDRESS
  _IO32 timer_mode;       // 0x04 ...    ....
  _IO32 prescaler;        // 0x08a

  _IO32 top_counter;      // 0x0C
  _IO32 compare_0A;       // 0x10
  _IO32 compare_0B;       // 0x14
  _IO32 compare_1A;       // 0x18
  _IO32 compare_1B;       // 0x1C
  _IO32 compare_2A;       // 0x20
  _IO32 compare_2B;       // 0x24

  _IO32 output_0A : 1;    // 0x28, bit 0
  _IO32 output_1A : 1;    // 0x28, bit 1
  _IO32 output_2A : 1;    // 0x28, bit 2
  _IO32 output_0B : 1;    // 0x28, bit 3
  _IO32 output_1B : 1;    // 0x28, bit 4
  _IO32 output_2B : 1;    // 0x28, bit 5
  _IO32           : 26;

  _IO32 enable_irq;       // 0x2C
  _IO32 capture_value;     // 0x30
  
  _IO32 dead_time;     // 0x34
  
} TIMER_TYPE;


#define TIMER_0 ((TIMER_TYPE *) &TIMER_BASE_ADDRESS)

void timer_config(uint32_t mode, uint32_t prescaler, uint32_t top_counter);
void timer_reset(void);

void timer_set_compare0A(uint32_t comp_value);
void timer_set_compare0B(uint32_t comp_value);
void timer_set_compare1A(uint32_t comp_value);
void timer_set_compare1B(uint32_t comp_value);
void timer_set_compare2A(uint32_t comp_value);
void timer_set_compare2B(uint32_t comp_value);
void timer_set_dead_time(uint32_t dead_time);

uint32_t timer_get_output0A(void);
uint32_t timer_get_output0B(void);
uint32_t timer_get_output1A(void);
uint32_t timer_get_output1B(void);
uint32_t timer_get_output2A(void);
uint32_t timer_get_output2B(void);
uint32_t timer_get_capture(void);

#endif // __TIMER_H
