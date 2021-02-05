#ifndef __GPIO_H
#define __GPIO_H

#include "../_core/hardware.h"

#define INBUS               *(&IONBUS_BASE_ADDRESS)
#define OUTBUS              *(&IONBUS_BASE_ADDRESS + 1)
#define EXTIx_IRQ_ENABLE    *(&IONBUS_BASE_ADDRESS + 2)
#define EXTIx_EDGE          *(&IONBUS_BASE_ADDRESS + 3)

#define SEGMENTS *(&SEGMENTS_BASE_ADDRESS)
#define HEX0    *(&SEGMENTS_BASE_ADDRESS)
#define HEX1    *(&SEGMENTS_BASE_ADDRESS + 1)
#define HEX2    *(&SEGMENTS_BASE_ADDRESS + 2)
#define HEX3    *(&SEGMENTS_BASE_ADDRESS + 3)
#define HEX4    *(&SEGMENTS_BASE_ADDRESS + 4)
#define HEX5    *(&SEGMENTS_BASE_ADDRESS + 5)

typedef enum EDGE
{

    RISING_EDGE               = 0,                            
    FALLING_EDGE              = 1,                            

	EDGE_ENUM
} EDGE_Type;




/* define interrupt number */
typedef enum GPIOx
{

    GPIO0                   = ((uint32_t)((uint32_t)0x01U<<(0))),                            
    GPIO1                   = ((uint32_t)((uint32_t)0x01U<<(1))),                            
    GPIO2                   = ((uint32_t)((uint32_t)0x01U<<(2))),                            
    GPIO3                   = ((uint32_t)((uint32_t)0x01U<<(3))),                            
    GPIO4                   = ((uint32_t)((uint32_t)0x01U<<(4))),                            
    GPIO5                   = ((uint32_t)((uint32_t)0x01U<<(5))),                                
    GPIO6                   = ((uint32_t)((uint32_t)0x01U<<(6))),     
    GPIO7                   = ((uint32_t)((uint32_t)0x01U<<(7))),     
    GPIO8                   = ((uint32_t)((uint32_t)0x01U<<(8))),     
    GPIO9                   = ((uint32_t)((uint32_t)0x01U<<(9))),     
    GPIO10                  = ((uint32_t)((uint32_t)0x01U<<(10))),                                         
    GPIO11                  = ((uint32_t)((uint32_t)0x01U<<(11))),                                         
    GPIO12                  = ((uint32_t)((uint32_t)0x01U<<(12))),         
    GPIO13                  = ((uint32_t)((uint32_t)0x01U<<(13))),         
    GPIO14                  = ((uint32_t)((uint32_t)0x01U<<(14))),         
    GPIO15                  = ((uint32_t)((uint32_t)0x01U<<(15))),         


	GPIO_NUM_INTERRUPTS
} GPIOx_Type;



void input_interrupt_enable(GPIOx_Type irq,EDGE_Type edge);



#endif