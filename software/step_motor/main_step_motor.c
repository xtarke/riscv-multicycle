#include <stdint.h>
#include "step_motor.h"

// Arquivo principal para criar funcionalidade do periférico step_motor
// Teste seguindo passos: 
// Iniciar motor com velocidade x, rotação em sentido anti-horário e full step (A-B-C-D-A)
// Alterar step para half step (A-AB-B-BC-C-CD-D-DA-A)
// Alterar sentido da rotação para sentido horário
// Para motor
// Refazer em looping

int main() {
            
    while(1) {
        reset_motor(1); // Resetar motor
    
        reset_motor(0); // Baixar nivel do reset para iniciar teste
        change_speed(2); // Iniciar velocidade em 2 (pode ser outro valor de 0 a 7, pois componente recebe 3 bits)
        change_step(1); // Iniciar passo em fullstep (A-B-C-D-A)
        stop_motor(0); // Iniciar motor
        reverse_rotation(0); // Iniciar motor com rotação no sentido anti-horário
        delay_(500000); // Delay de tempo suficiente para visualizar em hardware situação atual
        
        change_step(0); // Alterar passo para half step (A-AB-B-BC-C-CD-D-DA-A)
        delay_(500000); // Delay de tempo suficiente para visualizar em hardware situação atual

        reverse_rotation(1); // Alterar sentido da rotação para sentido horário
        delay_(500000); // Delay de tempo suficiente para visualizar em hardware situação atual
        
        stop_motor(1); // Parar motor
        delay_(500000); // Delay de tempo suficiente para visualizar em hardware situação atual
    }
    return 0;
}
