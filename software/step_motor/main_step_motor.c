#include "step_motor.h"
#include "../gpio/gpio.h"

int main() {
    while(1) {
        if (INBUS & MSK_RST == 1)
            reset_motor(1);
        else
            reset_motor(0);

        if (INBUS & MSK_STOP == 2) 
            stop_motor(1);
        else
            stop_motor(0);

        if (INBUS & MSK_ROT == 4)
            reverse_rotation(1);
        else
            reverse_rotation(0);        
        delay_(100000);
    }
    return 0;
}