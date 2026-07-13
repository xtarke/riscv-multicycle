#ifndef CAN_H
#define CAN_H

#include <stdint.h>
#include <stdbool.h>
#include "../_core/hardware.h"



#define CAN_BASE_BYTE   (0x04000000 + 25*64*4)
// Macro para acessar um registrador do CAN.
// O offset é o número do registrador (0x30, 0x31, ...)
#define REG8(offset)    (*(volatile uint8_t *)(CAN_BASE_BYTE + (offset)))
// Registradores
#define TXB0CTRL   REG8(0x30)
#define TXB0SIDH   REG8(0x31)
#define TXB0SIDL   REG8(0x32)
#define TXB0DLC    REG8(0x35)
#define TXB0D0     REG8(0x36)
#define TXB0D1     REG8(0x37)
#define TXB0D2     REG8(0x38)
#define TXB0D3     REG8(0x39)
#define TXB0D4     REG8(0x3A)
#define TXB0D5     REG8(0x3B)
#define TXB0D6     REG8(0x3C)
#define TXB0D7     REG8(0x3D)
#define BAUD_REG   REG8(0xF0)

/* Estrutura de um quadro CAN */
typedef struct {
    uint16_t id : 11;          /* Identificador de 11 bits */
    uint8_t  dlc : 4;          /* Data Length Code (0..8) */
    uint8_t  baud;             /* Valor do prescaler (BAUD_REG) */
    bool     tx_start;         /* Solicita transmissão (TXB0CTRL(3)) */
    bool     rtr;              /* Remote Transmission Request */
    uint8_t  payload[8];       /* Dados (até 8 bytes) */
} CAN_t;

/* Funções de baixo nível */
void can_set_id(uint16_t id);
void can_set_dlc(uint8_t dlc, bool rtr);
void can_load_payload(const uint8_t *data, uint8_t len);
void can_config_baud(uint8_t baud);
void can_start_transmission(void);

/* Função de alto nível */
void can_send_frame(const CAN_t *frame);

#endif