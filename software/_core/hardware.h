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
 * IO MAP mapped to  addr >= 0x4000000 
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

#define _IO8 _IO

#ifndef _IO16
#define _IO16 volatile uint16_t
#endif

#ifndef _IO32
#define _IO32 volatile uint32_t
#endif

#ifndef _IO32S
#define _IO32S volatile int32_t
#endif

#define PERIPH_BASE     ((uint32_t)0x4000000)          /*!< Peripheral base address */
#define SDRAM_BASE      ((uint32_t)0x6000000)          /*!< SDRAM base address */
#define SDRAM           (*(_IO32 *) (SDRAM_BASE))      /*!< SDRAM base address */

// flash base address is the same of SDRAM plus an offset. this is due to the
// length of 'dcsel' (2 bits) in databusmux.vhd. There isn't room for more then
// 4 peripherals there. if we increase the 'dcsel' length, then all references
// to it must be changed in the codebase (TODO?!).

// Address space (byte based) and chip select:
// 0x0000000000 ->  0b000 0000 0000 0000 0000 0000 0000 -> Instruction memory
// 0x0002000000 ->  0b010 0000 0000 0000 0000 0000 0000 -> Data memory
// 0x0004000000 ->  0b100 0000 0000 0000 0000 0000 0000 -> Input/Output generic address space
// 0x0006000000 ->  0b110 0000 0000 0000 0000 0000 0000 -> SDRAM
// 0x0007000000 ->  0b111 0000 0000 0000 0000 0000 0000 -> FLASH

#define FLASH_BASE		((uint32_t)0x7000000)       /*!< FLASH base address */
#define FLASH 			(*(_IO32 *) (FLASH_BASE))	/*!< FLASH base address */

// Each peripheral has 16 reserved memory addresses
// In that .h only the base address must be defined
// The specific addresses must be defined in the respective .h of the periphery
// Take gpio.h as an example


#define IONBUS_BASE_ADDRESS                 (*(_IO32 *) (PERIPH_BASE))
#define SEGMENTS_BASE_ADDRESS               (*(_IO32 *) (PERIPH_BASE + 1*16*4))
#define UART_BASE_ADDRESS                   (*(_IO32 *) (PERIPH_BASE + 2*16*4))
#define ADC_BASE_ADDRESS                    (*(_IO32 *) (PERIPH_BASE + 3*16*4))
#define I2C_BASE_ADDRESS                    (*(_IO32 *) (PERIPH_BASE + 4*16*4))
#define TIMER_BASE_ADDRESS                  (*(_IO32 *) (PERIPH_BASE + 5*16*4))
#define SPI_BASE_ADDRESS                    (*(_IO32 *) (PERIPH_BASE + 6*16*4))
#define TFT_BASE_ADDRESS                    (*(_IO32 *) (PERIPH_BASE + 7*16*4))
#define DIG_FIL_BASE_ADDRESS                (*(_IO32 *) (PERIPH_BASE + 8*16*4))
#define STEP_M_BASE_ADDRESS                 (*(_IO32 *) (PERIPH_BASE + 9*16*4))
#define DISPLAY_NOKIA_5110_BASE_ADDRESS     (*(_IO32 *) (PERIPH_BASE + 10*16*4))
#define NN_A_BASE_ADDRESS                   (*(_IO32 *) (PERIPH_BASE + 11*16*4))
#define HD44780_BASE_ADDRESS                (*(_IO32 *) (PERIPH_BASE + 12*16*4))
#define FIR_FILT_BASE_ADDRESS               (*(_IO32 *) (PERIPH_BASE + 13*16*4))
#define KEYBOARD_BASE_ADDRESS               (*(_IO32 *) (PERIPH_BASE + 14*16*4))
#define CRC_BASE_ADDRESS           	        (*(_IO32 *) (PERIPH_BASE + 15*16*4))
#define SPWM_BASE_ADDRESS                   (*(_IO32 *) (PERIPH_BASE + 17*16*4))
#define ACCELEROMETER_BASE_ADDRESS          (*(_IO32 *) (PERIPH_BASE + 18*16*4))
#define SIMPLE_SERIAL_TRANSMITTER_ADDRESS   (*(_IO32 *) (PERIPH_BASE + 19*16*4))
#define MORSE_BASE_ADDRESS                  (*(_IO32 *) (PERIPH_BASE + 20*16*4))
#define CORDIC_BASE_ADDRESS                 (*(_IO32 *) (PERIPH_BASE + 21*16*4))
#define RS485_BASE_ADDRESS                	(*(_IO32 *) (PERIPH_BASE + 23*16*4))
#define IRDA_BASE_ADDRESS                   (*(_IO32 *) (PERIPH_BASE + 24*16*4))

//#define TFT_DATA0		(*(_IO32 *) (PERIPH_BASE + 32))	
//#define TFT_DATA1		(*(_IO32 *) (PERIPH_BASE + 36))	
//#define TFT_DATA2		(*(_IO32 *) (PERIPH_BASE + 40))	
//#define TFT_RETURN    (*(_IO32 *) (PERIPH_BASE + 44))	

#endif //HARDWARE_H
