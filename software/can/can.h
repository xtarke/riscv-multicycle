#ifndef CAN_H
#define CAN_H

#include <stdio.h>

/*----- Definição dos endereçoes dos registradores -----*/

// ID de 11 bits do can frame
#define TXB0SIDH  ((uint8_t)0x31)
#define TXB0SIDL  ((uint8_t)0x32)

// Data length do can frame 
#define TXB0DLC   ((uint8_t)0x35)

// Payload do can frame
#define TXB0D0    ((uint8_t)0x36)
#define TXB0D1    ((uint8_t)0x37)
#define TXB0D2    ((uint8_t)0x38)
#define TXB0D3    ((uint8_t)0x39)
#define TXB0D4    ((uint8_t)0x3A)
#define TXB0D5    ((uint8_t)0x3B)
#define TXB0D6    ((uint8_t)0x3C)
#define TXB0D7    ((uint8_t)0x4D)

// Configuração do baudrate de transmissão
#define BAUD_REG ((uint8_t)0xF0)	// Abstração dos registradores CNFn

// Configuração da transmissão
#define TXB0CTRL ((uint8_t)0x30)

/* ---------------------------------------------------- */

typedef struct {
    uint16_t id	: 11;		// Id do can frame (TXB0SIDH & TXB0SIDL)
	uint8_t  dlc : 4;		// Tamanho do pacote (Máximo = 8) (TXB0DLC)
	uint8_t  baud;			// Age no preescaler (BAUD_REG) 
	bool     tx_start		// Solicita início da transmissão (TXB0CTRL(3))
	bool	 rtr;			// (Remote Transmission Request) 1 bit indicating if the frame is a data frame (0) or remote frame (1)
    uint8_t  payload[8]; 	// "Carga útil" do can frame (TXB0Dn)
} CAN_t;


void reset(CAN_t *dev);
/*
seta reg_wr_en = 0;
seta rst = 1;		// Qualquer transmissão é imediatamente interrompida
seta rst = 0;
*/


void set_id(CAN_t *dev);
/*
seta reg_wr_en = 0;
seta bus_addr = TXB0SIDH;
seta bus_data = dev->id // 8 primeiros MSB
seta reg_wr_en = 1;

//espera exatamente 1 ciclo de clock que vai para o periférico conforme mostra testbech.tb

seta bus_data = dev->id // TXB0SIDL[7:5] bits MSB do registrador são vazios

//espera exatamente 1 ciclo de clock que vai para o periférico

seta reg_wr_en = 0;
*/


void set_dlc(CAN_t *dev);
/*
seta reg_wr_en = 0;
seta bus_addr = TXB0DLC;
seta bus_data = dev->dlc || dev->rtr (bit 6 do reg) 
seta reg_wr_en = 1;

//espera exatamente 1 ciclo de clock que vai para o periférico conforme mostra testbech.tb

seta reg_wr_en = 0;
*/


void stuff_buffer(CAN_t *dev);
/*
seta reg_wr_en = 0;
seta bus_addr = TXB0D0;

LOOP tamanho de dev->dlc
	seta bus_data = dev->payload[i]
	seta reg_wr_en = 1;
//espera exatamente 1 ciclo de clock que vai para o periférico conforme mostra testbech.tb
FIM LOOP

seta reg_wr_en = 0;
*/


void config_baud(CAN_t *dev);
/*
seta reg_wr_en = 0;
seta bus_addr = BAUD_REG;
seta bus_data = dev->baud;
seta reg_wr_en = 1;

//espera exatamente 1 ciclo de clock que vai para o periférico conforme mostra testbech.tb

seta reg_wr_en = 0;
*/


void set_tx(CAN_t *dev);
/*
seta reg_wr_en = 0;
seta bus_addr = TXB0CTRL;
seta bus_data = dev->tx_start; // bit 3 do reg
seta reg_wr_en = 1;

//espera exatamente 1 ciclo de clock que vai para o periférico conforme mostra testbech.tb

seta reg_wr_en = 0;
*/


#endif