#include "../_core/hardware.h"
#include "../_core/utils.h"
#include "../gpio/gpio.h"
#include "HCSR04.h"

int main()
{
	int buffer = 0;
	uint8_t count = 0;
	uint32_t measure_clks = 0;
	uint32_t measure_clks_temp = 0;


	while (1)
	{

		measure_clks = HCSR04_read();
		if (measure_clks < 80)
		{
			measure_clks = 0;
		}
		if (measure_clks_temp > 80 && measure_clks == 0)
		{
			count++;
		}
		measure_clks_temp = measure_clks;


	
		SEGMENTS = count;

		
	}

	return 0;
}
