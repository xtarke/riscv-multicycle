#include "led_rgb.h"
#include "../_core/hardware.h"

void led_rgb_init(void) {
    
}

void led_rgb_set_color(uint32_t rgb) {
    *(&RGB_BASE_ADDRESS + 1) = rgb;
    RGB_BASE_ADDRESS = 0x1;
}

