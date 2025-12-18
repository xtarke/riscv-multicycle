#include <stdint.h>
#include "hardware.h"
#include "gpio.h"
#include "utils.h"

/* ================= CONFIGURAÇÃO ================= */
#define PASSWORD_D1 3
#define PASSWORD_D2 5
#define MAX_TRIES   3

/* LEDs */
#define LED_OK   (1 << 5)
#define LED_ERR  (1 << 6)

/* Switches */
#define ENTER_SW (1 << 4)
#define RESET_SW (1 << 7)

int main(void) {
    int tries = MAX_TRIES;
    int locked = 0;
    int enter_armed = 1;

    int digit_index = 0;
    int input_d1 = 0;
    int input_d2 = 0;

    OUTBUS = 0;
    HEX0 = tries;   /* Mostra tentativas */

    while (1) {
        uint32_t sw = INBUS & 0xFF;

        int digit = sw & 0x0F;
        int enter = sw & ENTER_SW;
        int reset = sw & RESET_SW;

        uint32_t leds_base = digit;

        /* ===== RESET ===== */
        if (reset) {
            tries = MAX_TRIES;
            locked = 0;
            digit_index = 0;
            enter_armed = 1;

            HEX0 = tries;
            OUTBUS = leds_base;

            delay_(300);
            continue;
        }

        /* ===== BLOQUEADO ===== */
        if (locked) {
            OUTBUS = leds_base | LED_ERR;
            delay_(1000);
            continue;
        }

        /* ===== ENTER ===== */
        if (enter && enter_armed) {
            enter_armed = 0;

            if (digit_index == 0) {
                input_d1 = digit;
                digit_index = 1;
            } else {
                input_d2 = digit;

                if (input_d1 == PASSWORD_D1 &&
                    input_d2 == PASSWORD_D2) {

                    /* ACERTO */
                    tries = MAX_TRIES;
                    HEX0 = tries;
                    OUTBUS = leds_base | LED_OK;
                } else {
                    /* ERRO */
                    tries--;
                    HEX0 = tries;
                    OUTBUS = leds_base | LED_ERR;

                    if (tries == 0)
                        locked = 1;
                }

                digit_index = 0;
                delay_(3000);
            }
        }

        /* ===== Libera ENTER ===== */
        if (!enter)
            enter_armed = 1;

        /* Estado normal */
        if (!locked && !enter)
            OUTBUS = leds_base;

        delay_(20);
    }

    return 0;
}
