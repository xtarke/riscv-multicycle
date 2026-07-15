//---------------------------------------------------
// IFSC
//Projeto Final - Sofia e Ueslei
// Periférico de Raiz Quadrada
//---------------------------------------------------

#include <stdint.h>

#include "../_core/utils.h"
#include "../_core/hardware.h"
#include "raiz.h"

int main(void)
{
    uint32_t valor;

    while (1)
    {
        /*
         * KEY0 (bit 10) seleciona o que será mostrado.
         * Botão é ativo em nível baixo: 0 = pressionado.
         *
         * KEY0 pressionado -> mostra o resto
         * KEY0 solto       -> mostra o resultado
         */
        if ((IONBUS_BASE_ADDRESS & (1 << 10)) == 0)
        {
            valor = raiz_get_remainder();
        }
        else
        {
            valor = raiz_get_result();
        }

        SEGMENTS_BASE_ADDRESS = valor;
        delay_(100000);
    }

    return 0;
}