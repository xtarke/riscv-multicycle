#include "can.h"
#include "../_core/utils.h"

int main(void)
{
    /* Preenche uma estrutura CAN_t com os dados do quadro */
    CAN_t frame;

    frame.id       = 0x2AA;     /* 11 bits */
    frame.dlc      = 5;         /* 5 bytes de dados */
    frame.baud     = 0;         /* prescaler = 0 (sem divisão) */
    frame.rtr      = false;     /* data frame, não remote */
    frame.tx_start = true;      /* transmite imediatamente */

    frame.payload[0] = 0xAA;
    frame.payload[1] = 0xBB;
    frame.payload[2] = 0xCC;
    frame.payload[3] = 0xDD;
    frame.payload[4] = 0xEE;
    /* bytes 5..7 não são usados (DLC=5) */


    /* Loop infinito para analisar a comunicação*/
	// pode se checar se frame.tx_start foi limpo ou se tx_done foi para 1
    while (1){
		/* Envia o quadro */
		can_send_frame(&frame);
		delay_(100);
	}
    return 0;
}
// int main(void) {
//     // 1. Configura o Baud Rate (prescaler = 0)
//     BAUD_REG = 0x00;

//     // 2. Configura o ID da mensagem (ID = 0xAA)
//     TXB0SIDH = 0xAA;  // Bits 10..3 do ID
//     TXB0SIDL = 0x00;  // Bits 2..0 do ID

//     // 3. Configura o comprimento dos dados (DLC = 5)
//     TXB0DLC  = 0x05;

//     // 4. Preenche os dados
//     TXB0D0   = 0xAA;
//     TXB0D1   = 0xBB;
//     TXB0D2   = 0xCC;
//     TXB0D3   = 0xDD;
//     TXB0D4   = 0xEE;

//     // 5. Dispara a transmissão (bit 3 do TXB0CTRL)
//     TXB0CTRL = 0x08;



//     while(1);  // Fica em loop infinito
//     return 0;
// }