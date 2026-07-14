/*
 * main.c - Leitura do sensor AS5600 PWM e display de 7 segmentos
 */

#include <stdint.h>
#include "../_core/hardware.h"
#include "../gpio/gpio.h"

// Definições de endereço para o periférico AS5600 (Slot 22)
#define AS5600_T_HIGH   (*(_IO32 *) (PERIPH_BASE + 22*16*4))
#define AS5600_T_PERIOD (*(_IO32 *) (PERIPH_BASE + 22*16*4 + 4))

int main() {
    uint32_t t_high;
    uint32_t t_period;
    uint32_t angle;
    uint32_t bcd_val;

    while (1) {
        // Leitura do sensor
        t_high   = AS5600_T_HIGH;
        t_period = AS5600_T_PERIOD;

        // Cálculo do ângulo
        angle = 0;
        if (t_period > 0) {
            // Converte proporção medida para clocks do sensor
            uint32_t internal_high = (t_high * 4351) / t_period;

            // Remove o offset de 128 do cabeçalho
            if (internal_high > 128) {
                uint32_t data_val = internal_high - 128;

                // Limita ao máximo (12 bits)
                if (data_val > 4095)
                    data_val = 4095;

                // Converte para graus (0 a 360)
                angle = (data_val * 360) / 4095;
            }
        }

        // Formatação para exibir o ângulo e o símbolo de grau (HEX0: °, HEX1: uni, HEX2: dez, HEX3: cent)
        uint32_t u = angle % 10;
        uint32_t d = (angle / 10) % 10;
        uint32_t c = (angle / 100) % 10;

        bcd_val = 0xA;              // HEX0: símbolo de grau (°)
        bcd_val |= (u << 4);        // HEX1: unidade

        // Dezena (apaga se ângulo < 10)
        if (angle >= 10) {
            bcd_val |= (d << 8);
        } else {
            bcd_val |= (0xF << 8);
        }

        // Centena (apaga se ângulo < 100)
        if (angle >= 100) {
            bcd_val |= (c << 12);
        } else {
            bcd_val |= (0xF << 12);
        }

        bcd_val |= 0xFF0000;        // HEX4-HEX5: apagados

        SEGMENTS_BASE_ADDRESS = bcd_val;

        // Delay para estabilização visual
        for (volatile uint32_t d = 0; d < 25000; d++);
    }

    return 0;
}
