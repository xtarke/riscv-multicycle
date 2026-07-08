#ifndef __RAIZ_H
#define __RAIZ_H

#include <stdint.h>
#include "../_core/hardware.h"

/*-------------------------------------------------------
 * Registradores do periférico RAIZ
 *
 * Offset 0 -> Operando (SW)
 * Offset 1 -> Resultado
 * Offset 2 -> Resto
 *------------------------------------------------------*/



#define SQRT_INPUT      (*(&SQRT_BASE_ADDRESS))
#define SQRT_RESULT     (*(&SQRT_BASE_ADDRESS + 1))
#define SQRT_REMAINDER  (*(&SQRT_BASE_ADDRESS + 2))

uint16_t raiz_get_input(void);

uint8_t raiz_get_result(void);

uint8_t raiz_get_remainder(void);

#endif

