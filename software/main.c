/*
 * main.c
 * Teste do Periférico RNG (Random Number Generator)
 */


#include "_core/utils.h"    // Para a função delay_
#include "_core/hardware.h" // Definições de base
#include "gpio/gpio.h"      // Para usar os LEDs e Displays
#include <stdint.h>
     

// ---------------------------------------------------------
// DEFINIÇÕES DO RNG
// ---------------------------------------------------------
// Endereço Base: 0x4000640
// Como o hardware agora é somente leitura, só precisamos deste endereço.

#ifndef RNG_BASE_ADDRESS
#define RNG_BASE_ADDRESS ((uint32_t)0x4000640)
#endif

// Acesso direto para leitura
#define RNG_VAL_READ   *(&RNG_BASE_ADDRESS)

// Ajuste o delay conforme necessário (5000000 ≈ 1 segundo)
#define DELAY_TIME 100000

int main() {
    uint32_t val = 0;
    int heartbeat = 0; 

    // Liga LED 7 para indicar "Sistema Iniciado"
    OUTBUS |= (1 << 7); 

    while (1) {

        // --- A. LEITURA ---
        // Simplesmente lê o barramento. O hardware entrega o número atual.
        val = RNG_VAL_READ;

        // --- B. EXIBIÇÃO NOS DISPLAYS (Hexadecimal) ---
        SEGMENTS_BASE_ADDRESS = val;
        
        // --- C. EXIBIÇÃO NOS LEDS (Binário) ---
        // Mostra os 6 primeiros bits do número nos LEDs 1 a 6.
        // Preserva o LED 7 (Status) e LED 0 (Heartbeat).
        
        uint32_t leds = OUTBUS;     // Lê o estado atual dos LEDs
        leds &= ~0x7E;              // Apaga LEDs 1..6 (Máscara ~01111110)
        leds |= ((val & 0x3F) << 1); // Insere os 6 bits do RNG deslocados
        OUTBUS = leds;              // Escreve de volta

        // --- D. HEARTBEAT (LED 0) ---
        // Pisca para mostrar que o processador não travou
        if (heartbeat == 0) {
            OUTBUS |= (1 << 0); 
            heartbeat = 1;
        } else {
            OUTBUS &= ~(1 << 0);
            heartbeat = 0;
        }
        
        // --- E. ESPERA ---
        delay_(DELAY_TIME); 
    }
    
    return 0;
}