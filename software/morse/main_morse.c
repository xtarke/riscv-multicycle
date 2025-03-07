/*
 * morse.c
 *
 *  Created on: 13 de Fevereiro de 2019
 *      Author: Brian Lesllie Silva Azevedo e João Victor Maciel da Veiga
 *      Instituto Federal de Santa Catarina
 *
 */

#include "morse.h"

int main(void){
  uint32_t i = 0;
  while(1){
    write_num(i);
    i++;
    
    i = i & 0x7;
    
    //if (i==10){
    //  i=0;
    
  }
}
