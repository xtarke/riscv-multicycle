#include <stdio.h>
#include <stdint.h>





foo(){
	int y;

	y = 3 +4;
}

void delay(){
    int i;
    
    for (i=0; i < 500000; i++);
}


int main(){

	int i;
    int loop = 1;
        
    uint32_t *io_map = 0x00040000;

	while (loop){
        *io_map = 1;
        // delay();
        *io_map = 0;
        // delay();
        
        loop--;
    }

	return 0;
}
