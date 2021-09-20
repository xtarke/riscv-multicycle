/* 
	digital filter peripheral
*/

#include "dig_filt.h"
#include "../gpio/gpio.h"

int main(){
	uint32_t data = 0;

	dig_filt_enable(1);						// habilitada filtro

	while (1){

        /* Read input bus */
        if (INBUS)
            /* Resets data when any input is high */
            data = 0;


        SEGMENTS_BASE_ADDRESS = dig_filt_get_output();  // get output function
        OUTBUS = data;
		
		data++;
		      
		delay_(100000);						// for human interaction
		
	
	}

	return 0;
}
