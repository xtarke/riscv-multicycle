#include <stdio.h>


foo(){
	int y;

	y = 3 +4;
}

int main(){

	int i;

	for (i=0; i < 4; i++){
		foo();
	}

	return 0;
}
