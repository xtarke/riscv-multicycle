/*
 * hardware.h
 *
 *  Created on: May 20, 2019
 *      Author: Renan Augusto Starke
 *      Instituto Federal de Santa Catarina
 * 
 * 
 * riscv-multicycle Hardware Map (registers)
 * -----------------------------------------
 * IO MAP mapped to  addr >= 0x40000 
 * 
 * 
 */


#ifndef __HARDWARE_H
#define __HARDWARE_H

#include <stdint.h>

#define CPU_CLOCK 1000000     /*!< PLL is adjusted to 1 MHz */

#ifndef _IO
#define _IO volatile uint8_t
#endif

#ifndef _IO16
#define _IO16 volatile uint16_t
#endif

#ifndef _IO32
#define _IO32 volatile uint32_t
#endif

#define PERIPH_BASE		((uint32_t)0x40000)          /*!< Peripheral base address */

#define INBUS 			(*(_IO32 *) (PERIPH_BASE))		/*!< Generic INPUT BUS - 32-bit register */
#define OUTBUS			(*(_IO32 *) (PERIPH_BASE + 4))	/*!< Generic OUPUT BUS - 32-bit register */
#define SEGMENTS		(*(_IO32 *) (PERIPH_BASE + 8))	/*!< Generic INPUT BUS - 32-bit register */
#define UART_TX			(*(_IO32 *) (PERIPH_BASE + 12))	/*!< Generic INPUT BUS - 32-bit register */
#define UART_RX			(*(_IO32 *) (PERIPH_BASE + 16))	/*!< Generic INPUT BUS - 32-bit register */

#endif //HARDWARE_H
