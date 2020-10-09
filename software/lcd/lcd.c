#include <stdint.h>
#include "utils.h"
#include "hardware.h"

int main(){
	char letter = 'A';

	
	while (1){
		OUTBUS = letter;
		delay_(1000);
	}

	return 0;
}