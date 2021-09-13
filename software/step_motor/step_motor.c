
#include "step_motor.h"
#include <stdint.h>

void reset_motor(uint8_t val) {
    STEP_BASE->rst = val;
}
void stop_motor(uint8_t val) {
    STEP_BASE->stop = val;
}
void reverse_rotation(uint8_t val) {
    STEP_BASE->reverse = val;
}