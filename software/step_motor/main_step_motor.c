#include <stdint.h>
#include "step_motor.h"
#include "../gpio/gpio.h"

int main() {
    uint8_t spd = 0;
    
    while(1) {
        if (INBUS & MSK_RST == 1)
            reset_motor(1);
        else
            reset_motor(0);

        if (INBUS & MSK_STOP == 2) 
            stop_motor(1);
        else
            stop_motor(0);

        if (INBUS & MSK_REV == 4)
            reverse_rotation(1);
        else
            reverse_rotation(0);

        if (INBUS & MSK_HF == 8)
            change_step(1);
        else
            change_step(0);

        if(spd > 7){
            spd = 0;
        }

        change_speed(7);
        
        delay_(100000);
    }
    return 0;
}