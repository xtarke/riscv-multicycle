// Codigo para teste de pseudo random number generator
// Aluna: Elisa Anes Romero
// Dispositivos logicos programaveis - IFSC

#include "_core/utils.h"    // Para a função delay_
#include "_core/hardware.h" // Definições de base
#include "gpio/gpio.h"      // Para usar os LEDs e Displays
#include <stdint.h>
     
#define DELAY_TIME 100000

int main() {

    int heartbeat = 0; 

    // Liga LED 7 para indicar "Sistema Iniciado"
    OUTBUS |= (1 << 7); 

    while (1) {

        //EXIBIÇÃO NOS DISPLAYS (Hexadecimal)
        SEGMENTS_BASE_ADDRESS = RNG_BASE_ADDRESS;

        //HEARTBEAT (LED 0) 
        // Pisca para mostrar que o processador não travou
        if (heartbeat == 0) {
            OUTBUS |= (1 << 0); 
            heartbeat = 1;
        } else {
            OUTBUS &= ~(1 << 0);
            heartbeat = 0;
        }
        
        //ESPERA
        delay_(DELAY_TIME); 
    }
    
    return 0;
}