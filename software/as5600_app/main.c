/*
 * main.c - Aplicação AS5600 PWM -> Display 7 Segmentos
 *
 * Lê o sinal PWM do sensor magnético AS5600,
 * calcula o ângulo de rotação (0 a 360 graus)
 * e exibe o resultado nos displays de 7 segmentos da DE10-Lite.
 *
 * Endereçamento segue o padrão do projeto:
 *   PERIPH_BASE + slot * 16 * 4  (cada slot = 16 words = 64 bytes)
 */

#include <stdint.h>
#include "../_core/hardware.h"
#include "../gpio/gpio.h"

/* AS5600 PWM Input - Slot 22 do iodatabusmux (x"0016")
 * MY_WORD_ADDRESS no VHDL = x"0160"
 * Byte offset = 22 * 16 * 4 = 0x580
 * Offset +0 = t_high,  Offset +1 word (+4 bytes) = t_period */
#define AS5600_T_HIGH   (*(_IO32 *) (PERIPH_BASE + 22*16*4))
#define AS5600_T_PERIOD (*(_IO32 *) (PERIPH_BASE + 22*16*4 + 4))

int main() {
    uint32_t t_high;
    uint32_t t_period;
    uint32_t angle;
    uint32_t bcd_val;
    uint32_t temp_angle;

while (1) {
    t_period = AS5600_T_PERIOD;
    SEGMENTS_BASE_ADDRESS = t_period;   // mostra o valor em hexadecimal
}

    return 0;
}
