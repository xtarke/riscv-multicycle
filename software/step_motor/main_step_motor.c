#include <stdint.h>
#include "step_motor.h"

int main() {
    reset_motor(1);
    while(1) {
        reset_motor(0);
        change_speed(5);
        change_step(1);
        stop_motor(0);
        reverse_rotation(0);
        delay_(2);

        change_step(0);
        delay_(1);

        stop_motor(1);
        delay_(3);
        reverse_rotation(1);
        delay_(1);

        change_speed(0);
        delay_(1);  

    }
    return 0;
}