#include <stdint.h>

#include "../_core/utils.h"
#include "../_core/hardware.h"
#include "../gpio/gpio.h"
#include "raiz.h"

int main(void)
{
    uint32_t valor;

    while (1)
    {
        /*
         * SW8 seleciona o que será mostrado.
         *
         * SW8 = 0 -> Resultado da raiz
         * SW8 = 1 -> Resto da divisão
         */

        if (INBUS & (1 << 8))
        {
            valor = raiz_get_remainder();
        }
        else
        {
           // valor = raiz_get_result();
        }

        SEGMENTS_BASE_ADDRESS = valor;
    }

    return 0;
}