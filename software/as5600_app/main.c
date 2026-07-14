#include <stdint.h>
#include "../_core/hardware.h"
#include "../gpio/gpio.h"

// registradores do módulo AS5600 (slot 22)
#define AS5600_T_HIGH   (*(_IO32 *) (PERIPH_BASE + 22*16*4))
#define AS5600_T_PERIOD (*(_IO32 *) (PERIPH_BASE + 22*16*4 + 4))

int32_t prev_angle = -1;
int32_t accum_angle = 0;

uint32_t calcular_modo_display(uint32_t angle_atual, uint32_t sw0_ligado) {
    if (sw0_ligado) {
        if (prev_angle == -1) {
            prev_angle = angle_atual;
        } else {
            int32_t delta = angle_atual - prev_angle;

            if (delta < -180) delta += 360;
            else if (delta > 180) delta -= 360;

            accum_angle += delta;

            if (accum_angle > 720) accum_angle = 720;
            if (accum_angle < 0) accum_angle = 0;

            prev_angle = angle_atual;
        }

        return (accum_angle * 50) / 360;

    } else {
        prev_angle = -1;
        accum_angle = 0;
        return angle_atual;
    }
}

int main() {
    uint32_t t_high;
    uint32_t t_period;
    uint32_t angle;
    uint32_t bcd_val;

    while (1) {
        t_high   = AS5600_T_HIGH;
        t_period = AS5600_T_PERIOD;

        angle = 0;
        if (t_period > 0) {
            // Normaliza para a escala interna do AS5600 (4351 clocks por ciclo)
            uint32_t internal_high = (t_high * 4351) / t_period;

            // Os primeiros 128 clocks são offset fixo do sensor
            if (internal_high > 128) {
                uint32_t data_val = internal_high - 128;

                if (data_val > 4095)
                    data_val = 4095;

                angle = (data_val * 360) / 4095;
            }
        }

        uint32_t sw0_ligado = INBUS & 0x01;
        uint32_t valor_para_tela = calcular_modo_display(angle, sw0_ligado);

        uint32_t u = valor_para_tela % 10;
        uint32_t d = (valor_para_tela / 10) % 10;
        uint32_t c = (valor_para_tela / 100) % 10;

        if (sw0_ligado) {
            // Modo potenciômetro
            bcd_val = u;

            if (valor_para_tela >= 10) {
                bcd_val |= (d << 4);
            } else {
                bcd_val |= (0xF << 4);
            }

            if (valor_para_tela >= 100) {
                bcd_val |= (c << 8);
            } else {
                bcd_val |= (0xF << 8);
            }

            bcd_val |= 0xFFF000;
        } else {
            // Modo graus: ° no HEX0
            bcd_val = 0xA;
            bcd_val |= (u << 4);

            if (valor_para_tela >= 10) {
                bcd_val |= (d << 8);
            } else {
                bcd_val |= (0xF << 8);
            }

            if (valor_para_tela >= 100) {
                bcd_val |= (c << 12);
            } else {
                bcd_val |= (0xF << 12);
            }

            bcd_val |= 0xFF0000;
        }

        SEGMENTS_BASE_ADDRESS = bcd_val;

        for (volatile uint32_t i = 0; i < 20000; i++);
    }

    return 0;
}
