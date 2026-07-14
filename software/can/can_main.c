// #include "can.h"

// int main(void) {
//     CAN_t frame;

//     /* Preenche a estrutura */
//     frame.id       = 0x0AA;               // 11 bits
//     frame.dlc      = 5;
//     frame.baud     = 0;
//     frame.rtr      = false;
//     frame.tx_start = true;
//     frame.payload[0] = 0xAA;
//     frame.payload[1] = 0xBB;
//     frame.payload[2] = 0xCC;
//     frame.payload[3] = 0xDD;
//     frame.payload[4] = 0xEE;
//     frame.payload[5] = 0x00;
//     frame.payload[6] = 0x00;
//     frame.payload[7] = 0x00;

//     /* Envia o quadro */
//     can_send_frame(&frame);

//     /* Loop infinito (o hardware continua a transmissão sozinho) */
//     while (1) {
//         /* Opcional: ler registrador de status para verificar fim da transmissão */
//     }

//     return 0;
// }
// can_main.c
// #include "../_core/hardware.h"
// #define TXB0CTRL (*(volatile unsigned char *)(CAN_BASE + 0x30*4))

// int main(void) {
	//     TXB0CTRL = 0x08;   // bit3 = 1 -> solicita transmissão
	//     while(1);
	//     return 0;
	// }
	// #define CAN_BASE (PERIPH_BASE + 32*16*4)
	// #define TXB0CTRL (*(volatile unsigned char *)(CAN_BASE + 0x30*4))

	// int main(void) {
		//     TXB0CTRL = 0x08;   // bit3 = 1 -> solicita transmissão
		//     while(1);
		//     return 0;
		// }


		#include <stdint.h>

		// Endereço base do periférico CAN (ajuste conforme seu endereçamento)
		// 0x04000000 + 28*16*4*4 = 0x04001C00
		// #define CAN_BASE       0x04001C00

		// Macro para acessar registros de 8 bits (deslocamento em words)
#define CAN_BASE 0x04000000+28*16*4*4 //0x01000640*4
#define REG8(offset)   (*(volatile uint8_t *)(CAN_BASE + (offset * 4)))

// Mapeamento dos registradores
#define TXB0CTRL       REG8(0x30)
#define TXB0SIDH       REG8(0x31)
#define TXB0SIDL       REG8(0x32)
#define TXB0DLC        REG8(0x35)
#define TXB0D0         REG8(0x36)
#define TXB0D1         REG8(0x37)
#define TXB0D2         REG8(0x38)
#define TXB0D3         REG8(0x39)
#define TXB0D4         REG8(0x3A)
#define TXB0D5         REG8(0x3B)
#define TXB0D6         REG8(0x3C)
#define TXB0D7         REG8(0x3D)
#define BAUD_REG       REG8(0xF0)

int main(void) {
    // 1. Configura o Baud Rate (prescaler = 0)
    BAUD_REG = 0x00;

    // 2. Configura o ID da mensagem (ID = 0xAA)
    TXB0SIDH = 0xAA;  // Bits 10..3 do ID
    TXB0SIDL = 0x00;  // Bits 2..0 do ID

    // 3. Configura o comprimento dos dados (DLC = 5)
    TXB0DLC  = 0x05;

    // 4. Preenche os dados
    TXB0D0   = 0xAA;
    TXB0D1   = 0xBB;
    TXB0D2   = 0xCC;
    TXB0D3   = 0xDD;
    TXB0D4   = 0xEE;

    // 5. Dispara a transmissão (bit 3 do TXB0CTRL)
    TXB0CTRL = 0x08;
	TXB0CTRL = 0x00;


    while(1);  // Fica em loop infinito
    return 0;
}