/*
 *
 *
 */
#include "accelerometer.h"

int main(void)
{
    while(1)
    {
		OUTBUS = read_axe_x();
		delay_(100000);
		OUTBUS = read_axe_y();
		delay_(100000);
		OUTBUS = read_axe_z();
		delay_(100000);
    }
	return 0;
}
