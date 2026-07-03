/*
 * main_sv_pwm.c
 *
 *  Exemplo de uso do periférico Space Vector PWM.
 *  Instituto Federal de Santa Catarina
 *
 * Funcionamento:
 *   - Inicializa o SVPWM com v_bar = 100 V e f_sw = 10 kHz.
 *   - Loop principal altera u_cmd entre +60 V e -60 V com base
 *     nos switches SW da placa (INBUS).
 *   - Exibe u_cmd atual nos displays de 7 segmentos.
 */

#include "../_core/hardware.h"
#include "../_core/utils.h"
#include "../gpio/gpio.h"
#include "sv_pwm.h"

#define VBUS_DEFAULT   100   /* Tensão do barramento DC [V]    */
#define FSW_DEFAULT    10000 /* Frequência de chaveamento [Hz] */

int main(void) {

    /* Configura tensão do barramento e frequência de chaveamento */
    sv_pwm_set_vbus(VBUS_DEFAULT);
    sv_pwm_set_fsw(FSW_DEFAULT);

    /* Começa com saída nula */
    sv_pwm_set_vcmd(0);

    sv_pwm_set_vcmd(60);
    SEGMENTS_BASE_ADDRESS = 2; //(uint32_t) sv_pwm_get_vcmd();
    while (1) {

        // if (INBUS & 0x1) {
            /* SW0 ligado: tensão positiva (+60 V) — caminho S1/S4 */
        // sv_pwm_set_vcmd(60);
        // } else if (INBUS & 0x2) {
        //     /* SW1 ligado: tensão negativa (-60 V) — caminho S2/S3 */
        //     sv_pwm_set_vcmd(-60);
        // } else {
        //     /* Nenhum switch: saída nula */
        //     sv_pwm_set_vcmd(0);
        // }

        /* Exibe u_cmd nos displays (cast para uint32 para o display) */
        // SEGMENTS_BASE_ADDRESS = (uint32_t) sv_pwm_get_vcmd();

        /* Delay para debounce dos switches.
         * Comentar para rodar no testbench. */
        // delay_(5000);
    }

    return 0;
}
