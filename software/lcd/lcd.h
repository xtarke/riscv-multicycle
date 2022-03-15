/** @file lcd.h
 *  @brief Nokia 5110 LCD display header file.
 * 
 *  Provides functions, defines and access to the RISCV
 *  memory databus.
*/

#ifndef __LCD_H
#define __LCD_H

#include <stdint.h>
#include "../_core/utils.h"
#include "../_core/hardware.h"

/**
 * Nokia 5110 LCD display initialization function.
 *  
 * Power up the display in a blank screen and implements
 * busy waiting for its delays.
 * 
 * @param None
 */
void lcd_init(void);

/**
 * Nokia 5110 LCD display clear function.
 *  
 * Clears the display after it has already been initialized. 
 * 
 * @param None
 */
void lcd_clear(void);

/**
 * Nokia 5110 LCD display print function.
 *  
 * Prints a string till it reaches the provided length.
 * Also allows the definition of its starting column and line.
 * 
 * @param string String to be printed
 * @param len Maximum length to be printed
 * @param x Column inital position
 * @param y Line initial position
 */
void lcd_print(char *string, _IO32 len, _IO32 x, _IO32 y);

/**
 * Nokia 5110 LCD display controller register type.
 * Provides variables to interact with the controller's
 * state machine.
 */
typedef struct{
    _IO32 reg_ctrl; /**< State machine control register. */
    _IO32 pos;      /**< Data index. */
    _IO32 data;     /**< Data to display.*/
    _IO32 we;       /**< Write enable */
} DISPLAY_NOKIA_5110_REG_TYPE;

/**
 * Nokia 5110 LCD display controller register declaration.
 */
#define DISPLAY_NOKIA_5110_REGISTER ((DISPLAY_NOKIA_5110_REG_TYPE *) &DISPLAY_NOKIA_5110_BASE_ADDRESS)

/**
 * Nokia 5110 LCD display controller line size.
 */
#define DISPLAY_NOKIA_5110_HEIGHT 6

/**
 * Nokia 5110 LCD display controller column size.
 */
#define DISPLAY_NOKIA_5110_WIDTH 84

/**
 * Nokia 5110 LCD display controller space between characters.
 */
#define DISPLAY_NOKIA_5110_LETTER_SPACING 6

#endif 