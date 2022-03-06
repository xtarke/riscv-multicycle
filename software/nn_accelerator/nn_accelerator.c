
#include "../_core/utils.h"
#include "nn_accelerator.h"
#include <stdint.h>

/*
void input_interrupt_enable(GPIOx_Type irq,EDGE_Type edge){
    EXTIx_IRQ_ENABLE = irq | EXTIx_IRQ_ENABLE;
    if(edge == RISING_EDGE){
        EXTIx_EDGE = EXTIx_EDGE & ~irq;
    }else{
        EXTIx_EDGE = EXTIx_EDGE | irq;
    }
}
*/



int8_t inference(int8_t x0, int8_t x1){
    NN_A_BASE->x0 = x0;
    return NN_A_BASE->y1;
}

void set_weigh(int8_t w0, int8_t x1, int8_t x2){
    
}
