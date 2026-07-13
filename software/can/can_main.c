#include "../_core/hardware.h"

/* Redefine a base do CAN para o valor numérico correto (byte address) */
#undef CAN_BASE_ADDRESS
#define CAN_BASE_ADDRESS  0x04000640

/* Macro de acesso byte‑a‑byte */
#define REG8(offset) (*(volatile uint8_t *)(CAN_BASE_ADDRESS + 4*(offset)))

/* Registradores */
#define TXB0CTRL   REG8(0x30)
#define TXB0SIDH   REG8(0x31)
#define TXB0SIDL   REG8(0x32)
#define TXB0DLC    REG8(0x35)
#define TXB0D0     REG8(0x36)
#define TXB0D1     REG8(0x37)
#define TXB0D2     REG8(0x38)
#define TXB0D3     REG8(0x39)
#define TXB0D4     REG8(0x3A)
#define BAUD_REG   REG8(0xF0)

/* Função auxiliar: envia um quadro e aguarda a transmissão terminar */
void send_can_frame(uint16_t id, uint8_t dlc, uint8_t *data) {
    /* Configura o ID */
    TXB0SIDH = (id >> 3) & 0xFF;
    TXB0SIDL = (id & 0x07) << 5;

    /* Configura DLC (sem RTR) */
    TXB0DLC = dlc & 0x0F;

    /* Carrega os dados (apenas os bytes indicados por dlc) */
    for (int i = 0; i < dlc && i < 8; i++) {
        REG8(0x36 + i) = data[i];   // TXB0D0 + i
    }

    /* Baud rate fixo (prescaler = 0) */
    BAUD_REG = 0;

    /* Dispara a transmissão */
    TXB0CTRL = (1 << 3);   // TXREQ = 1

    /*
     * Aguarda o fim da transmissão.
     * Este loop será desnecessário quando o hardware limpar TXREQ.
     * Por enquanto, apenas espera o bit voltar a 0 (nunca acontece),
     * mas a FSM inicia a transmissão imediatamente e o frame sai.
     * O loop será interrompido apenas na próxima escrita em TXB0CTRL.
     */
    while (TXB0CTRL & (1 << 3));
}

int main(void) {
    uint8_t payload1[] = {0xAA, 0xBB, 0xCC, 0xDD, 0xEE};
    uint8_t payload2[] = {0x11, 0x22, 0x33};
    uint8_t payload3[] = {0xDE, 0xAD, 0xBE, 0xEF};

    /* Loop infinito: transmite três quadros diferentes em sequência */
    while (1) {
        send_can_frame(0x2AA, 5, payload1);   // Frame 1
        send_can_frame(0x123, 3, payload2);   // Frame 2
        send_can_frame(0x7FF, 4, payload3);   // Frame 3
    }

    return 0;
}
// can_main.c
// #define CAN_BASE 0x04000640
// #define TXB0CTRL (*(volatile unsigned char *)(CAN_BASE + 0x30))

// int main(void) {
//     TXB0CTRL = 0x08;   // bit3 = 1 -> solicita transmissão
//     while(1);
//     return 0;
// }