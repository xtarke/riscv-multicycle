/*
 * firmware.c
 *
 *  Created on: Jan 20, 2019
 *      Author: Renan Augusto Starke
 *      Instituto Federal de Santa Catarina
 * 
 * 
 * Simple LED blink example.
 * -----------------------------------------
 */


#include "utils.h"
#include "hardware.h"


int main(){
	volatile int a_int=3, b_int=2;
	volatile uint32_t a_uint=3, b_uint=2;

	volatile uint64_t mul_result;
   	volatile uint32_t mulh_result;
   	volatile uint32_t mulhsu_result;
   	volatile uint32_t mulhu_result;
   	volatile int div_result;
   	volatile uint32_t divu_result;
   	volatile int rem_result;
   	volatile uint32_t remu_result;

	while (1){


		mul_result = a_uint * b_int;
//		mulh_result = a_int*b_int;//02e787b3s
//		mulhsu_result = a_uint*b_uint;
//		mulh_result = a_int*b_int;
//		div_result = a_int/b_int;
//		divu_result = a_uint/b_uint;
//		div_result = a_int%b_int;
//		divu_result = a_uint%b_uint;

//		/* To blink */
//		OUTBUS = 0x10;
//		SEGMENTS = 0xFFFFFFC0;
//		delay_(25000);
//        
//		OUTBUS = 0;
//        SEGMENTS = 0xFFFFFFFF;
//		delay_(25000); 
//        
//		/* To test Data Bus 
//		x = INBUS;        
//		OUTBUS = x; */
	}

	return 0;
}

/*
00000144 <main>:
 144:	fe010113          	addi	sp,sp,-32
 148:	00300713          	li	a4,3
 14c:	00e12e23          	sw	a4,28(sp)
 150:	00200793          	li	a5,2
 154:	00f12c23          	sw	a5,24(sp)
 158:	00e12a23          	sw	a4,20(sp)
 15c:	00f12823          	sw	a5,16(sp)
 160:	01c12783          	lw	a5,28(sp)
 164:	01812703          	lw	a4,24(sp)
 168:	02e787b3          	mul	a5,a5,a4
 16c:	00f12623          	sw	a5,12(sp)
 170:	ff1ff06f          	j	160 <main+0x1c>
 */