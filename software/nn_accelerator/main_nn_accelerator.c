#include <stdint.h>
#include "nn_accelerator.h"

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
        //y1 deve ser 127, para essas entradas e esses pesos
        //TODO: what to do with y1?!
        delay_(1);
    }
    return 0;
}