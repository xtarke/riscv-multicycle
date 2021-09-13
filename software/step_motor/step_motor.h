/*************************************************************************
 * Project: Step Motor controller                                        *
 * Created on: Sept, 2021                                                *
 * Author: Rayan Martins Steinbach                                       *
 * Instituto Federal de Educação, Ciência e Tecnologia de Santa Catarina *
 *************************************************************************/

#ifndef _STEP_MOTOR_H
#define _STEO_MOTOR_H



#include "../_core/hardware.h"
#include "../_core/utils.h"

typedef struct {
    _IO8 rst : 1;       // Reset motor to A state
    _IO8 stop :1;       // Stop motor in current state
    _IO8 reverse : 1;   // Change motor spin direction
}step_motor_t;

#define STEP_BASE ((step_motor_t *) &STEP_M_BASE_ADDRESS)
#define MSK_RST 0x01
#define MSK_STOP 0x02
#define MSK_ROT 0x04

void reset_motor(uint8_t val);
void stop_motor(uint8_t val);
void reverse_rotation(uint8_t val);

#endif
