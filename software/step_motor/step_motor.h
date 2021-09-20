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
    _IO32 rst;       // Reset motor to A state
    _IO32 stop;      // Stop motor in current state
    _IO32 reverse;   // Change motor spin direction
    _IO32 half_full; // Toggle motor's step size
    _IO32 speed;     // Change motor's speed in a range of 0 to 7;  
}step_motor_t;

#define STEP_BASE ((step_motor_t *) &STEP_M_BASE_ADDRESS)
#define MSK_RST  0x01
#define MSK_STOP 0x02
#define MSK_REV  0x04
#define MSK_HF   0x08

/**
  * @brief  Return step motor to initial state.
  * @param	val: Can be 0 or 1. Defines the reset state
  *
  * @retval void
  */
void reset_motor(uint8_t val);

/**
  * @brief  Stop motor rotation.
  * @param	val: Can be 0 or 1. Defines the stop state
  *
  * @retval void
  */
void stop_motor(uint8_t val);

/**
  * @brief  Changes motor's rotation .
  * @param	val: Can be 0 or 1. Defines the rotation direction
  *
  * @retval void
  */
void reverse_rotation(uint8_t val);

/**
  * @brief  Changes between half step or full step.
  * @param	val: Can be 0 or 1. Defines the step type
  *
  * @retval void
  */
void change_step(uint8_t val);

/**
  * @brief  Can increase or decrease motor's speed.
  * @param	val: Can be any value from 0 to 7
  *
  * @retval void
  */
void change_speed(uint8_t val);

#endif
