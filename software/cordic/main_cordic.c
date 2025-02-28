#include "../_core/utils.h"
#include "../_core/hardware.h"
#include "cordic.h"
#include "../gpio/gpio.h"

uint32_t test_case_1(void); // 45 deg
uint32_t test_case_2(void); // 30 deg
uint32_t test_case_3(void); // -45 deg

uint32_t test_case_1(void)
{
    uint32_t return_val;
    cordic_angle_in(12868); // 45 degs in rads = 0.7854. This value * 2^14 = 12868
    return_val = get_cordic_full();

    return return_val;
}

uint32_t test_case_2(void)
{
    uint32_t return_val;
    cordic_angle_in(8578); // 30 degs in rads = 0.5236. This value * 2^14 = 8578
    return_val = get_cordic_full();

    return return_val;
}

uint32_t test_case_3(void)
{
    uint32_t return_val;
    
    cordic_angle_in(52668);
   /* 
    *  This one's a little complicated.
    *  -0.7854 in fixed goes to -12868. Since we don´t use int16_t,
    *  this value in uint16_t becomes 52668, or 0xCDBC
    *  In 2's complement this becomes -12868
    */ 
   return_val = get_cordic_full();

   return return_val;
}



int main(void)
{
    uint32_t result = 0;
    uint32_t count = 0;

    while (1) {
        // sanity check
        // delay_(10);
        // result = 1;
        // CORDIC_BASE_ADDRESS = result;
        // delay_(100000);
        
        result = test_case_1();
        SEGMENTS_BASE_ADDRESS = result & 0xFFFF;
        delay_(100000);
        SEGMENTS_BASE_ADDRESS = (result >> 16);
        delay_(100000);
        result = test_case_2();
        SEGMENTS_BASE_ADDRESS = result & 0xFFFF;
        delay_(100000);
        SEGMENTS_BASE_ADDRESS = (result >> 16);
        delay_(100000);
        result = test_case_3();
        SEGMENTS_BASE_ADDRESS = result & 0xFFFF;
        delay_(100000);
        SEGMENTS_BASE_ADDRESS = (result >> 16);
        delay_(100000);

        
        
        count++;
        OUTBUS = count;

    
    }
}