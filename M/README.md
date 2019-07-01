# [“M” Standard Extension for Integer Multiplication and Division, Version 2.0](https://content.riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf#chapter.6)

[RV32/64G Instruction Set Listings](https://content.riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf#chapter.19)

![M word](./img/M_word.png)

![RV32M Standard Extension](./img/rv32M_standard_extension.png)

* MUL - **Signed\*Signed** 32 bits multiplication (rs1*rs2) - Place lower 32 bits in rd.
* MULH - **Signed\*Signed** 32 bits multiplication (rs1*rs2) - Place higher 32 bits in rd.
* MULHU - **Unsigned\*Unsigned** 32 bits multiplication (rs1*rs2) - Place higher 32 bits in rd.
* MULHSU - **Signed\*Unsigned** 32 bits multiplication (rs1*rs2) - Place higher 32 bits in rd.
* DIV - **Signed\*Signed** 32 bits division (rs1*rs2) - Place lower 32 bits in rd.
* DIVU - **Unsigned\*Unsigned** 32 bits division (rs1*rs2) - Place lower 32 bits in rd.
* REM - **Signed** remainder of the corresponding division operation
* REMU - **Unsigned** remainder of the corresponding division operation

![RV32M Standard Extension](./img/M_unit.png)

##Files to use M unit:

* M_types.vhd
* M.vhd

##Testbench:

* tb_M.do - Modelsim
* tb_M.vhd

##Code to Teste:
```C
#include "utils.h"
#include "hardware.h"
#include <limits.h>

int main(){
	volatile int a_int32=3, b_int32=2;
	volatile int a_int64=3, b_int64=2;

	volatile uint32_t a_uint32=INT_MAX, b_uint32=2;
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

		divu_result = a_uint32/b_uint32;

		div_result = a_int32%b_int32;

		divu_result = a_uint32%b_uint32;
	}

	return 0;
}
```
