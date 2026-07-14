/*
 * main.c - Aplicação AS5600 PWM -> Display 7 Segmentos
 *
 * Lê o sinal PWM do sensor magnético AS5600,
 * calcula o ângulo de rotação (0 a 360 graus)
 * e exibe o resultado nos displays de 7 segmentos da DE10-Lite.
 *
 * Conforme datasheet do AS5600 (seção PWM Output):
 *   - Período total do frame   = 4351 clocks internos
 *   - Cabeçalho fixo em HIGH   = 128  clocks internos
 *   - Dados úteis (ângulo)     = 0 a 4095 (12 bits)
 *   - Rodapé fixo em LOW       = 128  clocks internos
 *
 *   Fórmula: DATA = (t_high * 4351 / t_period) - 128
 *            Ângulo = DATA * 360 / 4095
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

    while (1) {
        /* 1. Ler as medições do periférico */
        t_high   = AS5600_T_HIGH;
        t_period = AS5600_T_PERIOD;

        /* 2. Calcular o ângulo conforme datasheet
         *
         * Com clock de 1 MHz e PWM a ~115 Hz:
         *   t_period ≈ 8696,  t_high máx ≈ 8696
         *   t_high * 4351 máx ≈ 37.8 milhões (cabe em 32 bits)
         */
        angle = 0;
        if (t_period > 0) {
            /* Converter proporção medida para clocks internos do AS5600 */
            uint32_t internal_high = (t_high * 4351) / t_period;

            /* Subtrair cabeçalho fixo de 128 clocks */
            if (internal_high > 128) {
                uint32_t data_val = internal_high - 128;

                /* Limitar ao máximo de 12 bits */
                if (data_val > 4095)
                    data_val = 4095;

                /* Converter para graus: 0-4095 -> 0-360 */
                angle = (data_val * 360) / 4095;
            }
        }

        /* 3. Converter ângulo para BCD e enviar ao display
         *
         * led_displays decodifica cada nibble (4 bits) como um dígito.
         * Valores 0x0-0x9 mostram o dígito, 0xF apaga o display.
         * HEX0 = unidade, HEX1 = dezena, HEX2 = centena
         * HEX3-HEX5 = apagados
         */
        bcd_val  = (angle % 10);              /* HEX0: unidade */
        bcd_val |= ((angle / 10) % 10) << 4;  /* HEX1: dezena  */
        bcd_val |= ((angle / 100) % 10) << 8; /* HEX2: centena */
        bcd_val |= 0xFFF000;                  /* HEX3-5: apagados */

        SEGMENTS_BASE_ADDRESS = bcd_val;

        /* Pequeno atraso para estabilidade visual */
        for (volatile uint32_t d = 0; d < 50000; d++);
    }

    return 0;
}
