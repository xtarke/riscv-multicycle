/*----------------------------------------------------------------------
-- Name        : main.c
-- Author      : Laura Martin Werneck
-- Date        : 20/08/2024
-- Description : Implementação de um cronômetro o qual, com o uso 
--               das chaves fa FPGA, consegue: iniciar a contagem, 
--               parar a contagem, salvar dois splits (valor da
--               contagem atual) em outros displays, além de zerar o 
--               contador e também apagar o valor de todos os displays.
------------------------------------------------------------------------*/

#include "utils.h"
#include "hardware.h"
#include "timer.h"
#include "interrupt.h"
#include "gpio.h"


volatile uint32_t seconds_1 = 0;       // Contador do display 1
volatile uint32_t seconds_2 = 0;       // Contador do display 2
volatile uint8_t  counting = 0;        // Flag para verificar se está contando ou parado
volatile uint8_t  split_count = 0;     // Contador dos splits
volatile uint32_t split_time_1 = 00;   // Primeiro split
volatile uint32_t split_time_2 = 00;   // Segundo split


// Interrupção responsável pelo funcionamento do cronômetro
void TIMER0_0A_IRQHandler(void)
{
    // Verifica se a chave 1 foi ativada, se sim inicia a contagem
    if (INBUS & 0x01) {
        counting = 1;           
    }

    // Verifica se a chave 1 foi desativada, se sim para a contagem
    if (!(INBUS & 0x01)) {
        counting = 0;          
    }

    // Verifica se a chave 2 foi ativada, se sim zera a contagem do display 1 e 2
    if (INBUS & 0x02) {
        seconds_1 = 0;          
        seconds_2 = 0;
    }

    // Verifica se a chave 3 foi ativada e se split_count é zero, ou seja, que 
    // ainda não foi feito um split, se sim salva o tempo no split_time_1
    if (INBUS & 0x04 && split_count == 0) {
        // Primeiro split salva o tempo nos displays 3 e 4
        split_time_1 = ((seconds_2 & 0xF) << 4) | (seconds_1 & 0xF);
        split_count++;
    }

    // Verifica se a chave 4 foi ativada e se split_count é 1, ou seja, que 
    // que já foi feito somente um split, se sim salva o tempo no split_time_2
    if (INBUS & 0x08 && split_count == 1) {
        // Primeiro split salva o tempo nos displays 3 e 4
        split_time_2 = ((seconds_2 & 0xF) << 4) | (seconds_1 & 0xF);
        split_count++;
    }

    // Verifica se a chave 4 está ativada, se sim limpa todos os displays
    if (INBUS & 0x10) {
        seconds_1 = 0;          
        seconds_2 = 0; 
        split_time_1 = 0;
        split_time_2 = 0;    
        split_count = 0;    
    }

    // Lógica do contador do cronômetro
    if (counting) {
        // Se passou de 9 segundos, incrementa o próximo display, 
        // o segundo display, dessa forma, conta em decimal
        if (seconds_1 == 9) {  
            seconds_1 = 0;
            seconds_2++;
        }
        else{
            seconds_1++;
        }
    }

    // Monta o valor final de SEGMENTS com todos os displays
    SEGMENTS = (split_time_2 << 16) | (split_time_1 << 8) | ((seconds_2 & 0xF) << 4) | (seconds_1 & 0xF);


}


void init_timer0(void)
{
    uint32_t events;

    TIMER_0->timer_reset = 1;

    TIMER_0->timer_mode = 1;
    TIMER_0->prescaler = 1000;   // Reduz a frequência de 1MHz para 1KHz
    TIMER_0->top_counter = 1000; // Conta até 1000, o que faz ser 1s

    TIMER_0->compare_0A = 100;
    TIMER_0->compare_0B = 600;
    TIMER_0->compare_1A = 10;
    TIMER_0->compare_1B = 10;
    TIMER_0->compare_2A = 10;
    TIMER_0->compare_2B = 10;
    TIMER_0->enable_irq = 1;
    TIMER_0->timer_reset = 0;
}

int main(){
	volatile uint32_t data = 0;
	
	init_timer0();

	timer_interrupt_enable(true);
	global_interrupt_enable(true);

	while (1){
        	data++;
        }

	return 0;
}





