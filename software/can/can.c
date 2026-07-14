#include "can.h"

/* Escreve o identificador de 11 bits nos registos TXB0SIDH e TXB0SIDL */
void can_set_id(uint16_t id)
{
    TXB0SIDH = (uint8_t)((id >> 3) & 0xFF);   /* bits [10:3] */
    TXB0SIDL = (uint8_t)((id & 0x7) << 5);    /* bits [2:0] em [7:5] */
}

/* Configura o DLC e o bit RTR */
void can_set_dlc(uint8_t dlc, bool rtr)
{
    uint8_t val = dlc & 0x0F;          /* bits [3:0] */
    if (rtr)
        val |= (1 << 6);               /* bit 6 = RTR */
    TXB0DLC = val;
}

/* Carrega os bytes de dados no buffer de transmissão (TXB0D0 .. TXB0D7) */
void can_load_payload(const uint8_t *data, uint8_t len)
{
    if (len > 8) len = 8;
    for (uint8_t i = 0; i < len; i++) {
        REG8(0x36 + i) = data[i];      /* TXB0D0 + i */
    }
}

/* Define o prescaler do baud rate */
void can_config_baud(uint8_t baud)
{
    BAUD_REG = baud;
}

/* Activa o pedido de transmissão (TXREQ = bit 3) */
void can_start_transmission(void)
{
    TXB0CTRL = (1 << 3);   /* TXREQ = 1 */
}

/* Preenche todos os registos e dispara a transmissão */
void can_send_frame(const CAN_t *frame)
{
    if (!frame) return;

    can_set_id(frame->id);
    can_set_dlc(frame->dlc, frame->rtr);
    can_load_payload(frame->payload, frame->dlc);
    can_config_baud(frame->baud);

    if (frame->tx_start) {
        can_start_transmission();
    }
}