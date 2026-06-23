#include <stdint.h>
#include "../_core/hardware.h" 

// Endereços Base corrigidos de endereço de palavra do VHDL para endereço de byte em C
// (Multiplicados por 4, pois cada palavra de 32-bits tem 4 bytes)
// VHDL MY_WORD_ADDRESS = x"01A0" -> Byte Address = x"01A0" * 4 = x"0680"
#define AS5600_PWM_ADDR    (*(_IO32 *) (PERIPH_BASE + 0x0680))
// VHDL MY_WORD_ADDRESS + 4 = x"01A4" -> Byte Address = x"01A4" * 4 = x"0690"
#define AS5600_PERIOD_ADDR (*(_IO32 *) (PERIPH_BASE + 0x0690))

// VHDL MY_WORD_ADDRESS = x"01B0" -> Byte Address = x"01B0" * 4 = x"06C0"
#define DISPLAY_7SEG_ADDR  (*(_IO32 *) (PERIPH_BASE + 0x06C0))

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
        
        // 2. Calcular o Ângulo baseado no Duty Cycle do AS5600
        // Conforme a Seção "PWM Output Mode" do datasheet do AS5600:
        // - O frame completo possui 4351 períodos de clock do PWM.
        // - O tempo mínimo em alto (ângulo = 0) é de 128 períodos de clock.
        // - A faixa de dados útil de ângulo (12 bits) vai de 0 a 4095.
        // O valor digital do ângulo (D) é calculado por:
        // D = (t_high * 4351 / t_period) - 128
        // Para evitar divisão por ponto flutuante e estouro em 32-bits, usamos uint64_t:
        if (t_period > 0) {
            uint64_t num = 4351ULL * t_high;
            uint64_t den = 128ULL * t_period;
            
            if (num > den) {
                uint32_t D = (uint32_t)((num - den) / t_period);
                if (D > 4095) {
                    D = 4095;
                }
                // Converte a faixa digital de 12 bits (0 a 4095) para graus (0 a 360)
                angle = (D * 360) / 4095;
            } else {
                angle = 0;
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
