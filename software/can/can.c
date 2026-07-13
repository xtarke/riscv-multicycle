#include "can.h"
#include <stddef.h>
void can_set_id(uint16_t id) {
    REG8(TXB0SIDH) = (uint8_t)((id >> 3) & 0xFF);   /* bits [10:3] */
    REG8(TXB0SIDL) = (uint8_t)((id & 0x7) << 5);    /* bits [2:0] em [7:5] */
}

void can_set_dlc(uint8_t dlc, bool rtr) {
    uint8_t val = dlc & 0x0F;            /* bits [3:0] */
    if (rtr)
        val |= (1 << 6);                 /* bit 6 = RTR */
    REG8(TXB0DLC) = val;
}

void can_load_payload(const uint8_t *data, uint8_t len) {
    if (len > 8) len = 8;
    for (uint8_t i = 0; i < len; i++) {
        REG8(TXB0D0 + i) = data[i];
    }
}

void can_config_baud(uint8_t baud) {
    REG8(BAUD_REG) = baud;
}

void can_start_transmission(void) {
    REG8(TXB0CTRL) = (1 << 3);   /* TXREQ = 1 */
}

void can_send_frame(const CAN_t *frame) {
    if (!frame) return;

    can_set_id(frame->id);
    can_set_dlc(frame->dlc, frame->rtr);
    can_load_payload(frame->payload, frame->dlc);
    can_config_baud(frame->baud);

    if (frame->tx_start) {
        can_start_transmission();

        /*
         * Aguarda o fim da transmissão.
         * O hardware atual NÃO limpa o bit TXREQ; portanto este
         * loop é infinito e deve ser removido quando a FSM for
         * alterada para limpar o bit automaticamente.
         * Enquanto isso, o frame CAN será transmitido repetidamente
         * (o que é útil para testes).
         */
        while (REG8(TXB0CTRL) & (1 << 3));
    }
}