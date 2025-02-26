/*
 * morse.c
 *
 *  Created on: 13 de Fevereiro de 2019
 *      Author: Brian Lesllie Silva Azevedo e João Victor Maciel da Veiga
 *      Instituto Federal de Santa Catarina
 *
 */

#include "morse.h"

void write_num(uint32_t i){
  MORSE_0->entrada = i; // escreve no endereço base
}
