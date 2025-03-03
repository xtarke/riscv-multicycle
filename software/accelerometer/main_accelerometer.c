/*
 *
 *    Aluno: Victor Lompa Schwider (edit: Kenner Marqueti Couto , 18 Feb 2025)
 *    Data : 07 Dez 2023
 */
#include "accelerometer.h"
#include "../_core/hardware.h"
#include "../_core/utils.h"
#include "../gpio/gpio.h"

uint32_t complemento (uint32_t x) {
    // Check if the number is negative (MSB is 1)
    if (x & 0x80000000) {
        return ~x + 1; // Compute two's complement (negate)
    }
    return x; // Already positive
}

int main(void){
    const int sense = 10; // Bubble effect sensibility
    uint32_t axe;
    uint32_t entrada;
    int32_t signed_axe;
    uint8_t abs_axe;


   
       // Bubble effect with leds based on axe value
    uint32_t bubble[19] =  {0x0200, 0x0300, 0x0100, 0x0180,
                            0x0080, 0x00c0, 0x0040, 0x0060,
                            0x0020, 0x0030, 0x0010, 0x0018, 
                            0x0008, 0x000c, 0x0004, 0x0006, 
                            0x0002, 0x0003, 0x0001};

    while(1)
    {
        entrada = (INBUS&0X7);
        if      (((entrada)) == 1){      // If SW(0) is on return axe_x values
            axe = read_axe_x();}
        else if (((entrada)) == 2){      // If SW(1) is on return axe_y values
            axe = read_axe_y();}
        else if (((entrada)) == 3){      // If SW(0) and SW(1) is on return axe_z values
            axe = read_axe_z();}
        else if (((entrada)) == 5){      // If SW(2) AND SW(0) is on return axe_x_max values
            axe = read_axe_x_max();}
        else if (((entrada)) == 6){      // If SW(2) and SW(1) is on return axe_y_max values
            axe = read_axe_y_max();}  
        else if (((entrada)) == 7){      // If SW(2) and SW(1) and SW(0) is on return axe_z_max values
            axe = read_axe_z_max();}   
        else{                              // If none of the above, return 0
            axe = 0;} 	
        
        signed_axe = (int32_t) axe;
        abs_axe = (uint8_t)((signed_axe < 0) ? -signed_axe : signed_axe);
        //axe = (signed_axe < 0) ? -signed_axe : axe;

//        SEGMENTS = "0xABCD12";

        // Negative values
        // Must not be higher than FCFF otherwise it will pop up the led on the positive side
        if      (axe > 0xffff -    sense){OUTBUS = bubble[9];}
        else if (axe > 0xffff -  2*sense){OUTBUS = bubble[10];}
        else if (axe > 0xffff -  3*sense){OUTBUS = bubble[11];}
        else if (axe > 0xffff -  4*sense){OUTBUS = bubble[12];}
        else if (axe > 0xffff -  5*sense){OUTBUS = bubble[13];}
        else if (axe > 0xffff -  6*sense){OUTBUS = bubble[14];}
        else if (axe > 0xffff -  7*sense){OUTBUS = bubble[15];}
        else if (axe > 0xffff -  8*sense){OUTBUS = bubble[16];}
        else if (axe > 0xffff -  9*sense){OUTBUS = bubble[17];}
        else if (axe > 0xfcff)           {OUTBUS = bubble[18];}

        // Positive values
        else if (axe > 8*sense){OUTBUS = bubble[0];}
        else if (axe > 7*sense){OUTBUS = bubble[1];}
        else if (axe > 6*sense){OUTBUS = bubble[2];}
        else if (axe > 5*sense){OUTBUS = bubble[3];}
        else if (axe > 4*sense){OUTBUS = bubble[4];}
        else if (axe > 3*sense){OUTBUS = bubble[5];}
        else if (axe > 2*sense){OUTBUS = bubble[6];}
        else if (axe >   sense){OUTBUS = bubble[7];}
        else if (axe >=      0){OUTBUS = bubble[8];}

        else {OUTBUS = 0x0000;}

        SEGMENTS = abs_axe;
        // Check if values are working on hardware with fixed value
        // OUTBUS = 0x2ef;

        
    }
	return 0;
}
