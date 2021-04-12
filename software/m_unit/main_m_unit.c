/*
 * firmware.c
 *
 *  Created on: Jul 08, 2019
 *      Author: Lucas Seara Manoel
 *      Instituto Federal de Santa Catarina
 *
 *
 * Mul/Div unit tests
 * -----------------------------------------
 */


#include "../_core/utils.h"
#include "../_core/hardware.h"
#include "../gpio/gpio.h"
#include <limits.h>


int main(){
	volatile int a_int32=3, b_int32=2;
	volatile int a_int64=3, b_int64=2;

	volatile uint32_t a_uint32=INT_MAX, b_uint32=1;
	volatile uint64_t a_uint64=INT_MAX, b_uint64=2;

	volatile uint64_t mul_result;
   	volatile uint32_t mulh_result;
   	volatile uint32_t mulhsu_result;
   	volatile uint32_t mulhu_result;
   	volatile int div_result;
   	volatile uint32_t divu_result;
   	volatile int rem_result;
   	volatile uint32_t remu_result;

	while (1){

		mul_result = a_uint32 * b_int32;

		mulh_result = a_int64*b_int64;

		mulhsu_result = a_uint64*b_uint64;

		mulh_result = a_int64*b_int64;

		div_result = a_int32/b_int32;
		OUTBUS = div_result;
		delay_(1000000);

		divu_result = a_uint32/b_uint32;
		OUTBUS = divu_result;
		delay_(1000000);

		div_result = a_int32%b_int32;
		OUTBUS = div_result;
		delay_(1000000);

		divu_result = a_uint32%b_uint32;
		OUTBUS = divu_result;
		delay_(1000000);

	}

	return 0;
}
