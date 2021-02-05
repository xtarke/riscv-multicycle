/*
 * utils.h
 *
 *  Created on: Dez 9, 2019
 *      Author: Jhonatan; Alexsandro
 *      Instituto Federal de Santa Catarina
 *
 * I2c functions
 *  - send data
 *  - (...)
 *
 */


#ifndef __I2C_H
#define __I2C_H

#include <stdint.h>
#include "../_core/hardware.h"

#define I2C I2C_BASE_ADDRESS

int I2C_write(uint8_t data, uint8_t addr);

// I2C_write_vector

#endif // __UART_H
