/* 
	fir filter peripheral
*/

#include "fir_filt.h"
#include "../gpio/gpio.h"

int main(){
			
	fir_filter_coefficient0(1);
    fir_filter_coefficient1(2);
    fir_filter_coefficient2(3);
    fir_filter_coefficient3(4);

	while (1){
        
        OUTBUS = fir_filt_get_output_msb_data();
        SEGMENTS_BASE_ADDRESS = fir_filt_get_output_lsb_data();
        	      
		delay_(100000);						// for human interaction
		
	}

	return 0;
}
