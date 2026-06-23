#include <stdint.h>
#include "../_core/hardware.h" 

// Endereços Base conforme definidos nos generics MY_WORD_ADDRESS do VHDL
#define AS5600_PWM_ADDR    (*(_IO32 *) (PERIPH_BASE + 0x01A0))
#define AS5600_PERIOD_ADDR (*(_IO32 *) (PERIPH_BASE + 0x01A4))

#define DISPLAY_7SEG_ADDR  (*(_IO32 *) (PERIPH_BASE + 0x01B0))

int main() {
    uint32_t t_high;
    uint32_t t_period;
    uint32_t angle;
    uint32_t bcd_val;
    uint32_t temp_angle;
    
    while (1) {
        // 1. Ler as medições de tempo do periférico de hardware
        t_high = AS5600_PWM_ADDR;
        t_period = AS5600_PERIOD_ADDR;
        
        // 2. Calcular o Ângulo baseado no Duty Cycle
        if (t_period > 0) {
            // O Duty Cycle (t_high / t_period) mapeia linearmente de 0 a 360 graus.
            angle = (t_high * 360) / t_period;
            
            // Tratamento de segurança (limita ao valor máximo do AS5600)
            if (angle > 360) {
                angle = 360;
            }
        } else {
            angle = 0;
        }

        // 3. Converter o ângulo para BCD para o display de 7 segmentos
        // O hardware espera um registrador de 24-bits com 6 nibbles (4-bits)
        // Cada nibble representa um dígito do display. O valor 0xA apaga o display.
        bcd_val = 0;
        temp_angle = angle;
        
        for(int i = 0; i < 6; i++) {
            if (i > 0 && temp_angle == 0) {
                // Se não há mais dígitos a serem exibidos (e não for a unidade), apaga (blank) = 0xA
                // Exemplo: O ângulo "45" exibirá apenas [ 4] [ 5], e o resto ficará apagado.
                bcd_val |= (0xA << (i * 4)); 
            } else {
                // Pega o dígito mais a direita (módulo 10) e coloca na posição do nibble correto
                bcd_val |= ((temp_angle % 10) << (i * 4));
            }
            temp_angle /= 10;
        }
        
        // 4. Enviar para o periférico de display
        DISPLAY_7SEG_ADDR = bcd_val;
        
        // Pequeno atraso para estabilidade visual
        for (volatile uint32_t d = 0; d < 100000; d++);
    }
    
    return 0;
}
