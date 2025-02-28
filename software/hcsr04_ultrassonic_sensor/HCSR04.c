#include <stdint.h>
#include "HCSR04.h"
#include "../_core/hardware.h"


uint32_t HCSR04_read(void)
{
	return HCSR04_REGISTER->measure;
}