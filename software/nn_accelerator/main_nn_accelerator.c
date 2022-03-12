#include <stdint.h>
#include "nn_accelerator.h"
#include "../gpio/gpio.h"

int main(){
    int8_t w0_0 = 1;
    int8_t w1_0 = 2;
    int8_t w0_1 = 1;
    int8_t w1_1 = -2;
    int8_t w0_2 = 1;
    int8_t w1_2 = 1;
    int8_t x0;
    int8_t x1;
    int8_t y1;
    set_weigh(w0_0, w1_0, w0_1, w1_1, w0_2, w1_2);
    while(1){
        x0 = 1;
        x1 = 2;
        y1 = inference(x0, x1);
        
        // Show in GPIO
        if (y1==(int8_t)127){ //worked
            // By my testing convention, I should write 1 to the lest-most GPIO to indiciate that the test succeded
            // This will be asserted in the testbench
            OUTBUS = 0b10000000000000000000000000000000 | (uint32_t) y1;
            //OUTBUS = 0b10101010101010101010101010101010;
            //OUTBUS = (uint32_t) y1;
        } else { //failed
            OUTBUS = 0b01111111111111111111111111111111 & (uint32_t) y1;
            //OUTBUS = 0b00110011001100110011001100110011;
            //OUTBUS = (uint32_t) y1;
        }
        delay_(1);
    }
    return 0;
}