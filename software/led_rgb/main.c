#include "led_rgb.h"
#include "../_core/utils.h"

int main(void) {
    led_rgb_init();

    // Define a cor verde (0xFF0000)
    //led_rgb_set_color(0x0000ff);
    // Define a cor vermelha (0xFF0000)
    //led_rgb_set_color(0x00FF00);

    

    while (1) {
        //led_rgb_set_color(0x0000ff);
        led_rgb_set_color(0x0000FF);
        delay_(50000);
        led_rgb_set_color(0xFF0000);
        delay_(50000);
        led_rgb_set_color(0x00FF00);
        delay_(50000);
    }

    return 0;
}
