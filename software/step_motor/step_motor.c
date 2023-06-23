#include "step_motor.h"
#include <stdint.h>

// Arquivo para criar funções do periférico step_motor

// Função para resetar motor, pode retornar 1 (resetado) ou 0 (não resetado)
void reset_motor(uint8_t val) {
    STEP_BASE->rst = val;
}

// Função para parar motor, pode retornar 1 (parado) ou 0 (andando)
void stop_motor(uint8_t val) {
    STEP_BASE->stop = val;
}

// Função para alterar sentido da rotação do motor, pode retornar 1 (horário) ou 0 (anti-horário)
void reverse_rotation(uint8_t val) {
    STEP_BASE->reverse = val;
}

// Função para alterar step do motor, pode retornar 1 (fullstep) ou 0 (half step)
void change_step(uint8_t val) {
    STEP_BASE->half_full = val;
}

// Função para alterar velocidade do motor, podendo retornar valor de 0 a 7, pois componente recebe 3 bits
void change_speed(uint8_t val) {
    STEP_BASE->speed = val;
}

