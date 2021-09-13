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

#define PERIPH_BASE		((uint32_t)0x4000000)          /*!< Peripheral base address */
#define SDRAM_BASE		((uint32_t)0x6000000)          /*!< SDRAM base address */

#define SDRAM 			(*(_IO32 *) (SDRAM_BASE))		/*!< SDRAM base address */

// Each peripheral has 16 reserved memory addresses
// In that .h only the base address must be defined
// The specific addresses must be defined in the respective .h of the periphery
// Take gpio.h as an example
#define IONBUS_BASE_ADDRESS 		(*(_IO32 *) (PERIPH_BASE))			    
#define SEGMENTS_BASE_ADDRESS 		(*(_IO32 *) (PERIPH_BASE + 1*16*4))		
#define UART_BASE_ADDRESS 			(*(_IO32 *) (PERIPH_BASE + 2*16*4))	
#define ADC_BASE_ADDRESS 		    (*(_IO32 *) (PERIPH_BASE + 3*16*4))		
#define I2C_BASE_ADDRESS 			(*(_IO32 *) (PERIPH_BASE + 4*16*4))	
#define TIMER_BASE_ADDRESS 			(*(_IO32 *) (PERIPH_BASE + 5*16*4))		
#define SPI_BASE_ADDRESS 		    (*(_IO32 *) (PERIPH_BASE + 6*16*4))	
#define TFT_BASE_ADDRESS            (*(_IO32 *) (PERIPH_BASE + 7*16*4))	
//#define TFT_DATA0		(*(_IO32 *) (PERIPH_BASE + 32))	
//#define TFT_DATA1		(*(_IO32 *) (PERIPH_BASE + 36))	
//#define TFT_DATA2		(*(_IO32 *) (PERIPH_BASE + 40))	
//#define TFT_RETURN    (*(_IO32 *) (PERIPH_BASE + 44))	
#define STEP_M_BASE_ADDRESS         (*(_IO32 *) (PERIPH_BASE + 9*16*4))


#endif //HARDWARE_H
