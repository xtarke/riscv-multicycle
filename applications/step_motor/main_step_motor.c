#include <stdint.h>
#include "step_motor.h"

// Arquivo principal para criar funcionalidade do periférico step_motor
// Teste seguindo passos: 
// Iniciar motor com velocidade x, rotação em sentido anti-horário e full step (A-B-C-D-A)
// Alterar step para half step (A-AB-B-BC-C-CD-D-DA-A)
// Alterar sentido da rotação para sentido horário
// Para motor
// Refazer em looping


//DO RE MI FA SOL LA SI DO
// 0  1  2  3  4   5  6  7
//
//LA-LA-LA-FA-DO-LA-FA-DO-LA
//MI-MI-MI-FA-DO-SOL#-FA-DO-LA
//LA-LA-LA-LA-SOL#-SOL-FA#-FA-FA#
//LA-RE#-RE-DO#-DO-SI-DO
//FA-SOL#-FA-SOL#-DO-SOL#-DO-MI
//LA-LA-LA-LA-SOL#-SOL-FA#-FA-FA#
//LA-RE#-RE-DO#-DO-SI-DO
//FA-SOL#-FA-DO-LA-FA-DO-LA

/*
DO-RE-MI-FA-FA-FA
DO-RE-DO-RE-RE-RE
DO-SOL-FA-MI-MI-MI
DO-RE-MI-FA-FA-FA

DO-FA-MI-RE-DO-RE
RE-RE-DO-RE-MI-FA
DO-FA-MI-RE-DO-RE
RE-RE-DO-RE-MI-FA
*/
//DO RE MI FA SOL LA SI DO
// 0  1  2  3  4   5  6  7

void t_tocar_nota(int velocidade, int t_nota, int t_pausa) {
    change_speed(velocidade);
    stop_motor(0);
    delay_(t_nota);
    stop_motor(1);
    delay_(t_pausa);
}

void tocar_nota(int velocidade) {
    change_speed(velocidade);
    stop_motor(0);
    delay_(100000);
    stop_motor(1);
    delay_(1000);
}



int main() {
            
    while(1) {
        reset_motor(1); // Resetar motor


        reset_motor(0); // Iniciar motor
        change_step(1); // Full step
        reverse_rotation(0); // Sentido anti-horário


        t_tocar_nota(0,100000,500); // 
        t_tocar_nota(1,100000,500); // 
        t_tocar_nota(2,100000,500); // 
        t_tocar_nota(3,100000,500); // 
        t_tocar_nota(3,100000,500); // 
        t_tocar_nota(3,100000,500); // 
        t_tocar_nota(0,100000,500); // 
        t_tocar_nota(1,100000,500); // 
        t_tocar_nota(0,100000,500); // 
        t_tocar_nota(1,100000,500); // 
        t_tocar_nota(1,100000,500); // 
        t_tocar_nota(1,100000,500); //
        t_tocar_nota(0,100000,500); // 
        t_tocar_nota(4,100000,500); // 
        t_tocar_nota(3,100000,500); // 
        t_tocar_nota(2,100000,500); // 
        t_tocar_nota(2,100000,500); // 
        t_tocar_nota(2,100000,500); // 
        t_tocar_nota(0,100000,500); // 
        t_tocar_nota(1,100000,500); // 
        t_tocar_nota(2,100000,500); // 
        t_tocar_nota(3,100000,500); // 
        t_tocar_nota(3,100000,500); // 
        t_tocar_nota(3,100000,500); //
        t_tocar_nota(0,100000,500); // 
        t_tocar_nota(3,100000,500); // 
        t_tocar_nota(2,100000,500); // 
        t_tocar_nota(1,100000,500); // 
        t_tocar_nota(0,100000,500); // 
        t_tocar_nota(1,100000,500); // 
        t_tocar_nota(1,100000,500); // 
        t_tocar_nota(1,100000,500); // 
        t_tocar_nota(0,100000,500); // 
        t_tocar_nota(1,100000,500); // 
        t_tocar_nota(2,100000,500); // 
        t_tocar_nota(3,100000,500); //
        t_tocar_nota(0,100000,500); // 
        t_tocar_nota(3,100000,500); // 
        t_tocar_nota(2,100000,500); // 
        t_tocar_nota(1,100000,500); // 
        t_tocar_nota(0,100000,500); // 
        t_tocar_nota(1,100000,500); // 
        t_tocar_nota(1,100000,500); // 
        t_tocar_nota(1,100000,500); // 
        t_tocar_nota(0,100000,500); // 
        t_tocar_nota(1,100000,500); // 
        t_tocar_nota(2,100000,500); // 
        t_tocar_nota(3,100000,500); // 

        delay_(1000000);

        //Marcha imperial
        // Primeira linha: LA-LA-LA-FA-DO-LA-FA-DO-LA
        t_tocar_nota(5,120000,1000); // LA
        t_tocar_nota(5,120000,1000); // LA
        t_tocar_nota(5,120000,2000); // LA
        t_tocar_nota(3,100000,2000); // FA
        t_tocar_nota(0,50000,500); // DO
        t_tocar_nota(5,100000,2000); // LA
        t_tocar_nota(3,100000,2000); // FA
        t_tocar_nota(0,50000,500); // DO
        t_tocar_nota(5,100000,2000); // LA

        // Segunda linha: MI-MI-MI-FA-DO-SOL#-FA-DO-LA
        t_tocar_nota(2,120000,1000); // MI
        t_tocar_nota(2,120000,1000); // MI
        t_tocar_nota(2,120000,2000); // MI
        t_tocar_nota(3,100000,2000); // FA
        t_tocar_nota(0,50000,500); // DO
        t_tocar_nota(4,100000,2000); // SOL#
        t_tocar_nota(3,100000,2000); // FA
        t_tocar_nota(0,50000,500); // DO
        t_tocar_nota(5,100000,2000); // LA


    }
    return 0;
}
