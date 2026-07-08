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
        if (INBUS & (1 << 8))
        {
            valor = raiz_get_remainder();
        }
        else
        {
            valor = raiz_get_result();
        }

        SEGMENTS = valor;
    }

    return 0;
}