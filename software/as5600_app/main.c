// Codigo principal para ler o AS5600 e mostrar no display
#include <stdint.h>
#include "../_core/hardware.h"
#include "../gpio/gpio.h"

// mapeamento de memória do modulo as5600 (slot 22)
#define AS5600_T_HIGH   (*(_IO32 *) (PERIPH_BASE + 22*16*4))
#define AS5600_T_PERIOD (*(_IO32 *) (PERIPH_BASE + 22*16*4 + 4))

// variáveis globais para lembrar a posição do giro entre uma leitura e outra
int32_t prev_angle = -1;
int32_t accum_angle = 0;

// função que calcula o valor a ser exibido (Modo Normal ou Modo Potenciômetro)
uint32_t calcular_modo_display(uint32_t angle_atual, uint32_t sw0_ligado) {
    if (sw0_ligado) {
        // MODO POTENCIÔMETRO (Múltiplas voltas, valor de 0 a 100)
        if (prev_angle == -1) {
            prev_angle = angle_atual; // Salva o ângulo em que a chave foi ligada
        } else {
            int32_t delta = angle_atual - prev_angle;
            
            // corrige o salto matemático quando a volta cruza o zero
            if (delta < -180) delta += 360;
            else if (delta > 180) delta -= 360;
            
            accum_angle += delta;
            
            // trava o limite entre 0 e 720 graus (2 voltas = valor 100)
            if (accum_angle > 720) accum_angle = 720;
            if (accum_angle < 0) accum_angle = 0;
            
            prev_angle = angle_atual;
        }
        
        // retorna o cálculo convertido (0 a 100)
        return (accum_angle * 50) / 360; 
        
    } else {
        // MODO NORMAL (Chave desligada, retorna apenas de 0 a 360)
        prev_angle = -1; // zera a referência para a próxima vez que ligar a chave
        accum_angle = 0;
        return angle_atual;
    }
}

int main() {
    uint32_t t_high;
    uint32_t t_period;
    uint32_t angle;
    uint32_t bcd_val;

    while (1) {
        // pega os valores direto do hardware
        t_high   = AS5600_T_HIGH;
        t_period = AS5600_T_PERIOD;

        angle = 0;
        if (t_period > 0) {
            // converte o tempo medido para a proporção de clocks do as5600 (4351 no total)
            uint32_t internal_high = (t_high * 4351) / t_period;

            // ignora os 128 clocks iniciais que são padrão do sensor
            if (internal_high > 128) {
                uint32_t data_val = internal_high - 128;

                // garante que não passa do limite de 12 bits
                if (data_val > 4095)
                    data_val = 4095;

                // faz a conversão pra 360 graus
                angle = (data_val * 360) / 4095;
            }
        }

        // lê a chave (usando INBUS de gpio.h)
        uint32_t sw0_ligado = INBUS & 0x01;
        
        // chama o bloco novo passando o angulo que seu código já calculou
        uint32_t valor_para_tela = calcular_modo_display(angle, sw0_ligado);

        // prepara os dados para o display usando a variável nova (valor_para_tela)
        uint32_t u = valor_para_tela % 10;
        uint32_t d = (valor_para_tela / 10) % 10;
        uint32_t c = (valor_para_tela / 100) % 10;

        bcd_val = 0xA;              // escreve '°' no primeiro display
        bcd_val |= (u << 4);        // escreve a unidade no segundo display

        // apaga a dezena caso seja menor que 10, para não ficar um zero a esquerda
        if (valor_para_tela >= 10) {
            bcd_val |= (d << 8);
        } else {
            bcd_val |= (0xF << 8);
        }

        // apaga a centena caso seja menor que 100, para não ficar um zero a esquerda
        if (valor_para_tela >= 100) {
            bcd_val |= (c << 12);
        } else {
            bcd_val |= (0xF << 12);
        }

        bcd_val |= 0xFF0000; // apaga os displays que sobram

        // atualiza os displays na placa
        SEGMENTS_BASE_ADDRESS = bcd_val;

        // delay para tela não piscar
        for (volatile uint32_t i = 0; i < 25000; i++);
    }

    return 0;
}
