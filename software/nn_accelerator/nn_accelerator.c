
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



void set_weigh(int8_t w0_0, int8_t w1_0, int8_t w0_1, int8_t w1_1, int8_t w0_2, int8_t w1_2){
    NN_A_BASE->w0_0 = w0_0;
    NN_A_BASE->w1_0 = w1_0;
    NN_A_BASE->w0_1 = w0_1;
    NN_A_BASE->w1_1 = w1_1;
    NN_A_BASE->w0_2 = w0_2;
    NN_A_BASE->w1_2 = w1_2;
}



int8_t inference(int8_t x0, int8_t x1){
    NN_A_BASE->x0 = x0;
    NN_A_BASE->x1 = x1;
    //delay_(2);
    return NN_A_BASE->y1;
}

