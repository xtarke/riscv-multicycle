
#include "../_core/utils.h"
#include "../gpio/gpio.h"
#include <stdint.h>

void input_interrupt_enable(GPIOx_Type irq,EDGE_Type edge){
    EXTIx_IRQ_ENABLE = irq | EXTIx_IRQ_ENABLE;
    if(edge == RISING_EDGE){
        EXTIx_EDGE = EXTIx_EDGE & ~irq;
    }else{
        EXTIx_EDGE = EXTIx_EDGE | irq;
    }
}

