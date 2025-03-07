/*
 * morse.h
 *
 *  Created on: 13 de Fevereiro de 2019
 *      Author: Brian Lesllie Silva Azevedo e João Victor Maciel da Veiga
 *      Instituto Federal de Santa Catarina
 *
 */

#ifndef __MORSE_H
#define __MORSE_H

#include <stdint.h>
#include "../_core/hardware.h"

typedef struct {
  _IO32 entrada; // 0x00 + MORSE_BASE_ADDRESS
} MORSE_TYPE;

#define MORSE_0 ((MORSE_TYPE *) &MORSE_BASE_ADDRESS)

void write_num(uint32_t i);

#endif
